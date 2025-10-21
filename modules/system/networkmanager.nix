{ config, lib, ... }:
let
  cfg = config.garden.services.networkmanager;
in
{
  options.garden.services.networkmanager = {
    enable = lib.mkEnableOption "networkmanager";
  };

  config = lib.mkIf cfg.enable {
    # TODO: Configure network manager profiles.
    networking.networkmanager.enable = true;
  };
}
