
#!/usr/bin/env bash

# ASRock UEFI Boot Discovery & Repair
# Supports Limine, systemd-boot and GRUB
# Designed for SteamOS recovery and CachyOS live USB.

set -uo pipefail

ESP_ROOT="/mnt/uefi-repair"
declare -a MOUNTED=()

pause() {
    read -rp "Press Enter to continue..."
}

ask() {
    local answer
    read -rp "$1 [y/N]: " answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

header() {
    clear
    echo "======================================"
    echo "       UEFI BOOT REPAIR TOOL"
    echo "======================================"
    echo
}

cleanup() {
    echo
    echo "Mounts have been left in place for inspection."
}

trap cleanup EXIT

if [[ $EUID -ne 0 ]]; then
    echo "Run with sudo: sudo bash $0"
    exit 1
fi

if [[ ! -d /sys/firmware/efi ]]; then
    echo "ERROR: This system was not booted in UEFI mode."
    exit 1
fi

if ! command -v efibootmgr >/dev/null; then
    echo "Installing efibootmgr..."
    if command -v pacman >/dev/null; then
        pacman -Sy --noconfirm efibootmgr || exit 1
    else
        echo "Please install efibootmgr manually."
        exit 1
    fi
fi

header
echo "Current firmware boot entries:"
efibootmgr -v
echo

if ! ask "Scan disks for EFI System Partitions?"; then
    exit 0
fi

mapfile -t PARTITIONS < <(
    lsblk -rpno NAME,PARTTYPE,FSTYPE |
    awk 'tolower($2)=="c12a7328-f81f-11d2-ba4b-00a0c93ec93b" &&
         tolower($3)=="vfat" {print $1}'
)

if [[ ${#PARTITIONS[@]} -eq 0 ]]; then
    echo "No FAT32 EFI System Partitions found."
    exit 1
fi

echo
echo "EFI partitions discovered:"
printf '  %s\n' "${PARTITIONS[@]}"
echo

for PART in "${PARTITIONS[@]}"; do

    echo
    echo "======================================"
    echo "Inspecting: $PART"
    echo "======================================"

    UUID=$(blkid -s UUID -o value "$PART" || true)
    DISK=$(lsblk -no PKNAME "$PART" | head -n1)
    PARTNUM=$(lsblk -no PARTN "$PART")

    echo "Partition UUID: $UUID"
    echo "Physical disk:  /dev/$DISK"
    echo "Partition:      $PARTNUM"

    MOUNT=$(findmnt -rn -S "$PART" -o TARGET | head -n1 || true)

    if [[ -z "$MOUNT" ]]; then
        echo
        echo "Partition is not mounted."

        if ask "Mount $PART read-only for inspection?"; then
            MOUNT="$ESP_ROOT/$(basename "$PART")"
            mkdir -p "$MOUNT"

            if ! mount -o ro "$PART" "$MOUNT"; then
                echo "Mount failed. Skipping."
                continue
            fi

            MOUNTED+=("$MOUNT")
        else
            continue
        fi
    else
        echo "Already mounted at: $MOUNT"
    fi

    echo
    echo "EFI files discovered:"

    find "$MOUNT/EFI" -maxdepth 3 -type f \
        \( -iname '*.efi' \) 2>/dev/null || true

    echo
    echo "Bootloader detection:"

    declare -a LOADERS=()

    if [[ -f "$MOUNT/EFI/BOOT/BOOTX64.EFI" ]]; then
        LOADERS+=('\EFI\BOOT\BOOTX64.EFI')
        echo "[FOUND] Generic fallback EFI"
    fi

    if [[ -f "$MOUNT/EFI/limine/limine_x64.efi" ]]; then
        LOADERS+=('\EFI\limine\limine_x64.efi')
        echo "[FOUND] Limine"
    fi

    if [[ -f "$MOUNT/EFI/systemd/systemd-bootx64.efi" ]]; then
        LOADERS+=('\EFI\systemd\systemd-bootx64.efi')
        echo "[FOUND] systemd-boot"
    fi

    if [[ -f "$MOUNT/EFI/GRUB/grubx64.efi" ]]; then
        LOADERS+=('\EFI\GRUB\grubx64.efi')
        echo "[FOUND] GRUB"
    fi

    if [[ -f "$MOUNT/EFI/fedora/shimx64.efi" ]]; then
        LOADERS+=('\EFI\fedora\shimx64.efi')
        echo "[FOUND] Fedora shim"
    fi

    if [[ ${#LOADERS[@]} -eq 0 ]]; then
        echo "No recognised bootloader found."
        continue
    fi

    echo
    echo "Existing firmware entries for this partition:"
    efibootmgr -v | grep -i "$UUID" || echo "No matching UUID found."

    for LOADER in "${LOADERS[@]}"; do

        echo
        echo "Candidate: $LOADER"

        # Compare the loader's partition GUID against existing entries.
        PARTUUID=$(blkid -s PARTUUID -o value "$PART")

        if efibootmgr -v | grep -iF "$PARTUUID" |
            grep -Fqi "$LOADER"; then
            echo "[EXISTS] Matching UEFI entry found."
            continue
        fi

        echo "[MISSING] No matching UEFI entry found."

        if ask "Create UEFI boot entry for $LOADER?"; then

            DISKPATH="/dev/$DISK"

            efibootmgr --create \
                --disk "$DISKPATH" \
                --part "$PARTNUM" \
                --label "$(basename "$DISK") $(basename "$LOADER" .efi)" \
                --loader "$LOADER"

            echo
            echo "Updated boot entries:"
            efibootmgr -v
        fi
    done

    echo
    echo "Finished inspecting $PART."
done

echo
echo "======================================"
echo "           REPAIR COMPLETE"
echo "======================================"

echo
echo "Current firmware boot configuration:"
efibootmgr -v

echo
if ask "Would you like to select a one-time boot target?"; then

    efibootmgr

    echo
    read -rp "Enter boot number (e.g. 0001): " ENTRY

    if [[ "$ENTRY" =~ ^[0-9A-Fa-f]{4}$ ]]; then
        efibootmgr -n "$ENTRY"
        echo "BootNext configured."
    else
        echo "Invalid boot number."
    fi
fi

echo
echo "No partitions were formatted or modified."
echo "No existing EFI files were overwritten."
