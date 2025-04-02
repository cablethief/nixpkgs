# /etc/nixos/hosts/proxmox-host/default.nix
{ config, pkgs, lib, inputs, customPackages, ... }: # Note 'inputs' and 'factorioPackage' from specialArgs

# Import shared modules and this host's hardware config
imports = [
  ../../modules/common.nix # Example shared module
  ../../modules/services/base.nix
  "${inputs.nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix" # Import needed module
];

let
  # Import host-specific secrets if using file method
  factorioSecrets = import ./secrets/factorio-credentials.nix;
in {
  # --- Host Specific Settings for proxmox-host ---

  networking.hostName = "factorio"; # Set hostname

  # Your specific Proxmox LXC settings
  proxmoxLXC = {
    manageNetwork = false;
    privileged = false;
  };

  # Factorio Service using the passed package and local secrets
  services.factorio = {
    package = customPackages.factorio; # Use package from specialArgs
    username = factorioSecrets.username;
    password = factorioSecrets.password;
    game-password = factorioSecrets.gamePassword;
    enable = true;
    openFirewall = true;
    public = true;
    lan = true;
    game-name = "SimonsNewJob"; # Or make this host-specific
    port = 34200;
  };


  # environment.systemPackages = with pkgs; [ htop ]; # Only packages needed here

  # Ensure state version is set
  system.stateVersion = "24.11"; # Or your appropriate version
}