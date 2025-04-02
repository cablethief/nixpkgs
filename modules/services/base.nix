# /etc/nixos/modules/services/base-server.nix
# Common settings for headless servers.
{ config, pkgs, lib, ... }:

{
  # --- Minimal Packages ---
  # Consider if servers should have *fewer* packages than common.nix
  # environment.systemPackages = with pkgs; [ git htop ]; # Example override

  # --- Strict Firewall ---
  # Example: Default deny incoming, only allow specific ports explicitly
  networking.firewall = {
    enable = true;
    rejectPackets = true; # Or false to drop silently
    allowedTCPPorts = [
      config.services.openssh.ports.[0] # Definitely allow SSH
      # Add other ports needed by server roles (e.g., 80, 443 for web)
    ];
    allowedUDPPorts = [
      # Add UDP ports if needed
    ];
    # Allow pings (optional)
    # icmp_echo_requests.enable = true;
  };

  # --- SSH Hardening ---
  services.openssh.settings = {
    PasswordAuthentication = false; # Strongly recommended for servers
    PermitRootLogin = "no"; # Disable direct root login
    # Consider adding: UseDNS no (can speed up logins)
    # Consider adding: AllowUsers admin backupuser ... (whitelist users)
  };

  # --- Disable Unnecessary Services ---
  # Ensure services typically used for desktop are off
  sound.enable = false;
  hardware.bluetooth.enable = false;
  services.printing.enable = false;
  services.blueman.enable = false;

  # --- Monitoring ---
  # Example: Enable node_exporter for Prometheus monitoring
  # services.prometheus.exporters.node = {
  #   enable = true;
  #   enabledCollectors = [ "systemd" ]; # Choose collectors
  #   listenAddress = "0.0.0.0";
  #   port = 9100;
  #   openFirewall = true; # Add firewall rule for node_exporter port
  # };

  # --- Log Management ---
  # Configure journald storage and limits
  services.journald = {
    storage = "persistent"; # Or "volatile"
    extraConfig = ''
      SystemMaxUse=500M
      RuntimeMaxUse=500M
    '';
  };

}