# /etc/nixos/modules/desktop.nix
# Settings for graphical desktop/laptop environments.
{ config, pkgs, lib, ... }:

{
  # --- Basic Desktop Setup ---
  # Enable sound server (PipeWire is default on modern NixOS)
  sound.enable = true;
  hardware.pulseaudio.enable = false; # Explicitly disable PulseAudio if using PipeWire
  security.rtkit.enable = true; # RealtimeKit for low-latency audio/PipeWire

  # Enable X11/Wayland graphical environment
  services.xserver.enable = true;

  # --- Choose and Configure Desktop Environment/Display Manager ---
  # Example: GNOME with GDM
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # --- Example: KDE Plasma with SDDM ---
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # --- Common Desktop Packages ---
  environment.systemPackages = with pkgs; [
    firefox          # Web browser
    libreoffice-fresh # Office suite
    vlc              # Media player
    gimp             # Image editor
    inkscape         # Vector graphics editor
    thunderbird      # Email client (optional)
    # Add your preferred desktop applications
  ];

  # --- Hardware Support ---
  # Enable Bluetooth support
  hardware.bluetooth.enable = true;
  services.blueman.enable = true; # Optional GUI for Bluetooth

  # Enable printing support
  services.printing.enable = true;
  services.avahi = { # mDNS for network discovery (printers, etc.)
    enable = true;
    nssmdns = true;
    openFirewall = true; # Allow mDNS traffic
  };

  # Enable power management for laptops (optional)
  # services.tlp.enable = true;

  # --- Fonts ---
  # Add extra fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    # Add others as needed
  ];

}