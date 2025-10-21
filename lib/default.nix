{ lib }:
{
  /**
    Return a list of the imports from the given directory.

    This will not include the following:
      - a file called `default.nix`
      - any directory that does not contain a `default.nix` itself
      - it will not traverse all directories recursively
  */
  getImports =
    path:
    let
      isImport =
        name: type:
        if type == "regular" then
          (lib.strings.hasSuffix ".nix" name && name != "default.nix")
        else if (type == "directory") then
          let
            dir = lib.path.append path name;
            defaultPath = lib.path.append dir "default.nix";
          in
          builtins.pathExists defaultPath
        else
          false;
    in
    builtins.map (f: lib.path.append path f) (
      builtins.attrNames (lib.attrsets.filterAttrs isImport (builtins.readDir path))
    );
}
