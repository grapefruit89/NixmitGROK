# ---
# meta:
#   layer: 3
#   role: module
#   purpose: Readarr — eigene dendritische Datei
#   docs:
#     - docs/adr/007-dendritic-one-file-per-service.md
#   services:
#     - readarr
#   tags:
#     - media
#     - arr
#     - dendritic
# ---
{ config, lib, ... }:

let
  cfgReadarr = config.my.services.readarr;
  ports = config.my.ports;
  uids = config.my.users.registry;
  gids = config.my.groups.registry;
  arrHelper = import ./arr-helper.nix { inherit config lib; };

in
{
  config = lib.mkIf cfgReadarr.enable (arrHelper.mkArrService {
    name = "readarr";
    port = ports.readarr;
    dataDir = "/var/lib/readarr";
    uid = uids.readarr;
    gid = gids.readarr;
  });
}