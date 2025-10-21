{ lib, ... }:
{
  options.garden = {
    # Profile is a way to group hosts of similar use cases. This allows for having
    # common configurations that can be shared across hosts of the same profile. For
    # example, all server hosts should have the time zone set to `UTC`. Instead of
    # having to set for each host, it can be set in the profile configurations.
    #
    # The profile specific configurations can be seen in `hosts/profiles/*.nix`.
    profile = lib.mkOption {
      type = lib.types.enum [
        "server"
        "daily-use"
      ];
      description = "The profile of the host.";
    };
  };
}
