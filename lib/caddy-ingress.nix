# ---
# meta:
#   id: NIXH-05-LIB-010
#   layer: 5
#   role: lib
#   purpose: Caddy vHost-Generator aus my.services.spec (Zonen-Policy)
#   docs:
#     - docs/ROADMAP.md
#   tags:
#     - caddy
#     - ingress
# ---
{ lib, caddy, vpnConn ? null }:

let
  vpnUpstream =
    name: entry:
    if vpnConn == null then
      mkUpstream entry
    else if lib.elem name [ "sabnzbd" "prowlarr" ] then
      "${vpnConn.connectionAddress vpnConn.cfg name}:${toString entry.port}"
    else
      mkUpstream entry;
  streamingSubdomains = [
    "jellyfin"
    "audiobookshelf"
  ];

  mkUpstream =
    entry:
    if entry.socket or null != null then
      "unix/${entry.socket}"
    else
      "127.0.0.1:${toString entry.port}";

  mkFqdn = domain: entry: "${entry.subdomain}.${domain}";

  genAuthVhost = upstream: ''
    import security_headers
    handle /api/auth/* {
      reverse_proxy ${upstream}
    }
    handle /.well-known/* {
      reverse_proxy ${upstream}
    }
    handle /admin/* {
      import tailscale_admin
      reverse_proxy ${upstream}
    }
    handle {
      import sso_auth
      reverse_proxy ${upstream}
    }
  '';

  genZoneVhost =
    {
      zone,
      upstream,
      subdomain,
    }:
    if zone == "admin-hangar" then
      ''
        import tailscale_admin
        import security_headers
        reverse_proxy ${upstream}
      ''
    else if zone == "public" then
      ''
        import security_headers
        reverse_proxy ${upstream}
      ''
    else if zone == "family-pocketid" && lib.elem subdomain streamingSubdomains then
      ''
        import streamer_headers
        import security_headers
        import sso_auth
        reverse_proxy ${upstream} {
          flush_interval -1
          transport http {
            read_buffer 0
            keepalive off
          }
        }
      ''
    else if zone == "family-pocketid" then
      ''
        import security_headers
        import sso_auth
        reverse_proxy ${upstream}
      ''
    else
      throw "caddy-ingress: zone '${zone}' hat keinen Ingress";

  # Jellyfin Client-Split bleibt in jellyfin.nix (manualHosts)
  manualHosts = [
    "jellyfin"
    "vaultwarden"
  ];

  genVirtualHosts =
    {
      spec,
      domain,
      isEnabled,
      blockyMetricsPort,
    }:
    let
      ingress =
        lib.filterAttrs (
          name: entry:
          (entry.subdomain or null) != null
          && (entry.zone != "loopback")
          && !(lib.elem name manualHosts)
          && isEnabled name
        ) spec;

      mkHost = name: entry:
        let
          upstream =
            if name == "blocky" then
              "127.0.0.1:${toString blockyMetricsPort}"
            else
              vpnUpstream name entry;
          fqdn = mkFqdn domain entry;
          extraConfig =
            if name == "pocket-id" then
              genAuthVhost upstream
            else
              genZoneVhost {
                zone = entry.zone;
                inherit upstream;
                subdomain = entry.subdomain;
              };
        in
        lib.nameValuePair fqdn { inherit extraConfig; };

    in
    lib.listToAttrs (lib.mapAttrsToList mkHost ingress);

in
{
  inherit genVirtualHosts manualHosts streamingSubdomains;
}