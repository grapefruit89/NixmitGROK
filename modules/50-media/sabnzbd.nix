# ---
# meta:
#   layer: 3
#   role: module
#   purpose: SABnzbd Usenet mit VPN-Kill-Switch
#   docs:
#     - docs/memory_oom.md
#   lib:
#     - lib/memory-policy.nix
#     - lib/vpn-killswitch.nix
#   services:
#     - sabnzbd
#   tags:
#     - media
#     - usenet
# ---
{ config, lib, ... }:

let
  caddy = import ../../lib/caddy-helpers.nix { inherit lib; };
  memory = import ../../lib/memory-policy.nix { inherit lib; };
  vpnConn = import ../../lib/vpn-connection.nix { inherit lib; };
  cfgSabnzbd = config.my.services.sabnzbd;
  vpnCfg = config.my.services.vpn-confinement;
  domain = config.my.configs.identity.domain;
  portSabnzbd = config.my.ports.sabnzbd;
  uids = config.my.users.registry;
  gids = config.my.groups.registry;
  sabUpstream = vpnConn.connectionAddress vpnCfg "sabnzbd";
  sabInVpn = vpnConn.isVpnConfined vpnCfg "sabnzbd";
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
          host = if sabInVpn then "0.0.0.0" else "127.0.0.1";
        };
      };
    };

    # GID/UID und Gruppen-Anpassung
    users = {
      groups = {
        media = { };
        sabnzbd.gid = lib.mkDefault gids.sabnzbd;
      };
      users.sabnzbd = {
        uid = lib.mkDefault uids.sabnzbd;
        extraGroups = [ "media" ];
      };
    };

    systemd.services.sabnzbd = lib.mkMerge [
      (lib.mkIf (!(config.my.services.vpn-confinement.enable or false)) vpnKillSwitch)
      {
        serviceConfig = lib.mkMerge [
          (memory.sabnzbd { })
          {
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
          }
        ];
      }
    ];

    services.caddy.virtualHosts."sabnzbd.${domain}" = lib.mkIf (!(config.my.ingress.fromSpec.enable or false)) {
      extraConfig = caddy.proxyTailscaleSso { port = portSabnzbd; host = sabUpstream; };
    };
  };
}
