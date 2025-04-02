# /path/to/my-factorio-flake/flake.nix
{
  description = "A custom flake for the Factorio game";

  inputs = {
    # Use the nixpkgs revision you want the package to be built against
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Or stable, or a specific commit
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Import nixpkgs for the target system
        pkgs = import nixpkgs {
          inherit system;
          # You could apply overlays here if needed, but usually not necessary for just packaging
          # overlays = [ ... ];
          # Allow non-free packages like factorio
          config.allowUnfree = true;
        };

        # Define how to call your factorio package definition
        factorioDrv = pkgs.callPackage ./pkgs/factorio {
          # You can override arguments here if needed.
          # For example, to enable steam support:
          # steamSupport = true;
          # steam = pkgs.steam; # Ensure steam is passed if steamSupport = true
        };

        # Version with Steam support (demonstrates passing args)
        factorioSteamDrv = pkgs.callPackage ./pkgs/factorio {
           steamSupport = true;
           steam = pkgs.steam; # callPackage finds 'steam' within 'pkgs'
        };

      in
      {
        # Expose the package(s) under the 'packages' attribute
        packages = {
          factorio = factorioDrv;
          factorio-steam = factorioSteamDrv;
          # Set a default for convenience (e.g., `nix build .`)
          default = self.packages.${system}.factorio;
        };

        # Optional: Provide an overlay for easy integration into other flakes
        overlays.default = final: prev: {
          factorio = self.packages.${prev.system}.factorio;
          factorio-steam = self.packages.${prev.system}.factorio-steam;
        };

        # Optional: Default application for `nix run .`
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/factorio";
        };
        apps.factorio = self.apps.default;
        apps.factorio-steam = {
          type = "app";
          program = "${self.packages.${system}.factorio-steam}/bin/factorio";
        };
      }
    );
}