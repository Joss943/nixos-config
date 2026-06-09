{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nix-pc02enterprise";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  console.keyMap = "fr";

  services.xserver.enable = true;
  services.xserver.xkb.layout = "fr";
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      Port = 22;
    };
  };

  users.users.admin = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "admin";
  };

  security.sudo.enable = true;
  system.stateVersion = "25.05";
}