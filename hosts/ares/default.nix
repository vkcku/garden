{ ... }:
{
  # keep-sorted start block=yes newline_separated=yes
  garden = {
    profile = "daily-use";
  };

  imports = [
    ../common.nix
    ./disk.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "ares";

  # DO NOT MODIFY
  system.stateVersion = "25.11";

  time.timeZone = "Asia/Kolkata";
  # keep-sorted end
}
