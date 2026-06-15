
{ config, lib, ... }:

let
  cfgSabnzbd = config.my.services.sabnzbd;
  domain = config.my.configs.identity.domain;
  portSabnzbd = config.my.ports.sabnzbd;
  vpnKillSwitch = import ../../lib/vpn-killswitch.nix {
    inherit lib;
    privadoEnabled = config.my.services.privado-vpn.enable or false;
  };

in
{
  config = lib.mkIf cfgSabnzbd.enable {
    services.sabnzbd = {
      enable = true;
      openFirewall = false;
      configFile = null;
      allowConfigWrite = true;
      settings = {
        misc = {
          port = portSabnzbd;
          host = "127.0.0.1";
        };
      };
    };

    # GID/UID und Gruppen-Anpassung
    users = {
      groups = {
        media = { };
        sabnzbd.gid = lib.mkDefault 194;
      };
      users.sabnzbd = {
        uid = lib.mkDefault 984;
        extraGroups = [ "media" ];
      };
    };

    systemd.services.sabnzbd = lib.mkMerge [
      vpnKillSwitch
      {
        serviceConfig = {
          ProtectSystem = lib.mkForce "strict";
          ProtectHome = lib.mkForce true;
          PrivateTmp = lib.mkForce true;
          PrivateDevices = lib.mkForce true;
          NoNewPrivileges = lib.mkForce true;
          UMask = "0002";
          RuntimeDirectory = "sabnzbd-tmp";
          RuntimeDirectoryMode = "0700";
          ReadWritePaths = [
            "/var/lib/sabnzbd"
            "/data/downloads"
            "/run/sabnzbd-tmp"
          ];
        };
      }
    ];

    services.caddy.virtualHosts."sabnzbd.${domain}" = {
      extraConfig = ''
        import tailscale_admin
        import sso_auth
        reverse_proxy 127.0.0.1:${toString portSabnzbd}
      '';
    };
  };
}
