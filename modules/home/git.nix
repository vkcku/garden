{
  config,
  lib,
  pkgs,
  garden,
  ...
}:
let
  inherit (lib.generators) toGitINI;

  cfg = config.garden.user.git;
  enable = config.garden.user.enable && cfg.enable;

  /**
    Write the given config to the nix store and return the derivation.
  */
  writeGitConfig = name: value: pkgs.writeText name (toGitINI value);

  /**
    Convert from
      `{ "key = gitConfig; }`
    to
      `{ "includeIf"."${key}" = { path = <path to gitConfig written in store>; } }`
  */
  mkIncludesIf =
    includes:
    let
      includeIfSubSections = lib.attrsets.mapAttrs (_: gitConfig: {
        path = writeGitConfig "git-config-includes" gitConfig;
      }) includes;
    in
    {
      includeIf = includeIfSubSections;
    };

  gitConfig = {
    #
    # Basic configurations.
    #

    core.editor = "hx";
    init.defaultBranch = "main";
    user = {
      email = cfg.email;
      name = cfg.username;
    };

    #
    # Aliases
    #
    alias = {
      # keep-sorted start
      "logs" = "log main..";
      "logso" = "log --oneline main..";
      "pf" = "push --force-with-lease";
      "st" = "status --short";
      # keep-sorted end
    };

    #
    # Signing
    #
    commit.gpgSign = true;
    gpg = {
      format = "ssh";
      "ssh".program = "${pkgs.openssh}/bin/ssh-keygen";
    };
    tag.gpgSign = true;
    user.signingKey = "~/.ssh/id_ed25519.pub";

    #
    # Diffs, reviews, PRs etc.
    #

    commit.verbose = true;
    core = {
      # Show the whitespace properly in diffs. Generally, this should be taken
      # care of by formatters etc, but just in case.
      whitespace = "trailing-space";
      pager = "${pkgs.delta}/bin/delta";
    };

    delta = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      hyperlinks = true;
    };

    diff = {
      # Modern diff algorithm that handles moving code blocks around much
      # better.
      algorithm = "histogram";
      mnemonicPrefix = true;

      # Detect copies and renames in `git diff`.
      renames = "copy";
    };

    interactive.diff-filter = "${pkgs.delta}/bin/delta --color-only";

    merge.conflictStyle = "zdiff3";

    # Remember how merge conflicts were resolved.
    rerere = {
      enabled = true;
      autoUpdate = true;
    };

    #
    # Fetching/status checks etc.
    #
    fetch.prune = true;

    push = {
      default = "simple"; # Already the default since v2.

      # Automatically track remote branch with the same name.
      autoSetupRemote = true;

      # Push tags to remote automatically.
      followTags = true;
    };

    rebase = {
      autosquash = true;
      # REFERENCE: https://andrewlock.net/working-with-stacked-branches-in-git-is-easier-with-update-refs/
      updaterefs = true;
    };

    #
    # CLI stuff
    #

    # Show the branches sorted by last commit timestamp in descending order.
    branch.sort = "=committerdate";
    help.autocorrect = "prompt";
    # Sort the tags reasonably based on the version rather than alphanumerically.
    #
    # NOTE: I have no idea what this actually means, but only what it does.
    tag.refname = "-version:refname";

    #
    # Mmaintenance etc.
    #

    core = {
      fsmonitor = true;
      # Reduce size for more CPU (more than disk, this may help in network transfers due
      # to smaller size). Or at least that is the reasoning. I haven't actually tested
      # this.
      compression = 9;
    };

    maintenance = {
      auto = true;
      strategy = "incremental";
    };

    transfer.fsckobjects = true;

    #
    # GitHub integration.
    #

    # Example: `git clone gh:<owner>/<repo>`.
    url."git@github.com:".insteadOf = "gh:";
    url."git@gitlab.com:".insteadOf = "gl:";
  };
in
{
  options.garden.user.git = {
    enable = lib.mkEnableOption "git";

    email = lib.options.mkOption {
      type = lib.types.str;
      default = garden.lib.mkEmail {
        local = "git";
        domain = "mail.vkcku";
      };
      example = "foobar@example.com";
      description = "The email for git.";
    };

    username = lib.options.mkOption {
      type = lib.types.str;
      default = "vkcku";
      description = "The username for git.";
    };

    # Includes i.e. `includeIf` have to be handled separately so that they are included
    # at the end of the config since `git` loads the configurations when it sees them
    # immediately.
    #
    # The keys must are the `includeIf` subsection i.e. `[includeIf "<key>"]` while
    # the values are the git configurations to apply. The value will be written to
    # a file in the nix store that will then be set to the `path` value.
    includes = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
      description = "The `includeIf` directives to include in the final git config.";
    };
  };

  config = lib.mkIf enable {
    garden.user.packages = [ pkgs.git ];

    garden.user.git.includes = { };

    garden.user.configFiles = {
      "git/config" =
        let
          includesIf = mkIncludesIf cfg.includes;
        in
        (toGitINI gitConfig) + "\n" + (toGitINI includesIf);
    };
  };
}
