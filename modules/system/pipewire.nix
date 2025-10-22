{ config, lib, ... }:
let
  cfg = config.garden.services.pipewire;
in
{
  options.garden.services.pipewire = {
    enable = lib.mkEnableOption "pipewire";
  };

  # REFERENCE: https://nixos.wiki/wiki/PipeWire
  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
