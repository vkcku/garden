{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.garden.services.bluetooth;
in
{
  options.garden.services.bluetooth = {
    enable = lib.options.mkEnableOption "bluetooth";
  };

  # REFERENFCE: https://nixos.wiki/wiki/Bluetooth
  config = lib.mkIf cfg.enable {
    garden.user.packages = [ pkgs.bluez ];

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
