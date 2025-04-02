# /etc/nixos/hosts/proxmox-host/default.nix

# Correct function signature (adjust args as needed)
{ config, pkgs, lib, inputs, customPackages, ... }:

# 'let' block comes immediately after the signature
let
  # Import host-specific secrets if using file method
  # factorioSecrets = import /root/factorio-credentials.nix;

# 'in' is followed by ONE single attribute set containing ALL options
in {
  # --- Imports belong inside the main attribute set ---
  imports = [
    # ./hardware-configuration.nix # Make sure this exists/is correct relative path
    ../../modules/common.nix     # Make sure relative path is correct
    # Assuming base-server.nix, check name: ../../modules/services/base-server.nix
    # Make sure this path is correct, e.g., base-server.nix or base.nix?
    ../../modules/services/base.nix
    # Import the proxmox module from nixpkgs input
    "${inputs.nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
  ];

  # --- Host Specific Settings for proxmox-host ---

  networking.hostName = "factorio"; # Set hostname (or "proxmox-host"?)

  # Your specific Proxmox LXC settings
  proxmoxLXC = {
    manageNetwork = false;
    privileged = false;
  };

  # Factorio Service using the passed package and local secrets
  services.factorio = {
    package = customPackages.factorio; # Use package from specialArgs
    username = ""; # Use variable from 'let' block
    password = ""; # Use variable from 'let' block
    game-password = ""; # Use variable from 'let' block
    enable = true;
    openFirewall = true;
    public = true;
    lan = true;
    game-name = "SimonsNewJob"; # Or make this host-specific
    port = 34200;
  };

  # Other settings like system packages, ssh, etc. would go here too
  # environment.systemPackages = with pkgs; [ htop ]; # Example

  # Ensure state version is set
  system.stateVersion = "24.11"; # Or your appropriate version

# --- Closing brace for the SINGLE returned attribute set ---
}