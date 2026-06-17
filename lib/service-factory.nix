# ---
# meta:
#   id: NIXH-05-LIB-002
#   layer: 5
#   role: lib
#   purpose: mkService — systemd-Hardening + Caddy-Ingress aus dns-map
#   docs:
#     - docs/SPEC_REGISTRY.md
#     - modules/60-apps/SERVICE_TEMPLATE.nix
#   lib:
#     - lib/dns-map.nix
#     - lib/caddy-helpers.nix
#   tags:
#     - factory
#     - caddy
#     - systemd
# ---
{ lib }:

let
  caddy = import ./caddy-helpers.nix { inherit lib; };

  systemdHardening =
    {
      readWritePaths ? [ ],
      privateDevices ? true,
      profile ? "full", # full | dotnet | node
      extra ? { },
    }:
    let
      # .NET/Node crashen mit ~@resources oder leerem CapabilityBoundingSet (fchown → SYS)
      base =
        {
          ProtectSystem = lib.mkForce "strict";
          ProtectHome = lib.mkForce true;
          PrivateTmp = lib.mkForce true;
          PrivateDevices = lib.mkForce privateDevices;
          NoNewPrivileges = lib.mkForce true;
          ProtectKernelTunables = lib.mkForce true;
          ProtectKernelModules = lib.mkForce true;
          ProtectControlGroups = lib.mkForce true;
          RestrictRealtime = lib.mkForce true;
          RestrictSUIDSGID = lib.mkForce true;
          LockPersonality = lib.mkForce true;
          RestrictAddressFamilies = lib.mkForce [ "AF_INET" "AF_INET6" "AF_UNIX" ];
          ReadWritePaths = readWritePaths;
        }
        // lib.optionalAttrs (profile == "full") {
          CapabilityBoundingSet = lib.mkForce "";
          DevicePolicy = lib.mkForce "closed";
          SystemCallFilter = lib.mkForce [ "@system-service" "~@privileged" "~@resources" ];
        }
        // lib.optionalAttrs (profile == "dotnet") {
          SystemCallFilter = lib.mkForce [ "@system-service" "~@privileged" ];
        };
    in
    lib.mkMerge [ base extra ];

  mkCaddyExtra =
    {
      mode ? "sso",
      port ? null,
      socketPath ? null,
      upstreamHost ? "127.0.0.1",
      extra ? "",
    }:
    let
      proxy =
        if socketPath != null then
          {
            sso = caddy.proxyUnixSso socketPath;
            "tailscale-sso" = caddy.proxyUnixTailscaleSso socketPath;
            security = caddy.proxyUnixSecurity socketPath;
            direct = caddy.proxyUnixDirect socketPath;
          }
        else if port != null then
          {
            sso = caddy.proxySso port;
            "tailscale-sso" = caddy.proxyTailscaleSso port;
            security = caddy.proxySecurity port;
            direct = caddy.proxyDirect port;
            streaming = ''
              import streamer_headers
              import security_headers
              import sso_auth
              ${caddy.streamingBackend port}
            '';
          }
        else
          throw "mkCaddyExtra: port oder socketPath erforderlich";
    in
    (if builtins.hasAttr mode proxy then proxy.${mode} else throw "mkCaddyExtra: unbekannter mode '${mode}'")
    + lib.optionalString (extra != "") "\n${extra}";

in
{
  inherit systemdHardening mkCaddyExtra;

  mkService =
    {
      config,
      name,
      port ? null,
      socketPath ? null,
      host ? null,
      mode ? "sso",
      upstreamHost ? "127.0.0.1",
      readWritePaths ? [ ],
      privateDevices ? true,
      hardeningProfile ? "full",
      memoryPolicy ? null,
      extraSystemd ? { },
      extraCaddy ? "",
      caddyOnly ? false,
    }:
    let
      domain = config.my.configs.identity.domain;
      dnsMap = import ./dns-map.nix { inherit domain; };
      vhost = if host != null then host else dnsMap.host name;
      caddyExtra = mkCaddyExtra {
        inherit mode port socketPath upstreamHost;
        extra = extraCaddy;
      };
    in
    lib.mkMerge [
      (lib.mkIf (!caddyOnly) {
        systemd.services.${name}.serviceConfig = lib.mkMerge (
          [
            (systemdHardening {
              inherit readWritePaths privateDevices;
              profile = hardeningProfile;
            })
          ]
          ++ lib.optional (memoryPolicy != null) memoryPolicy
          ++ [ extraSystemd ]
        );
      })
      {
        services.caddy.virtualHosts.${vhost} = {
          extraConfig = caddyExtra;
        };
      }
    ];
}