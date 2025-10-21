{ config, lib, ... }:
let
  enabled = config.garden.profile == "daily-use";
in
{
  config = lib.mkIf enabled {
    time.timeZone = "Asia/Kolkata";
  };
}
