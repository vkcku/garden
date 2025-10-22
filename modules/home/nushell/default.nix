{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.garden.user.nushell;
  enable = config.garden.user.enable && cfg.enable;

  inherit (lib.strings) optionalString;

  mkSourceLine = path: "source ${path}";
  mkSourceLineIf = cond: path: if cond then mkSourceLine path else "";

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

  sshAgent = ''
    load-env {
      SSH_AUTH_SOCK: ($env.XDG_RUNTIME_DIR | path join "ssh-agent.sock")
    }
  '';

  nushellEnv = ''
    ${optionalString cfg.enableZoxide zoxideEnv}
  '';

  # TODO: Have a "minimal" flag that can be used to disable most of these. This would
  # be mostly useful for servers.
  nushellConfig = ''
    ${builtins.readFile ./config.nu}

    ${optionalString config.garden.user.ssh-agent.enable sshAgent}
    ${optionalString cfg.enableStarship starship}
    ${optionalString cfg.enableZoxide zoxideConfig}

    ${mkSourceLineIf config.garden.user.hyprland.enable ./garden.nu}
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
