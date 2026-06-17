# ---
# meta:
#   layer: 3
#   role: module
#   purpose: Sonarr + Radarr — gemeinsame dendritische Datei
#   docs:
#     - docs/adr/007-dendritic-one-file-per-service.md
#     - docs/guides/GUIDE-dendritic-architecture.md
#   services:
#     - sonarr
#     - radarr
#   tags:
#     - media
#     - arr
#     - dendritic
# ---
{ config, lib, ... }:

let
  cfgSonarr = config.my.services.sonarr;
  cfgRadarr = config.my.services.radarr;
  ports = config.my.ports;
  uids = config.my.users.registry;
  gids = config.my.groups.registry;
  arrHelper = import ./arr-helper.nix { inherit config lib; };

in
{
  config = lib.mkMerge [

    (lib.mkIf cfgSonarr.enable (arrHelper.mkArrService {
      name = "sonarr";
      port = ports.sonarr;
      dataDir = "/var/lib/sonarr";
      uid = uids.sonarr;
      gid = gids.sonarr;
    }))

    (lib.mkIf cfgRadarr.enable (arrHelper.mkArrService {
      name = "radarr";
      port = ports.radarr;
      dataDir = "/var/lib/radarr";
      uid = uids.radarr;
      gid = gids.radarr;
    }))

  ];
}