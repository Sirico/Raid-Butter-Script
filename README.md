# Raid Butter Script

I created this because I was tired of messing with **fstab** every time I distro-hopped. I run a single SATA drive for my OS and pool NVMe drives for storage and gaming — this script is built around that design. It was mainly designed for Ublue os's so sets up flatpak permissions and mounts to /var/games by default this is because some games (like Forza Horizon 5)struggle if the steam directory is too long. 

**Raid Butter Script** is a user-friendly Bash + Zenity script for easily creating and managing a Btrfs-based gaming storage pool on Linux. It guides you through selecting unmounted drives, configuring mount options optimized for gaming, and automatically sets up dedicated folders for Steam, Lutris, and Heroic with proper Flatpak integration.

---

## Features

- ✅ Zenity-based GUI for drive selection  
- ✅ Automatic detection of unmounted disks  
- ✅ Configurable Btrfs mount options with gaming-optimized defaults  
- ✅ Safe confirmation and warning before wiping drives  
- ✅ RAID0 data with RAID1 metadata layout for performance and redundancy  
- ✅ Creates a persistent systemd mount unit  
- ✅ Sets up Flatpak overrides for Steam, Lutris, and Heroic  
- ✅ Tests write access to game folders  
- ✅ Easy, automated setup

---

## Prerequisites

- **Zenity** (required for the GUI prompts)  
  - On Fedora Silverblue/Bazzite:  
    ```bash
    rpm-ostree install zenity
    ```
  - On other distros:  
    ```bash
    sudo dnf install zenity
    ```
    or  
    ```bash
    sudo apt install zenity
    ```

- **btrfs-progs**  
  ```bash
  sudo dnf install btrfs-progs

## Usage

Save the script as btrfs-gaming-pool.sh and make it executable:

```bash
Copy
Edit
chmod +x btrfs-gaming-pool.sh
Run it:
```
```bash
Copy
Edit
./btrfs-gaming-pool.sh
```
Follow the Zenity prompts to:

Select two or more unmounted drives to pool (⚠️ WARNING: all data will be erased)

Choose a mount point (default: /var/games)

Confirm or adjust recommended Btrfs mount options

Confirm destructive operations

The script will then:

Wipe the selected drives

Create a Btrfs RAID0 pool with RAID1 metadata

Set up the mount point with a persistent systemd mount unit

Create directories for Steam, Lutris, and Heroic

Set Flatpak overrides for these apps

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

Why Btrfs for Gaming?
RAID0 for performance

RAID1 metadata for resilience

Modern CoW (copy-on-write) features

Snapshot support

Flexible expansion

Contributing
Pull requests, improvements, and suggestions are welcome!
