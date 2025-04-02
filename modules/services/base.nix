# /etc/nixos/modules/services/base-server.nix
# Common settings for headless servers.
{ config, pkgs, lib, ... }:

let
  githubUsername = "cablethief"; # <<< Replace with your GitHub username
  # --- Paste the SHA256 hash you calculated here ---
  githubKeysSha256 = "02ec593ac978bea28de7508c7ace7a3d7306dc6aebc0ca8e0cced6c42ed0ba30"; # <<< Replace with the actual hash

  # Fetch the keys file from GitHub
  githubKeysFile = builtins.fetchurl {
    url = "https://github.com/${githubUsername}.keys";
    sha256 = githubKeysSha256;
  };

  # Read the content of the fetched file and split into a list of keys
  githubKeysList =
    let
      fileContent = builtins.readFile githubKeysFile;
    in
      # Split by newline and remove any empty strings resulting from trailing newlines
      lib.filter (s: s != "") (lib.splitString "\n" fileContent);

in {
  # Consider if servers should have *fewer* packages than common.nix
  environment.systemPackages = with pkgs; [ git vim curl ]; # Example override

  # --- Strict Firewall ---
  # Example: Default deny incoming, only allow specific ports explicitly
  networking.firewall = {
    enable = true;
    rejectPackets = true; # Or false to drop silently
    allowedTCPPorts = [
    #   config.services.openssh.ports.[0] # Definitely allow SSH
    #   # Add other ports needed by server roles (e.g., 80, 443 for web)
    ];
    allowedUDPPorts = [
      # Add UDP ports if needed
    ];
    # Allow pings (optional)
    icmp_echo_requests.enable = true;
  };
  
  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
        PasswordAuthentication = false; # Strongly recommended for servers
        PermitRootLogin = "no"; # Disable direct root login
        # Consider adding: UseDNS no (can speed up logins)
        # Consider adding: AllowUsers admin backupuser ... (whitelist users)
    };
  };


    users.users.michael = {
        openssh.authorizedKeys = {
            keys = githubKeysList;
        };
    };

    # --- Log Management ---
    # Configure journald storage and limits
    services.journald = {
        storage = "persistent"; # Or "volatile"
        extraConfig = ''
        SystemMaxUse=500M
        RuntimeMaxUse=500M
        '';
    };

    system.autoUpgrade = {
        enable = true;
        flake = inputs.self.outPath;
        flags = [
            "--update-input"
            "nixpkgs"
            "-L" # print build logs
        ];
        dates = "02:00";
        randomizedDelaySec = "45min";
    };


    }
