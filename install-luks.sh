#!/bin/bash
set -e
DISK="/dev/nvme0n1"
PASSWORD="admin123"

umount /mnt 2>/dev/null || true
wipefs -a $DISK
parted $DISK -- mklabel gpt
parted $DISK -- mkpart primary fat32 1MB 512MB
parted $DISK -- set 1 esp on
parted $DISK -- mkpart primary ext4 512MB 1024MB
parted $DISK -- mkpart primary ext4 1024MB 100%

mkfs.fat -F 32 ${DISK}p1
mkfs.ext4 -F ${DISK}p2

echo -n "$PASSWORD" | cryptsetup luksFormat --type luks2 ${DISK}p3 -
echo -n "$PASSWORD" | cryptsetup open ${DISK}p3 cryptroot -

mkfs.ext4 -F /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount ${DISK}p1 /mnt/boot

nixos-generate-config --root /mnt

cat > /mnt/etc/nixos/configuration.nix << 'CONFIG'
{
  imports = [ ./hardware-configuration.nix ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices.cryptroot.device = "/dev/nvme0n1p3";
  networking.hostName = "nix-pc02enterprise";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = "fr";
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.pipewire.enable = true;
  services.openssh.enable = true;
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "admin123";
  };
  system.stateVersion = "25.11";
}
CONFIG

nixos-install --no-root-passwd
