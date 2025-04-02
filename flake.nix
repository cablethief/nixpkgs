# /etc/nixos/flake.nix (Multi-Host Example)
{
  description = "My NixOS Configurations for Multiple Hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Or your preferred branch
    # Add other inputs if needed (e.g., home-manager, agenix)
    # agenix = { url = "github:ryantm/agenix"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # --- Define common helper functions or values ---
      # Function to generate pkgs for a specific system, ensuring unfree is enabled
      pkgsFor = system: import nixpkgs {
         inherit system;
         config.allowUnfree = true; # Needed for Factorio package build
         # Add overlays here if needed globally: overlays = [ ... ];
      };

      # --- Define common custom packages once ---
      # Function to build factorio for a specific system
      factorioPackageFor = system: (pkgsFor system).callPackage ./pkgs/factorio {};
      # Add other custom packages if you have them

      # --- Common Special Args to pass to all hosts ---
      commonSpecialArgs = {
        # Make all inputs available if needed by shared modules
        inherit inputs;
        # Pass common custom packages (adjust system architecture if needed)
        factorioPackage = factorioPackageFor "x86_64-linux";
      };

    in {
      # --- Define each NixOS Host ---
      nixosConfigurations = {

        "proxmox-host" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux"; # Specify architecture
          specialArgs = commonSpecialArgs; # Pass common args
          modules = [
            # Host-specific main configuration file
            ./hosts/proxmox-host/default.nix

            # Shared modules this host should include
            # ./modules/common.nix
            # ./modules/services/base-server.nix

            # Proxmox module - now likely imported within hosts/proxmox-host/default.nix
            # Or kept here if truly fundamental to this flake output

            # Inline module for Nix settings (can stay if universal)
            ({ config, pkgs, ... }: {
              nix.settings = {
                sandbox = false;
                experimental-features = [ "nix-command" "flakes" ];
                auto-optimise-store = true;
              };
            })
            # Add agenix module if using it: inputs.agenix.nixosModules.default
          ];
        };

        # "laptop-bravo" = nixpkgs.lib.nixosSystem {
        #   system = "x86_64-linux";
        #   specialArgs = commonSpecialArgs; # Pass common args (Factorio might not be needed here!)
        #   # Alternatively define specific specialArgs: specialArgs = { inherit inputs; };
        #   modules = [
        #     # Host-specific main configuration file
        #     ./hosts/laptop-bravo/default.nix

        #     # Shared modules this host should include
        #     # ./modules/common.nix
        #     # ./modules/desktop.nix
        #   ];
        # };

        # "server-alpha" = nixpkgs.lib.nixosSystem {
        #   system = "x86_64-linux";
        #   specialArgs = commonSpecialArgs;
        #   modules = [
        #     # Host-specific main configuration file
        #     ./hosts/server-alpha/default.nix
        #     # ./modules/common.nix
        #     # ./modules/services/base-server.nix
        #     # Add other modules specific to this server role...
        #   ];
        # };

        # --- Add more hosts here ---

      }; # End nixosConfigurations

      # Optional: Expose packages/overlays/apps if needed
      packages.x86_64-linux.factorio = factorioPackageFor "x86_64-linux";
      # ... other outputs ...

    }; # End outputs
}