{ ... }:
{
  # keep-sorted start block=yes newline_separated=yes
  garden = {
    profile = "daily-use";

    # TODO: Turn off SSH.
    services.ssh.enable = true;
  };

  imports = [
    ../common.nix
    ./disk.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "joli";

  # DO NOT MODIFY.
  system.stateVersion = "25.11";

  time.timeZone = "Asia/Kolkata";
  # keep-sorted end
}
