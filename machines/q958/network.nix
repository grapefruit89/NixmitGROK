# q958 — Netzwerk-Verdrahtung aus profile.nix (keine Keys, keine Widersprüche)
{ config, lib, ... }:

let
  p = import ./profile.nix;
  lan = p.network.lan;
  secretsDir = p.secrets.dir;
  secretPath = name: "${secretsDir}/${p.secrets.files.${name}}";
in
{
  my.configs.network = {
    dnsDoH = p.network.dns.doh;
    dnsBootstrap = p.network.dns.bootstrap;
    dnsFallback = p.network.dns.fallback;
  };

  my.services = {
    blocky.upstreamDns = p.network.blocky.upstream;
    pocket-id.secretsFile = secretPath "pocketId";
    privado-vpn = {
      privateKeyFile = secretPath "privadoKey";
      ipAddress = p.network.privado.address;
      publicKey = p.network.privado.publicKey;
      endpoint = p.network.privado.endpoint;
      dns = p.network.privado.dns;
    };
  };

  # Blocky-DNS fürs LAN — nur auf eno1, nicht WAN-weit (vor nftables Stufe 8)
  networking.firewall.interfaces.${lan.interface} = lib.mkIf (
    config.my.services.blocky.enable && !config.my.security.firewall.enable
  ) {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };

  networking.firewall.allowedUDPPorts = lib.mkIf (
    config.my.services.tailscale.enable && !config.my.security.firewall.enable
  ) (lib.mkForce [ config.my.services.tailscale.port ]);
}