
# arr-helper.nix
# Shared helper to generate standardized *Arr services.
{ config, lib, ... }:

let
  caddy = import ../../lib/caddy-helpers.nix { inherit lib; };
  vpnKillSwitchAttrs = import ../../lib/vpn-killswitch.nix {
    inherit lib;
    privadoEnabled = config.my.services.privado-vpn.enable or false;
  };
in
{
  mkArrService = { name, port, dataDir, uid, gid, useVpnKillSwitch ? false }: {
    services.${name} = {
      enable = true;
      openFirewall = false;
      inherit dataDir;
    };

    users.groups.${name} = {
      gid = lib.mkDefault gid;
    };
    users.users.${name} = {
      uid = lib.mkDefault uid;
      group = name;
      isSystemUser = true;
      extraGroups = [ "media" ];
    };

    systemd.services.${name} = lib.mkMerge [
      (lib.mkIf useVpnKillSwitch vpnKillSwitchAttrs)
      {
        serviceConfig = {
          ProtectSystem = lib.mkForce "strict";
          ProtectHome = lib.mkForce true;
          PrivateTmp = lib.mkForce true;
          PrivateDevices = lib.mkForce true;
          NoNewPrivileges = lib.mkForce true;
          UMask = lib.mkForce "0002";
          ReadWritePaths = [
            dataDir
            "/data/media"
            "/data/downloads"
          ];
        };
      }
    ];

    services.caddy.virtualHosts."${name}.${config.my.configs.identity.domain}" = {
      extraConfig = caddy.proxySso port;
    };
  };
}
