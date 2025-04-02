# /etc/nixos/modules/common.nix
# Settings applied to ALL hosts importing this module.
{ config, pkgs, lib, ... }:

{
  # --- Time & Location ---
  time.timeZone = "Europe/London"; # Set your timezone

  # --- Localization ---
  i18n.defaultLocale = "en_GB.UTF-8";
  # Add other locales if needed, e.g., console keymap
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "uk";
  # };

  # --- Basic System Packages (available on all hosts) ---
  # Host-specific configs can add more packages.
  environment.systemPackages = with pkgs; [
    vim       # Basic editor
    git       # Version control
    wget      # Network downloader
    curl      # Network utility
    htop      # Process viewer
    tmux      # Terminal multiplexer
    # Add other truly universal tools here
  ];

  # --- Basic User Setup ---
  # Define common users here, or manage them per-host.
  # Example: A shared admin user (consider security implications)
  users.users.admin = {
    isNormalUser = true;
    description = "Administrator";
    extraGroups = [ "networkmanager" "wheel" ]; # 'wheel' grants sudo access
    # Set initial password securely (e.g., using mkpasswd or secrets management)
    # initialHashedPassword = "$6$...hashedpassword...";
    openssh.authorizedKeys.keys = [
      # Add public SSH keys for this user here if desired globally
      # "ssh-ed25519 AAAAC3..."
    ];
  };
  # Allow users in 'wheel' group to use sudo
  security.sudo.wheelNeedsPassword = true;

  # --- Basic SSH Daemon Settings ---
  # Enable SSH access on all machines (can be overridden per-host)
  services.openssh = {
    enable = true;
    settings = {
      # PermitRootLogin = "no"; # Good security practice
      # PasswordAuthentication = false; # Recommended if using keys
      # KbdInteractiveAuthentication = false; # Often needed for PAM/2FA, disable if not
    };
  };

  # --- Nix Settings ---
  # Configure automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  # Keep a reasonable number of generations by default
  boot.loader.systemd-boot.configurationLimit = 10; # For systemd-boot
  # boot.loader.grub.configurationLimit = 10; # For GRUB

  # --- Basic Firewall ---
  # Enable firewall, specific rules defined per-host or per-role module.
  # This example allows established connections and related traffic, plus SSH.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ config.services.openssh.ports.[0] ]; # Allow SSH port
    # allowedUDPPorts = [ ... ];
  };

}