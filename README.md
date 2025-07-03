Btrfs Gaming Pool Generator
Btrfs Gaming Pool Generator is a user-friendly Bash + Zenity script for easily creating and managing a Btrfs-based gaming storage pool on Linux. It guides you through selecting unmounted drives, configuring mount options optimized for gaming, and automatically sets up dedicated folders for Steam, Lutris, and Heroic, with proper Flatpak integration.

Features

✅ Zenity-based GUI for drive selection

✅ Automatic detection of unmounted disks

✅ Configurable Btrfs mount options with gaming-optimized defaults

✅ Safe confirmation and warning before wiping drives

✅ RAID0 data with RAID1 metadata layout for performance and redundancy

✅ Creates a persistent systemd mount unit

✅ Sets up Flatpak overrides for Steam, Lutris, and Heroic

✅ Tests write access to game folders

✅ Easy, automated setup

Prerequisites
Zenity (required for GUI prompts)
Install on Fedora Silverblue/Bazzite with:

bash
Copy
Edit
rpm-ostree install zenity
or on other distros via:

bash
Copy
Edit
sudo dnf install zenity
or

bash
Copy
Edit
sudo apt install zenity
btrfs-progs

bash
Copy
Edit
sudo dnf install btrfs-progs
wipefs (usually included in util-linux)

Usage
Save the script as btrfs-gaming-pool.sh and make it executable:

bash
Copy
Edit
chmod +x btrfs-gaming-pool.sh
Run it:

bash
Copy
Edit
./btrfs-gaming-pool.sh
Follow the Zenity prompts to:

Select two or more unmounted drives to pool (⚠️ WARNING: data will be erased)

Choose a mount point (default /var/games)

Confirm or adjust recommended Btrfs mount options

Confirm destructive operations

The script will:

Wipe selected drives

Create a Btrfs RAID0 pool with RAID1 metadata

Set up the mount point with a systemd mount unit

Create directories for Steam, Lutris, and Heroic

Set Flatpak overrides for those apps

Test write access

Show a final Zenity success dialog

What It Does

✅ Detects and filters unmounted disks

✅ Offers a checklist to select drives

✅ Confirms data-wiping steps

✅ Creates a Btrfs RAID0 pool with RAID1 metadata

✅ Mounts with recommended gaming options

✅ Creates and enables a systemd mount unit

✅ Prepares game folders with proper permissions

✅ Integrates Flatpak apps with correct folder access

✅ Tests the pool for write access

Disclaimer
⚠️ This script will permanently erase all data on the selected drives. Double-check your selections before proceeding. You are responsible for any data loss.

Use at your own risk.

Why Btrfs for gaming?
RAID0 for performance

RAID1 metadata for resilience

Modern CoW features

Snapshot support

Flexible expansion

Example
bash
Copy
Edit
./btrfs-gaming-pool.sh
Zenity will walk you through the rest.

Contributing
Pull requests, improvements, and suggestions welcome!

