# ---
# meta:
#   layer: 2
#   role: machine
#   purpose: q958-Verdrahtung — Module-Imports und my.configs ohne .enable
#   tags:
#     - wiring
#     - q958
# ---
{ ... }:

let
  p = import ./profile.nix;
  moritz = import ../../users/moritz/profile.nix;
  zigbeeSocket = "socket://${p.iot.zigbeeCoordinator.host}:${toString p.iot.zigbeeCoordinator.port}";
in
{
  imports = [
    ./hardware.nix
    ../../modules/00-core.nix
    ../../modules/25-kernel-policy.nix
    ../../modules/10-network.nix
    ../../modules/10-gateway.nix
    ../../modules/15-firewall.nix
    ../../modules/20-security.nix
    ../../modules/30-storage.nix
    ../../modules/35-automount.nix
    ../../modules/40-observability.nix
    ../../modules/50-media
    ../../modules/60-apps
    ../../modules/70-forge.nix
    ../../modules/80-gaming.nix
    ../../users/moritz/default.nix
    ./kernel-slim.nix
    ./access.nix
    ./network.nix
    ./storage.nix
    ./secrets.nix
    ./dev-mode.nix
    ./rollout.nix
    ./boot-baseline.nix
    ../../modules/91-security-assertions.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${moritz.name} = import ../../users/moritz/home.nix;
  };

  networking.hostName = p.system.hostName;

  my = {
    configs = {
      identity = {
        user = moritz.name;
        domain = moritz.domain;
      };
      hardware = {
        ramGB = p.hardware.ramGB;
      };
      server = {
        lanIP = p.network.lan.ip;
        tailscaleIP = p.network.tailscaleIP;
      };
      ddns = {
        zone = p.network.ddns.zone;
        record = p.network.ddns.record;
      };
    };

    ports.ssh = p.network.sshPort;

    core.nix-tuning = {
      maxJobs = p.nix.maxJobs;
      cores = p.nix.cores;
      daemonLowPriority = p.nix.daemonLowPriority;
    };

    impermanence = {
      persistentDisk = p.storage.tierA.persist.disk;
      persistMountPoint = p.storage.impermanence.mountPoint;
    };

    security = {
      sovereign-unlock = {
        luksDevice = p.storage.luks.device;
        sshPort = p.security.sovereignUnlock.sshPort;
        authorizedKeys = p.security.sovereignUnlock.authorizedKeys;
      };
      firewall = {
        lanCidrs = p.security.firewall.lanCidrs;
        blockedCountries = p.security.firewall.blockedCountries;
        allowLanDns = p.security.firewall.allowLanDns;
      };
    };

    services = {
      storage.poolMountPoint = p.storage.mediaPoolMountPoint;
      storage-mover = {
        sourceDir = "${p.storage.fastPoolMountPoint}/downloads";
        targetDir = "${p.storage.mediaPoolMountPoint}/downloads";
      };
      restic-backup.healthcheckUrl = p.restic.healthcheckUrl;
      homepage.agentZeroUrl = p.integrations.agentZero.url;
      cockpit = {
        amtHost = p.integrations.amt.host;
        amtPort = p.integrations.amt.port;
        exposeAmt = p.integrations.amt.host != "";
      };
      home-assistant = {
        port = p.iot.homeAssistant.port;
        zigbeeDevice = zigbeeSocket;
      };
      zigbee-stack = {
        mqttPort = p.iot.zigbeeStack.mqttPort;
        zigbeePort = p.iot.zigbeeStack.zigbeePort;
        zigbeeDevice = zigbeeSocket;
        adapter = p.iot.zigbeeStack.adapter;
      };
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = p.boot.kernelParams;
  };

  system.stateVersion = p.system.stateVersion;
}