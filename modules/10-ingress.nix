# ---
# meta:
#   id: NIXH-10-ING-001
#   layer: 3
#   role: module
#   purpose: Spez-basierter Caddy-Ingress — ersetzt manuelle vHosts
#   lib:
#     - lib/caddy-ingress.nix
#     - lib/service-enable.nix
#   tags:
#     - caddy
#     - ingress
# ---
{ config, lib, ... }:

let
  caddy = import ../lib/caddy-helpers.nix { inherit lib; };
  vpnConnLib = import ../lib/vpn-connection.nix { inherit lib; };
  ingressLib = import ../lib/caddy-ingress.nix {
    inherit lib caddy;
    vpnConn = {
      cfg = config.my.services.vpn-confinement;
      connectionAddress = vpnConnLib.connectionAddress;
    };
  };
  enableMap = import ../lib/service-enable.nix { inherit lib; };

  domain = config.my.configs.identity.domain;
  cfg = config.my.ingress;
in
{
  options.my.ingress = {
    fromSpec = {
      enable = lib.mkEnableOption "Caddy vHosts aus my.services.spec generieren";
    };
    catchAll = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Wildcard-Catch-All (nicht unterstützt durch services.caddy.virtualHosts — optional via extraConfig).";
    };
  };

  config = lib.mkIf (config.services.caddy.enable && cfg.fromSpec.enable) {
    services.caddy.virtualHosts =
      let
        generated =
          ingressLib.genVirtualHosts {
            spec = config.my.services.spec;
            inherit domain;
            isEnabled = enableMap.enabled config;
            blockyMetricsPort = config.my.services.blocky.metricsPort or 4000;
          };
      in
      generated;
  };
}