{
  config,
  lib,
  garden,
  pkgs,
  ...
}:
let
  cfg = config.garden.user;
in
{
  imports = garden.lib.getImports ./.;

  options.garden.user = {
    /**
      An attreset of files to be added to `$XDG_CONFIG_HOME`. The keys must be
      filepaths that are considered to be relative to `$XDG_CONFIG_HOME`.

      If the value is a string, then it is considered to be the raw contents of the
      file to add.
    */
    configFiles = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.str
          lib.types.path
        ]
      );
      default = { };
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "The packages to install for the user.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users."${garden.username}".packages = cfg.packages;

    hjem.users."${garden.username}" = {
      enable = true;

      xdg.config.files =
        let
          /**
            Given a path or a string, return the final path to the file. If it is a
            string, it is written to a file in the store and that path is returned.

            NOTE: It is guaranteed that the type is a string or a path since the types
            for configFiles is set that way in the module options.
          */
          mkPath =
            filename: pathOrString:
            if (builtins.isString pathOrString) then (pkgs.writeText filename pathOrString) else pathOrString;

          /**
            Convert from
              `{ "filename": ./path-to-file }`
            into
              `{ "filename".source = ./path-to-file }`
          */
          mkHjemFiles = files: lib.attrsets.mapAttrs (name: path: { source = (mkPath name path); }) files;
        in
        (mkHjemFiles cfg.configFiles);
    };
  };
}
