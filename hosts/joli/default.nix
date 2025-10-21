{ garden, ... }:
let
  secrets = garden.secrets.joli;
in
{
  # keep-sorted start block=yes newline_separated=yes
  garden = {
    profile = "daily-use";

    # TODO: Turn off SSH.
    services.ssh.enable = true;

    user.git = {
      email = secrets.git.email;
      username = secrets.git.name;

      includes = {
        "gitdir:~/projects/personal/" = {
          user.name = "vkcku";
          user.email = garden.lib.mkEmail {
            local = "git";
            domain = "mail.vkcku";
          };
        };
      };
    };
  };

  imports = [
    ../common.nix
    ./disk.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "joli";

  # DO NOT MODIFY.
  system.stateVersion = "25.11";

  time.timeZone = "Asia/Kolkata";
  # keep-sorted end
}
