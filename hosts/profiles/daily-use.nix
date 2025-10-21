{ config, lib, ... }:
let
  enabled = config.garden.profile == "daily-use";
in
{
  config = lib.mkIf enabled {
    # keep-sorted start block=yes newline_separated=yes
    garden = {
      services.networkmanager.enable = true;

      user.nushell = {
        enableStarship = true;
        enableZoxide = true;
      };
    };

    time.timeZone = "Asia/Kolkata";
    # keep-sorted end
  };
}
