#!/usr/bin/env bash
DISK="/dev/nvme0n1"
umount /mnt 2>/dev/null
wipefs -a $DISK
parted $DISK -- mklabel gpt
parted $DISK -- mkpart primary fat32 1MB 512MB
parted $DISK -- set 1 esp on
parted $DISK -- mkpart primary ext4 512MB 100%
mkfs.fat -F 32 ${DISK}p1
mkfs.ext4 ${DISK}p2
mount ${DISK}p2 /mnt
mkdir /mnt/boot
mount ${DISK}p1 /mnt/boot
nixos-generate-config --root /mnt
cp /home/nixos/nixos-config/configuration.nix /mnt/etc/nixos/
nixos-install
