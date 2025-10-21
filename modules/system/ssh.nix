{ config, lib, ... }:
let
  cfg = config.garden.services.ssh;
in
{
  options.garden.services.ssh = {
    enable = lib.mkEnableOption "ssh";
  };

  config = {
    # TODO: SSH hardening.
    services.openssh.enable = cfg.enable;
    networking.firewall.allowedTCPPorts = lib.lists.optional cfg.enable 22;
  };
}
