# /etc/nixos/flake.nix (With Automatic Package Discovery)
{
  description = "My NixOS Configuration and Custom Packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # flake-utils provides helpers like eachDefaultSystem if you prefer that
    # flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # Use nixpkgs lib functions for system iteration
      lib = nixpkgs.lib;
      # Systems to build packages for (or use flake-utils.lib.eachDefaultSystem)
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ]; # Add systems you need

      # --- Function to Discover and Build Packages for a System ---
      discoverPackages = system:
        let
          # Get pkgs for the specific system
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true; # Allow building unfree pkgs like Factorio
            # overlays = [ ... ]; # Apply overlays if needed globally for builds
          };

          # Define the path to your packages directory
          pkgsPath = ./pkgs;

          # Read the directory contents { factorio = "directory"; ... }
          pkgsDirEntries = builtins.readDir pkgsPath;

          # Filter out non-directories (like README files, etc.)
          packageDirs = lib.filterAttrs (name: type: type == "directory") pkgsDirEntries;

          # Create an attribute set { packageName = packageDerivation; ... }
          # by calling callPackage on each directory found
          packagesSet = lib.mapAttrs (pkgName: type:
            pkgs.callPackage "${pkgsPath}/${pkgName}" {
              # You can pass arguments here if needed by specific packages,
              # but typically {} is sufficient for self-contained packages.
              # Example: someArg = "value";
            }
          ) packageDirs;

        in packagesSet; # Return the set like { factorio = <drv>; my-cool-script = <drv>; }

      # --- Generate package sets for all supported systems ---
      packagesPerSystem = lib.genAttrs supportedSystems discoverPackages;

    in {
      # --- Expose Packages ---
      # packages = flake-utils.lib.eachDefaultSystem (system: discoverPackages system); # Alternative using flake-utils
      packages = packagesPerSystem;

      # --- Expose Overlay ---
      # The overlay provides the discovered packages for the system it's applied to.
      overlays.default = final: prev: discoverPackages prev.system;

      # --- NixOS Configurations ---
      nixosConfigurations = {
        "factorio" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            # Pass the set of discovered packages for this host's system
            customPackages = packagesPerSystem."x86_64-linux";
          };
          modules = [
            ./hosts/factorio/default.nix
            # ./modules/services/base.nix
            # ./modules/common.nix
            # ... other modules ...
          ];
        };

        # "laptop-bravo" = lib.nixosSystem {
        #   system = "x86_64-linux";
        #    specialArgs = {
        #      inherit inputs;
        #      customPackages = packagesPerSystem."x86_64-linux";
        #      # You might have different specialArgs per host if needed
        #    };
        #    modules = [
        #      ./hosts/laptop-bravo/default.nix
        #      # ... other modules ...
        #    ];
        # };

        # Add other hosts...
      }; # End nixosConfigurations

      # --- Optional: Default Package ---
      # Select a default package if desired, e.g., for `nix build .`
      # Requires choosing one package name consistently.
      # defaultPackage = lib.genAttrs supportedSystems (system: packagesPerSystem.${system}.factorio);

    }; # End outputs
}