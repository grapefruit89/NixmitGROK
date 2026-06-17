# ---
# meta:
#   layer: 3
#   role: module
#   purpose: Prowlarr — VPN-NetNS, eigene dendritische Datei
#   docs:
#     - docs/adr/007-dendritic-one-file-per-service.md
#   services:
#     - prowlarr
#   tags:
#     - media
#     - arr
#     - dendritic
#     - vpn
# ---
{ config, lib, ... }:

let
  cfgProwlarr = config.my.services.prowlarr;
  vpnCfg = config.my.services.vpn-confinement;
  vpnConn = import ../../lib/vpn-connection.nix { inherit lib; };
  ports = config.my.ports;
  uids = config.my.users.registry;
  gids = config.my.groups.registry;
  arrHelper = import ./arr-helper.nix { inherit config lib; };
  prowlarrUpstream = vpnConn.connectionAddress vpnCfg "prowlarr";

in
{
  config = lib.mkIf cfgProwlarr.enable (arrHelper.mkArrService {
    name = "prowlarr";
    port = ports.prowlarr;
    dataDir = "/var/lib/prowlarr";
    uid = uids.prowlarr;
    gid = gids.prowlarr;
    useVpnKillSwitch = true;
    upstreamHost = prowlarrUpstream;
  });
}