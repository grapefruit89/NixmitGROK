# ---
# meta:
#   layer: 3
#   role: module
#   purpose: Jellyfin QuickSync + Jellyseerr hinter Caddy
#   docs:
#     - docs/memory_oom.md
#   lib:
#     - lib/memory-policy.nix
#   services:
#     - jellyfin
#     - seerr
#   tags:
#     - media
#     - jellyfin
# ---
{ config, lib, pkgs, ... }:

let
  caddy = import ../../lib/caddy-helpers.nix { inherit lib; };
  factory = import ../../lib/service-factory.nix { inherit lib; };
  memory = import ../../lib/memory-policy.nix { inherit lib; };
  cfgJellyfin = config.my.services.jellyfin;
  cfgJellyseerr = config.my.services.jellyseerr;
  domain = config.my.configs.identity.domain;
  dnsMap = import ../../lib/dns-map.nix { inherit domain; };
  portJellyfin = config.my.ports.jellyfin;
  portJellyseerr = config.my.ports.jellyseerr;

in
{
  config = lib.mkMerge [
    (lib.mkIf cfgJellyfin.enable (lib.mkMerge [
      {
        services.jellyfin = {
          enable = true;
          openFirewall = false;
        };

        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver
            intel-compute-runtime
            ocl-icd
          ];
        };

        users.users.jellyfin.extraGroups = [ "video" "render" "media" ];

        systemd.services.jellyfin.environment = {
          LIBVA_DRIVER_NAME = "iHD";
          LIBVA_DRIVERS_PATH = "${pkgs.intel-media-driver}/lib/dri";
          VDPAU_DRIVER = "va_gl";
          OCL_ICD_VENDORS = "${pkgs.intel-compute-runtime}/etc/OpenCL/vendors";
        };

        environment.systemPackages = with pkgs; [
          libva-utils
          intel-gpu-tools
        ];

        services.caddy.virtualHosts.${dnsMap.host "jellyfin"} = {
          extraConfig = ''
            import streamer_headers
            import security_headers

            @jellyfin_client header_regexp X-Emby-Authorization (?i)MediaBrowser

            handle @jellyfin_client {
              ${caddy.streamingBackend portJellyfin}
            }

            handle {
              import sso_auth
              ${caddy.streamingBackend portJellyfin}
            }
          '';
        };
      }
      (factory.mkStreamer {
        inherit config;
        name = "jellyfin";
        port = portJellyfin;
        useGPU = true;
        manageIngress = false;
        memoryPolicy = memory.jellyfin { };
        persistDirs = [
          "/var/lib/jellyfin"
          "/var/cache/jellyfin"
        ];
        readWritePaths = [
          "/var/lib/jellyfin"
          "/var/cache/jellyfin"
          "/run/jellyfin-transcode"
          "/mnt/fast_pool/cache/jellyfin"
          "/mnt/fast_pool/metadata/jellyfin"
          "/data/downloads"
        ];
        readOnlyPaths = [
          "/data/media"
          "${pkgs.intel-media-driver}/lib"
          "${pkgs.intel-compute-runtime}/lib"
          "/run/opengl-driver"
        ];
        extraSystemd = {
          IPAddressAllow = lib.mkForce [
            "127.0.0.0/8"
            "10.0.0.0/8"
            "192.168.0.0/16"
            "100.64.0.0/10"
          ];
          IPAddressDeny = lib.mkForce "any";
        };
      })
    ]))

    (lib.mkIf cfgJellyseerr.enable (lib.mkMerge [
      {
        services.seerr = {
          enable = true;
          port = portJellyseerr;
          openFirewall = false;
        };
      }
      (factory.mkService {
        inherit config;
        name = "seerr";
        port = portJellyseerr;
        mode = "sso";
        persistDirs = [ "/var/lib/seerr" ];
        readWritePaths = [ "/var/lib/seerr" ];
      })
    ]))
  ];
}
