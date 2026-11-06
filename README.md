# Asrock-Linux-Boot-issue-
B85M-ITX mother board - boot Linux distributions after install.


ASRock UEFI Boot Discovery & Repair Tool 🖥️

A Bash-based UEFI boot discovery and repair utility for ASRock motherboards.

Designed to help diagnose and restore missing UEFI boot entries when bootloaders are present on disk but are no longer registered in motherboard firmware.

Built for use with CachyOS Live USB, SteamOS recovery environments and other Linux-based recovery systems.

🎯 Project Goal

UEFI boot entries can disappear after BIOS updates, firmware resets, bootloader changes or operating system installations.

This tool scans available EFI System Partitions (ESP), identifies recognised bootloaders and helps recreate missing motherboard firmware boot entries without reinstalling the operating system.

The goal is to make UEFI boot recovery easier, safer and more accessible.

✨ Features
UEFI Firmware Diagnostics
Detects whether the system was booted in UEFI mode.
Displays existing motherboard firmware boot entries.
Uses efibootmgr to inspect UEFI NVRAM.
Identifies existing bootloader registrations.
Displays partition UUIDs and physical disk information.
EFI Partition Discovery
Automatically scans connected disks.
Identifies EFI System Partitions using their GPT partition type.
Detects FAT32 EFI partitions.
Displays discovered EFI files.
Mounts unmounted EFI partitions read-only for inspection.
Leaves existing mounts untouched.
Bootloader Detection

Automatically searches for the following bootloaders:

Bootloader	EFI Location
Limine	EFI/limine/limine_x64.efi
systemd-boot	EFI/systemd/systemd-bootx64.efi
GRUB	EFI/GRUB/grubx64.efi
Generic fallback	EFI/BOOT/BOOTX64.EFI
Fedora shim	EFI/fedora/shimx64.efi
UEFI Boot Entry Repair
Compares existing firmware entries against discovered EFI loaders.
Identifies missing boot entries.
Allows users to create new UEFI boot entries.
Automatically identifies the physical disk and partition number.
Generates descriptive boot entry labels.
Displays updated firmware boot configuration.
One-Time Boot Selection
Displays available firmware boot entries.
Allows selection of a one-time boot target.
Uses efibootmgr -n to configure BootNext.
Does not permanently change the boot order.
🔐 Safety Features

The tool is designed to minimise changes to existing installations.

EFI partitions are mounted read-only when mounting is required for inspection.
Existing mounted partitions are not remounted.
Existing boot entries are checked before creating new entries.
No partitions are formatted.
No existing EFI bootloader files are overwritten.
Boot entry creation requires user confirmation.
One-time boot selection requires user confirmation.

Important: Creating UEFI firmware entries modifies motherboard NVRAM. The tool does not modify existing EFI bootloader files or partition contents.

🔧 Requirements
ASRock motherboard with UEFI firmware.
Linux booted in UEFI mode.
Root privileges.
efibootmgr
lsblk
blkid
findmnt
mount
awk

Recommended recovery environments:

CachyOS Live USB
SteamOS recovery environment
Arch Linux Live USB
📦 Installation

Clone the repository:

bash
git clone https://github.com/YOUR_USERNAME/ASRock-UEFI-Boot-Repair.git


Enter the directory:

bash
cd ASRock-UEFI-Boot-Repair


Make the script executable:

bash
chmod +x AsrockCheckboot.sh


Run the utility:

bash
sudo ./AsrockCheckboot.sh


Alternatively:

bash
sudo bash AsrockCheckboot.sh

🖥️ How It Works
Checks that Linux was booted in UEFI mode.
Checks for efibootmgr and installs it using Pacman if necessary.
Displays current UEFI firmware boot entries.
Scans connected disks for EFI System Partitions.
Mounts unmounted EFI partitions read-only.
Searches for recognised bootloader EFI files.
Compares discovered loaders against existing firmware entries.
Offers to create missing UEFI boot entries.
Displays the updated firmware configuration.
Optionally configures a one-time boot target.
💡 Example Use Case

An ASRock motherboard boots directly into BIOS after a firmware reset.

The CachyOS installation is still present, and the EFI partition contains Limine, but the motherboard no longer has a corresponding boot entry.

Instead of reinstalling CachyOS:

Boot from a CachyOS Live USB.
Run the recovery script.
Scan the EFI partitions.
Locate the existing Limine EFI executable.
Create a new firmware boot entry.
Reboot and test the restored boot option.
⚠️ Important Notes
Secure Boot compatibility is not automatically verified.
The script currently detects specific EFI file paths and filenames.
It does not repair damaged EFI executables or bootloader configuration files.
It does not rebuild Limine, GRUB or systemd-boot installations.
A successful NVRAM entry creation does not guarantee that the operating system will boot.
Firmware behaviour varies between motherboard manufacturers and models.

Always ensure important data is backed up before performing boot recovery operations.

🚀 Project Status

Version 1.0 – UEFI Discovery & Boot Entry Repair

Implemented functionality:

UEFI mode detection.
EFI System Partition discovery.
Bootloader identification.
Firmware boot entry diagnostics.
Missing boot entry creation.
One-time boot selection.
Read-only EFI inspection.
👨‍💻 Contributing

Suggestions, improvements and bug reports are welcome.

Feel free to fork the project and contribute.

📜 License

MIT License (recommended).

ASRock UEFI Boot Discovery & Repair Tool

Find it. Register it. Boot again.

🐧 Built for Linux recovery and UEFI troubleshooting.
