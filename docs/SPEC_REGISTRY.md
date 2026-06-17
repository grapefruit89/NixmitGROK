---
meta:
  role: doc
  purpose: Leichtgewichtige Spec-IDs — Pfad, ADR, optional meta.id in Code-Headern
  tags:
    - registry
    - spec
---

# SPEC Registry

> Stabile IDs für KI und Mensch — **kein** Nix-Build-Overhead (`options.my.meta.*` bewusst nicht).
> IDs stehen optional im comment-YAML-Header (`meta.id`) und hier in der Tabelle.

## Kern-Bibliotheken

| ID | Pfad | ADR / Doku |
|----|------|------------|
| NIXH-05-LIB-001 | `lib/dns-map.nix` | — |
| NIXH-05-LIB-002 | `lib/service-factory.nix` | — |
| NIXH-05-LIB-003 | `lib/memory-policy.nix` | [003](adr/003-oom-cgroup-isolation.md) |
| NIXH-05-LIB-004 | `lib/critical-systemd.nix` | [005](adr/005-critical-systemd-restart.md) |
| NIXH-05-LIB-005 | `lib/unix-sockets.nix` | [004](adr/004-unix-socket-upstreams.md) |

## Gateway & Policy

| ID | Pfad | ADR / Doku |
|----|------|------------|
| NIXH-10-GTW-001 | `modules/10-gateway.nix` | [006](adr/006-sops-migration-path.md) |
| NIXH-90-POL-001 | `modules/91-security-assertions.nix` | `docs/SECURITY.md` |

## Media & Apps

| ID | Pfad | ADR / Doku |
|----|------|------------|
| NIXH-50-MED-001 | `modules/50-media/audiobookshelf.nix` | `docs/memory_oom.md` |
| NIXH-60-APP-TPL | `modules/60-apps/SERVICE_TEMPLATE.nix` | — |

## DNS-Hostnamen (SSOT)

Alle FQDNs: `lib/dns-map.nix` → `host "<schlüssel>"`. Beispiele:

| Schlüssel | FQDN (domain = nix.m7c5.de) |
|-----------|----------------------------|
| `linkwarden` | `links.nix.m7c5.de` |
| `audiobookshelf` | `audiobookshelf.nix.m7c5.de` |
| `vaultwarden` | `vault.nix.m7c5.de` |
| `ddns-updater` | `ddns.nix.m7c5.de` |

## Neue Einträge

1. Optional `meta.id: NIXH-…` im Datei-Header
2. Zeile in dieser Tabelle
3. Bei Architektur-Entscheidung: ADR in `docs/adr/`