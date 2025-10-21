{
  config,
  lib,
  ...
}:
let
  cfg = config.garden.user.hyprland;
  enable = config.garden.user.enable && cfg.enable;
in
{
  options.garden.user.hyprland = {
    enable = lib.options.mkEnableOption "hyprland";
  };

  config = lib.mkIf enable {
    programs.hyprland = {
      enable = cfg.enable;
      withUWSM = true;
    };

    garden.user.configFiles = {
      "hypr/hyprland.conf" = ./hyprland.conf;
    };
  };
}
