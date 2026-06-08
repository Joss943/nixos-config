{ config, pkgs, lib, ... }:

let
  # Types d'utilisateurs
  userTypes = {
    standard = {
      groups = [ "users" "networkmanager" ];
      sudo = null;
      homeMode = "750";
      maxLogins = 2;
      quotaHome = "10GB";
      sessionTimeout = 300;
    };
    
    restricted = {
      groups = [ "users" ];
      sudo = null;
      homeMode = "755";
      maxLogins = 1;
      quotaHome = "5GB";
      sessionTimeout = 180;
    };
    
    local-admin = {
      groups = [ "wheel" "networkmanager" ];
      sudo = "ALL=(ALL) ALL";
      homeMode = "750";
      maxLogins = 3;
      quotaHome = "20GB";
      sessionTimeout = 600;
    };
  };
  
  adGroups = {
    "Domain Admins" = { gid = 10000; members = [ "admin" ]; };
    "IT Department" = { gid = 10001; members = [ "john" "jane" ]; };
    "Interns" = { gid = 10002; members = [ "bob" ]; };
  };
  
  passwordPolicy = {
    minLength = 12;
    maxAge = 90;
    minAge = 1;
    warnAge = 14;
    lockoutThreshold = 5;
    lockoutDuration = 900;
  };
  
in {
  # Hôte
  networking.hostName = "nix-auto";
  
  # Groupes
  users.groups = builtins.listToAttrs (map (name: {
    name = name;
    value = { gid = adGroups.${name}.gid; };
  }) (builtins.attrNames adGroups));
  
  # Utilisateur local admin
  users.users.admin = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "admin";
    homeMode = "750";
  };
  
  # Sudo
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
    extraRules = [
      {
        groups = [ "Domain Admins" ];
        commands = [ { command = "ALL"; options = [ "SETENV" ]; } ];
      }
      {
        groups = [ "IT Department" ];
        commands = [ { command = "/run/current-system/sw/bin/systemctl"; } ];
      }
    ];
  };
  
  # Verrouillage écran
  systemd.user.services.auto-lock = {
    script = "sleep 300 && ${pkgs.gnome.gnome-screensaver}/bin/gnome-screensaver-command --lock";
    wantedBy = [ "graphical-session.target" ];
  };
  
  # Version
  system.stateVersion = "25.11";
}