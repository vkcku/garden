{
  config,
  lib,
  pkgs,
  garden,
  ...
}:
let
  cfg = config.garden.user.ssh-agent;
  enable = config.garden.user.enable && cfg.enable;
in
{
  options.garden.user.ssh-agent = {
    enable = lib.options.mkEnableOption "ssh-agent";
    timeout = lib.options.mkOption {
      type = lib.types.str;
      default = "2h";
      description = "The timeout for the SSH keys to be kept in memory.";
    };
  };

  config = lib.mkIf enable {
    systemd.user.services.garden-ssh-agent = {
      enable = true;
      wantedBy = [ "default.target" ];
      description = "SSH Agent";
      unitConfig = {
        ConditionUser = "${garden.username}";
      };
      serviceConfig = {
        Type = "exec";
        # '%t' is the `$XDG_RUNTIME_DIR`.
        ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent.sock -t ${cfg.timeout}";
        Restart = "on-failure";
      };
    };
  };
}
