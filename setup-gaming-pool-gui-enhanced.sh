#!/usr/bin/env bash

# Ensure zenity is installed
if ! command -v zenity &> /dev/null; then
  echo "Zenity is required. Install it with: rpm-ostree install zenity"
  exit 1
fi

# Get all physical disks
ALL_DISKS=$(lsblk -ndo NAME,TYPE | awk '$2=="disk" {print "/dev/" $1}')

# Get mounted devices
MOUNTED=$(lsblk -nrpo NAME,MOUNTPOINT | awk '$2!="" {print $1}')

# Filter unmounted disks
UNMOUNTED_DISKS=()
for d in $ALL_DISKS; do
  if ! echo "$MOUNTED" | grep -q "$d"; then
    UNMOUNTED_DISKS+=("$d")
  fi
done

if [[ ${#UNMOUNTED_DISKS[@]} -eq 0 ]]; then
  zenity --error --text="No unmounted drives found. Cannot continue."
  exit 1
fi

# Build Zenity checklist input
DRIVE_SELECTION=()
for d in "${UNMOUNTED_DISKS[@]}"; do
  DRIVE_SELECTION+=("FALSE" "$d")
done

# Drive selection
SELECTED=$(zenity --list --checklist \
  --title="Select Drives to Pool" \
  --text="Select 2 or more UNMOUNTED drives for the Btrfs pool. THIS WILL ERASE THEM." \
  --column="Select" --column="Drive" \
  --width=500 --height=400 \
  "${DRIVE_SELECTION[@]}")

if [[ -z "$SELECTED" ]]; then
  zenity --error --text="No drives selected. Aborting."
  exit 1
fi

# Split Zenity output into array
IFS="|" read -ra SELECTED_ARRAY <<< "$SELECTED"

NUM_SELECTED=${#SELECTED_ARRAY[@]}
if [[ "$NUM_SELECTED" -lt 2 ]]; then
  zenity --error --text="You must select at least 2 drives. You selected $NUM_SELECTED."
  exit 1
fi

# Ask for mountpoint
MOUNTPOINT=$(zenity --entry --title="Choose Mount Point" \
  --text="Enter the full path for where you want to mount the pool:" \
  --entry-text="/var/games")

if [[ -z "$MOUNTPOINT" ]]; then
  zenity --error --text="No mount point entered. Aborting."
  exit 1
fi

# Ask for Btrfs mount options
MOUNT_OPTIONS=$(zenity --list --checklist \
  --title="Select Btrfs Mount Options" \
  --text="Recommended options for gaming are pre-selected." \
  --column="Use" --column="Option" --column="Description" \
  TRUE noatime "Do not update access times (speeds up reads)" \
  TRUE ssd "Enable SSD optimizations" \
  TRUE space_cache=v2 "Improved space cache" \
  TRUE discard=async "Asynchronous TRIM" \
  FALSE compress=zstd:1 "Zstandard compression (space-saving, may slow access)" \
  --width=800 --height=400)

if [[ -z "$MOUNT_OPTIONS" ]]; then
  zenity --error --text="No mount options selected. Aborting."
  exit 1
fi

# Confirm wipe
zenity --question --text="⚠️ This will ERASE ALL DATA on: ${SELECTED_ARRAY[*]}. Continue?" || exit 1

LABEL="gaming_pool"

# Detect current user safely
USER_NAME=$(whoami)
if [[ "$USER_NAME" == "root" ]]; then
  USER_NAME=$(logname 2>/dev/null || echo "")
  if [[ -z "$USER_NAME" ]]; then
    USER_NAME=$(zenity --entry --title="User Name Required" --text="Enter your Linux username to set folder permissions:")
  fi
fi

echo "🧹 Wiping drives..."
for DRIVE in "${SELECTED_ARRAY[@]}"; do
  sudo wipefs -a "$DRIVE"
done

echo "🛠️ Creating Btrfs RAID 0 pool with RAID 1 metadata..."
sudo mkfs.btrfs -f -L "$LABEL" -d raid0 -m raid1 "${SELECTED_ARRAY[@]}"

echo "📁 Creating mount point at $MOUNTPOINT..."
sudo mkdir -p "$MOUNTPOINT"

echo "🔗 Mounting temporarily..."
sudo mount -o $(echo $MOUNT_OPTIONS | tr '|' ',') LABEL="$LABEL" "$MOUNTPOINT"

echo "🎮 Creating game directories..."
for folder in Steam Lutris Heroic; do
  sudo mkdir -p "$MOUNTPOINT/$folder"
  sudo chown -R "$USER_NAME:$USER_NAME" "$MOUNTPOINT/$folder"
  sudo chmod -R u+rwX "$MOUNTPOINT/$folder"
done

MOUNT_UNIT_NAME=$(echo "$MOUNTPOINT" | sed 's|^/||;s|/|-|g').mount

echo "🧾 Creating systemd mount unit at /etc/systemd/system/$MOUNT_UNIT_NAME..."
sudo tee /etc/systemd/system/$MOUNT_UNIT_NAME > /dev/null <<EOF
[Unit]
Description=Mount Btrfs gaming pool at $MOUNTPOINT
Before=local-fs.target
After=systemd-udev-settle.service

[Mount]
What=LABEL=$LABEL
Where=$MOUNTPOINT
Type=btrfs
Options=$(echo $MOUNT_OPTIONS | tr '|' ',')

[Install]
WantedBy=local-fs.target
EOF

echo "🔄 Reloading systemd and enabling mount unit..."
sudo systemctl daemon-reload
sudo systemctl enable --now $MOUNT_UNIT_NAME

echo "🔧 Setting Flatpak overrides..."
flatpak override com.valvesoftware.Steam --filesystem=$MOUNTPOINT/Steam:rw
flatpak override net.lutris.Lutris --filesystem=$MOUNTPOINT/Lutris:rw
flatpak override com.heroicgameslauncher.hgl --filesystem=$MOUNTPOINT/Heroic:rw

echo "🧪 Testing write access..."
for path in $MOUNTPOINT/Steam $MOUNTPOINT/Lutris $MOUNTPOINT/Heroic; do
  if touch "$path/testfile"; then
    echo "✅ Write test passed for $path"
    rm "$path/testfile"
  else
    echo "❌ Write test failed for $path"
  fi
done

zenity --info --text="✅ Gaming pool setup complete! Mounted at $MOUNTPOINT"

