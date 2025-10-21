{
  config,
  lib,
  garden,
  ...
}:
let
  cfg = config.garden.user.zen-browser;
  enable = config.garden.user.enable && cfg.enable;

  policies =
    let
      transformExt = ext: {
        name = ext.id;
        value = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${ext.id}/latest.xpi";
          updates_disabled = false;
          temporarily_allow_weak_signatures = false;
          private_browsing = false;
          # Pin the extension. Other option is "menupanel".
          default_area = "navbar";
        }
        // builtins.removeAttrs ext [ "id" ];
      };
      mkExtensionSettings = extensions: builtins.listToAttrs (builtins.map transformExt extensions);
    in
    {
      # keep-sorted start block=yes
      AutoAppUpdate = false;
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      Cookies = {
        Behavior = "reject-tracker-and-partition-foreign";
        BehaviorPrivateBrowsing = "reject-tracker-and-partition-foreign";
        Locked = true;
      };
      DNSOverHTTPS = {
        Enabled = true;
        # Need to fallback when connecting over tailscale.
        Fallback = false;
        Locked = true;
        # This can be used for excluding my homelab.
        ExcludedDomains = [
          # "example.com"
        ];
      };
      DefaultDownloadDirectory = "${config.users.users."${garden.username}".home}/Downloads";
      DisableFirefoxAccounts = true;
      DisableProfileImport = true;
      DisableTelemetry = true;
      DisplayBookmarksToolbar = "newtab";
      DontCheckDefaultBrowser = true;
      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
        SuspectedFingerprinting = true;
        Category = "strict";
      };
      ExtensionSettings = mkExtensionSettings [
        # proton pass
        {
          id = "78272b6fa58f4a1abaac99321d503a20@proton.me";
        }
        # proton VPN
        {
          id = "vpn@proton.ch";
          private_browsing = true;
        }
      ];
      HardwareAcceleration = true;
      HttpsOnlyMode = "force_enabled";
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;
      PostQuantumKeyAgreementEnabled = true;
      Preferences =
        let
          mkLocked =
            attrs:
            lib.attrsets.mapAttrs (_: value: {
              Value = value;
              Status = "locked";
            }) attrs;
        in
        # REFERENCE: https://searchfox.org/firefox-main/source/modules/libpref/init/StaticPrefList.yaml
        mkLocked { "browser.tabs.warnOnClose" = false; };
      SearchEngines.Default = "DuckDuckGo";
      WebsiteFilter = {
        Block = [
          "*://*.reddit.com/*"
        ];
      };
      # keep-sorted end
    };

  # TODO: Configure the containers etc.
in
{
  options.garden.user.zen-browser = {
    enable = lib.mkEnableOption "zen-browser";
  };

  config = lib.mkIf enable {
    garden.user.packages =
      let
        zen = garden.packages.zen-browser.override {
          inherit policies;
        };
      in
      [ zen ];
  };
}
