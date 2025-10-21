{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.garden.user.ghostty;
  enable = config.garden.user.enable && cfg.enable;

  toKeyValueSettings = {
    # There is no space before and after the '=' sign by default and I do not like
    # that.
    mkKeyValue = lib.generators.mkKeyValueDefault { } " = ";
  };
  writeGhosttyConfig = (pkgs.formats.keyValue toKeyValueSettings).generate;
in
{
  options.garden.user.ghostty = {
    enable = lib.options.mkEnableOption "ghostty";
  };

  config = lib.mkIf enable {
    garden.user.packages = [ pkgs.ghostty ];

    garden.user.configFiles = {
      "ghostty/config" = writeGhosttyConfig "ghostty-config" {
        # keep-sorted start
        auto-update = "off";
        background = "1e1e1e";
        background-opacity = 0.900000;
        desktop-notifications = false;
        fullscreen = true;
        gtk-tabs-location = "hidden";
        window-padding-color = "extend";
        # keep-sorted end
      };
    };
  };
}
