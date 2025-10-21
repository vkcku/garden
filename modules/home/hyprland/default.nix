{
  config,
  lib,
  pkgs,
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

    garden.user.packages = [ pkgs.hyprpaper ];

    garden.user.configFiles = {
      "hypr/hyprland.conf" = ./hyprland.conf;
    };

    # https://wiki.hypr.land/Nix/Hyprland-on-NixOS/#fixing-problems-with-themes
    programs.dconf.enable = true;
    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          gtk-theme = "Adwaita-dark";
        };
      }
    ];
  };
}
