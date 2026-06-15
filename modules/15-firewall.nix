
# ==============================================================================
# PURPOSE
# ==============================================================================
# Reine nftables-L4-Firewall: Geo, Rate-Limits, SYN-Schutz, CrowdSec-Sets.
# Geo/ASN NIEMALS in Caddy — eine Wahrheit hier im Kernel.
#
# Hinweis Cloudflare orange cloud: saddr = CF-Edge-IP → L4-Geo wirkungslos.
# Für Geo entweder DNS-only (graue Wolke) oder CF Firewall Rules am Edge.

{ config, pkgs, lib, ... }:

let
  cfg = config.my.security.firewall;
  sshPort = config.my.ports.ssh;
  lanIP = config.my.configs.server.lanIP;
  sshPorts =
    (if config.my.mode == "development" then [ 22 ] else [ sshPort ])
    ++ lib.optional (
      (config.my.security ? dropbear-rescue) && config.my.security.dropbear-rescue.enable
    ) config.my.security.dropbear-rescue.port;

  lanCidrList = lib.concatStringsSep ", " cfg.lanCidrs;
  blockedCountryList = lib.concatStringsSep " " cfg.blockedCountries;

in
{
  options.my.security.firewall = {
    enable = lib.mkEnableOption "nftables L4 firewall (ersetzt networking.firewall)";

    lanCidrs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "192.168.0.0/16" "10.0.0.0/8" "172.16.0.0/12" ];
      description = "Vertrauenswürdige LAN-CIDRs — vor Geo-Block akzeptiert.";
    };

    blockedCountries = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "cn" "ru" "kp" "ir" "sy" "vn" ];
      description = "ISO-Ländercodes für ipdeny.com → geoip_blocked Set (Blocklist).";
    };

    allowLanDns = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "UDP/TCP 53 von LAN an Blocky erlauben (DHCP DNS → q958).";
    };

    webRateLimit = lib.mkOption {
      type = lib.types.str;
      default = "100/minute";
      description = "Neue HTTP/HTTPS-Verbindungen pro Quell-IP (WAN).";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.enable = false;

    networking.nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          set geoip_blocked {
            type ipv4_addr
            flags interval
          }

          set crowdsec_blocked_ipv4 {
            type ipv4_addr
            flags interval
          }

          set crowdsec_blocked_ipv6 {
            type ipv6_addr
            flags interval
          }

          set ssh_meter {
            type ipv4_addr
            flags dynamic, timeout
            timeout 1m
          }

          set web_meter {
            type ipv4_addr
            flags dynamic, timeout
            timeout 1m
          }

          chain input {
            type filter hook input priority filter; policy drop;

            # Trusted paths (vor Geo/Rate)
            iifname lo accept
            iifname tailscale0 accept comment "Tailscale"
            iifname privado accept comment "Privado WG egress"

            ct state established,related accept
            ct state invalid drop comment "Invalid TCP state"

            ip frag-off & 0x3fff != 0 drop comment "Fragments"

            # LAN: voller Zugang (Apps, Jellyfin, Blocky-DNS) — kein Geo
            ip saddr { ${lanCidrList} } accept comment "LAN trusted"

            # WAN: Geo-Block (nur öffentliche IPs, LAN bereits oben)
            ip saddr @geoip_blocked drop comment "Geo blocklist"

            ip saddr @crowdsec_blocked_ipv4 drop comment "CrowdSec IPv4"
            ip6 saddr @crowdsec_blocked_ipv6 drop comment "CrowdSec IPv6"

            icmp type echo-request limit rate over 10/second drop
            icmp type echo-request accept
            icmp type { redirect, router-advertisement } drop
            ip protocol icmp accept

            tcp flags & (syn|rst|ack) == syn limit rate over 20/second burst 40 packets drop comment "SYN flood"

            udp dport ${toString config.my.services.tailscale.port} accept comment "Tailscale UDP"

            ${lib.optionalString cfg.allowLanDns ''
            udp dport 53 ip saddr { ${lanCidrList} } accept comment "Blocky DNS LAN"
            tcp dport 53 ip saddr { ${lanCidrList} } accept comment "Blocky DNS LAN TCP"
            ''}

            tcp dport { 80, 443 } ct state new update @web_meter { ip saddr limit rate over ${cfg.webRateLimit} } drop
            tcp dport { 80, 443 } accept

            tcp dport { ${lib.concatStringsSep ", " (map toString sshPorts)} } ct state new update @ssh_meter { ip saddr limit rate over 10/minute } drop
            tcp dport { ${lib.concatStringsSep ", " (map toString sshPorts)} } accept

            limit rate 5/second log prefix "nftables-dropped: "
          }

          chain forward {
            type filter hook forward priority filter; policy drop;
            iifname tailscale0 accept
            oifname tailscale0 accept
          }

          chain output {
            type filter hook output priority filter; policy accept;
          }
        }
      '';
    };

    systemd.services.nftables-geoip-update = {
      description = "Geo-IP blocklist → nftables set geoip_blocked";
      after = [ "network-online.target" "nftables.service" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "update-geoip" ''
          set -euo pipefail
          TEMP_DIR=$(mktemp -d)
          trap 'rm -rf "$TEMP_DIR"' EXIT
          IP_FILE="$TEMP_DIR/ips.txt"
          touch "$IP_FILE"
          for country in ${blockedCountryList}; do
            URL="https://www.ipdeny.com/ipblocks/data/countries/$country.zone"
            echo "Fetching $country..."
            ${pkgs.curl}/bin/curl --ssl-reqd -fsS -o "$TEMP_DIR/$country.zone" "$URL" \
              && cat "$TEMP_DIR/$country.zone" >> "$IP_FILE" \
              || echo "WARN: skip $country"
          done
          ${pkgs.gnugrep}/bin/grep -v -E '^\s*(#|$)' "$IP_FILE" > "$TEMP_DIR/clean_ips.txt" || true
          if [ ! -s "$TEMP_DIR/clean_ips.txt" ]; then
            echo "ERROR: no subnets fetched"
            exit 1
          fi
          NFT_FILE="$TEMP_DIR/rules.nft"
          echo "flush set inet filter geoip_blocked" > "$NFT_FILE"
          echo "add element inet filter geoip_blocked {" >> "$NFT_FILE"
          paste -sd, "$TEMP_DIR/clean_ips.txt" >> "$NFT_FILE"
          echo "}" >> "$NFT_FILE"
          ${pkgs.nftables}/bin/nft -f "$NFT_FILE"
          echo "geoip_blocked updated ($(wc -l < "$TEMP_DIR/clean_ips.txt") prefixes)"
        '';
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
      };
    };

    systemd.timers.nftables-geoip-update = {
      description = "Weekly Geo-IP refresh";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "7d";
        RandomizedDelaySec = "1h";
      };
    };
  };
}