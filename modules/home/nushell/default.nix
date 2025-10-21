{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.garden.user.nushell;

  enable = config.garden.user.enable && cfg.enable;

  starship = ''
    mkdir ($nu.data-dir | path join "vendor/autoload")
    ${pkgs.starship}/bin/starship init nu | save --force ($nu.data-dir | path join "vendor/autoload/starship.nu")
  '';

  zoxideEnv = ''
    mkdir $nu.data-dir
    zoxide init nushell | save --force ($nu.data-dir | path join "zoxide.nu")
  '';

  zoxideConfig = ''
    source ($nu.data-dir | path join "zoxide.nu")
    alias cd = __zoxide_z
    alias cdi = __zoxide_zi
  '';

  nushellEnv = ''
    ${lib.strings.optionalString cfg.enableZoxide zoxideEnv}
  '';

  nushellConfig = ''
    ${builtins.readFile ./config.nu}

    ${lib.strings.optionalString cfg.enableStarship starship}
    ${lib.strings.optionalString cfg.enableZoxide zoxideConfig}
  '';
in
{
  options.garden.user.nushell = {
    enable = lib.mkEnableOption "nushell";

    enableStarship = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the starship prompt.";
    };

    enableZoxide = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable zoxide.";
    };
  };

  config = lib.mkIf enable {
    garden.user.packages = lib.lists.optional cfg.enableZoxide pkgs.zoxide;

    garden.user.configFiles = {
      "nushell/config.nu" = nushellConfig;
      "nushell/env.nu" = nushellEnv;
    };
  };
}
