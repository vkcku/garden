{
  config,
  lib,
  garden,
  pkgs,
  ...
}:
let
  cfg = config.garden.user;

  enabled = lib.asserts.assertMsg cfg.enable "garden: the 'garden.user' option MUST be enabled";
in
{
  options.garden.user = {
    # NOTE: This is made into an option just for completeness sake. It actually is
    # not an "option" since this user HAS to be enabled for the flake to even build.
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable the main user.";
    };
  };

  config = lib.mkIf enabled {
    # keep-sorted start block=yes newline_separated=yes
    nix.settings.trusted-users = [ garden.username ];

    users.groups."${garden.username}" = { };

    users.users."${garden.username}" = {
      # keep-sorted start block=yes newline_separated=yes
      createHome = true;

      extraGroups = [
        "networkmanager"
        "wheel"
      ];

      group = garden.username;

      hashedPasswordFile = "${config.sops.secrets."passwords/vkcku".path}";

      isNormalUser = true;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuPo1QoCFCyPPSmx0ZvKVvE4K/hQonR3zjrJlGKZnYv personal-laptop"
      ];

      shell = pkgs.nushell;
      # keep-sorted end
    };
    # keep-sorted end
  };
}
