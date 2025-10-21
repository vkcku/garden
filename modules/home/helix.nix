{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.garden.user.helix;
  enable = config.garden.user.enable && cfg.enable;
in
{
  options.garden.user.helix = {
    enable = lib.mkEnableOption "helix";
  };

  config = lib.mkIf enable {
    garden.user.packages = [ pkgs.helix ];

    garden.user.configFiles = {
      "helix/config.toml" = pkgs.writers.writeTOML "helix-config.toml" {
        theme = "ayu_dark";

        editor = {
          auto-format = false;
          line-number = "relative";
          shell = [
            "nu"
            "--commands"
          ];
          true-color = true;
          cursor-shape.insert = "bar";
          file-picker.hidden = false;
          soft-wrap.enable = true;
          statusline = {
            left = [
              "mode"
              "spinner"
              "file-name"
              "read-only-indicator"
              "file-modification-indicator"
            ];
            center = [ ];
            right = [
              "diagnostics"
              "register"
              "position"
              "spacer"
              "version-control"
            ];
          };
        };

        keys = {
          # Write the file, if modified, when switching to normal mode from insert mode.
          insert.esc = [
            "normal_mode"
            ":update"
          ];
          normal.g.e = "goto_last_line";
          select.g.e = "goto_last_line";
        };
      };
    };
  };
}
