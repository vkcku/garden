{
  garden,
  pkgs,
  hjem,
  ...
}:
{
  # keep-sorted start block=yes newline_separated=yes
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  garden = {
    user.nushell.enable = true;
    user.helix.enable = true;
    user.git.enable = true;
  };

  hjem = {
    clobberByDefault = true;
    linker = hjem.packages.${pkgs.stdenv.hostPlatform.system}.smfh;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  imports = [
    ../modules
    ./profiles/server.nix
    ./profiles/daily-use.nix
  ];

  nix = {
    # keep-sorted start block=yes newline_separated=yes
    gc = {
      automatic = true;
      dates = "weekly";
      # Keep the last 10 generations.
      options = "--delete-older-than +10";
      persistent = true;
    };

    optimise = {
      automatic = true;
      dates = "daily";
      persistent = true;
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    # keep-sorted end
  };

  sops = {
    # keep-sorted start block=yes newline_separated=yes
    age.keyFile = "/var/lib/sops-nix/key.txt";

    defaultSopsFile = "${garden.secrets.secretsFile}";

    secrets."passwords/vkcku" = {
      neededForUsers = true;
    };
    # keep-sorted end
  };

  users = {
    mutableUsers = false;

    # Disable root user.
    users.root.hashedPassword = "!";
  };

  # keep-sorted end
}
