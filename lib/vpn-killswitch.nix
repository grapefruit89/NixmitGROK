# systemd-Härtung: Dienst darf nur über privado-WG egress (Kill-Switch).
{ lib, privadoEnabled }:

lib.optionalAttrs privadoEnabled {
  bindsTo = [ "sys-subsystem-net-devices-privado.device" ];
  after = [ "sys-subsystem-net-devices-privado.device" ];
  serviceConfig.RestrictNetworkInterfaces = [ "lo" "privado" ];
}