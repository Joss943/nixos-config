{ config, pkgs, lib, ... }:

{
  networking.hostName = "nix-auto";

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

  system.stateVersion = "25.11";
}