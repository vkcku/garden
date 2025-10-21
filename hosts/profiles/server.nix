{ config, lib, ... }:
let
  enabled = config.garden.profile == "server";
in
{
  config = lib.mkIf enabled {
    time.timeZone = "UTC";
  };
}
