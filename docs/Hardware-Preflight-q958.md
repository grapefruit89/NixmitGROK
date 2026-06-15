# Hardware Preflight — q958 (192.168.2.73)
Generated: 2026-06-15 12:40 UTC / local 2026-06-15
Source: SSH `nixos@192.168.2.73` (password auth verified)
USB installer stick: user reports still inserted; system booted from internal SSD (`root=fstab` on `/dev/sda2`).

---

## Summary

| Item | Value |
|------|-------|
| Hostname | q958 |
| IP | 192.168.2.73/24 (eno1) |
| NixOS | 26.05 Yarara |
| Internal disk | Micron MTFDDAK512TDL 512 GB (`/dev/sda`) |
| EFI boot | `/dev/sda1` 1024 MiB label BOOT |
| Root | `/dev/sda2` ext4 label NIXHOME_PERSIST |
| Login | `nixos` / `#baumeister` (verified via SSH) |
| Boot menu title | **Startpunkt** (generation 3+, declarative via `system.nixos.distroName`) |
| Active config | Bootstrap `configuration.nix` (not full flake yet) |
| Homelab config on disk | `/etc/nixos/hosts/q958/` + `flake.nix` (Obsidian `Nix Files/`, not active) |

## Reachability

```
q958
nixos
26.05.1550.bd0ff2d3eac2 (Yarara)
```

## Kernel

```
Linux q958 6.18.34 #1-NixOS SMP PREEMPT_DYNAMIC Mon Jun  1 15:51:08 UTC 2026 x86_64 GNU/Linux
```

## CPU

```
Architecture:                            x86_64
CPU op-mode(s):                          32-bit, 64-bit
Address sizes:                           39 bits physical, 48 bits virtual
Byte Order:                              Little Endian
CPU(s):                                  4
On-line CPU(s) list:                     0-3
Vendor ID:                               GenuineIntel
Model name:                              Intel(R) Core(TM) i3-9100 CPU @ 3.60GHz
CPU family:                              6
Model:                                   158
Thread(s) per core:                      1
Core(s) per socket:                      4
Socket(s):                               1
Stepping:                                11
Microcode version:                       0xf6
CPU(s) scaling MHz:                      100%
CPU max MHz:                             3600.0000
CPU min MHz:                             800.0000
BogoMIPS:                                7200.00
Flags:                                   fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good noplx nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb pti ssbd ibrs ibpb stibp tpr_shadow flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm arat pln pts hwp hwp_notify hwp_act_window hwp_epp vnmi md_clear flush_l1d arch_capabilities
Virtualization:                          VT-x
L1d cache:                               128 KiB (4 instances)
L1i cache:                               128 KiB (4 instances)
L2 cache:                                1 MiB (4 instances)
L3 cache:                                6 MiB (1 instance)
NUMA node(s):                            1
NUMA node0 CPU(s):                       0-3
Vulnerability Gather data sampling:      Mitigation; Microcode
Vulnerability Ghostwrite:                Not affected
Vulnerability Indirect target selection: Not affected
Vulnerability Itlb multihit:             KVM: Mitigation: Split huge pages
Vulnerability L1tf:                      Mitigation; PTE Inversion; VMX conditional cache flushes, SMT disabled
Vulnerability Mds:                       Mitigation; Clear CPU buffers; SMT disabled
Vulnerability Meltdown:                  Mitigation; PTI
Vulnerability Mmio stale data:           Mitigation; Clear CPU buffers; SMT disabled
Vulnerability Old microcode:             Not affected
Vulnerability Reg file data sampling:    Not affected
Vulnerability Retbleed:                  Mitigation; IBRS
Vulnerability Spec rstack overflow:      Not affected
Vulnerability Spec store bypass:         Mitigation; Speculative Store Bypass disabled via prctl
Vulnerability Spectre v1:                Mitigation; usercopy/swapgs barriers and __user pointer sanitization
Vulnerability Spectre v2:                Mitigation; IBRS; IBPB conditional; STIBP disabled; RSB filling; PBRSB-eIBRS Not affected; BHI Not affected
Vulnerability Srbds:                     Mitigation; Microcode
Vulnerability Tsa:                       Not affected
Vulnerability Tsx async abort:           Not affected
Vulnerability Vmscape:                   Mitigation; IBPB before exit to userspace
```

## Memory

```
total        used        free      shared  buff/cache   available
Mem:            15Gi       499Mi        14Gi       5.5Mi       241Mi        14Gi
Swap:             0B          0B          0B
```

## DMI System/BIOS

```

```

## Block devices

```
NAME     SIZE TYPE FSTYPE LABEL           MODEL                   SERIAL           UUID                                 MOUNTPOINT
sda    476.9G disk                        MTFDDAK512TDL-1AW1ZABFA 19432490DAF2                                          
├─sda1     1G part vfat   BOOT                                                     D4C4-F64A                            /boot
└─sda2 475.9G part ext4   NIXHOME_PERSIST                                          a25be61c-fea9-4f28-b5ef-1d4298701933 /
sdb     59.8G disk                        Flash Drive FIT         0306122120002731                                      
├─sdb1  59.7G part exfat  Ventoy                                                   4E21-0000                            
└─sdb2    32M part vfat   VTOYEFI                                                  E039-AD96
```

## Filesystem usage

```
Filesystem     Type      Size  Used Avail Use% Mounted on
/dev/sda2      ext4      468G  3.9G  440G   1% /
tmpfs          tmpfs     3.9G  4.3M  3.9G   1% /run
devtmpfs       devtmpfs  789M     0  789M   0% /dev
tmpfs          tmpfs     7.7G     0  7.7G   0% /dev/shm
efivarfs       efivarfs  192K   52K  136K  28% /sys/firmware/efi/efivars
none           tmpfs     1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
none           tmpfs     1.0M     0  1.0M   0% /run/credentials/systemd-resolved.service
none           tmpfs     1.0M     0  1.0M   0% /run/credentials/systemd-networkd.service
tmpfs          tmpfs     7.7G  1.1M  7.7G   1% /run/wrappers
/dev/sda1      vfat     1022M   95M  928M  10% /boot
none           tmpfs     1.0M     0  1.0M   0% /run/credentials/getty@tty1.service
tmpfs          tmpfs     1.6G  4.0K  1.6G   1% /run/user/1000
```

## Mount points

```
TARGET                                    SOURCE                FSTYPE       SIZE  AVAIL USE%
/                                         /dev/sda2             ext4       467.4G 439.7G   1%
/run                                      tmpfs                 tmpfs        3.8G   3.8G   0%
/dev                                      devtmpfs              devtmpfs   788.4M 788.4M   0%
/dev/pts                                  devpts                devpts          0      0    -
/dev/shm                                  tmpfs                 tmpfs        7.7G   7.7G   0%
/proc                                     proc                  proc            0      0    -
/run/keys                                 ramfs                 ramfs           0      0    -
/sys                                      sysfs                 sysfs           0      0    -
/nix/store                                /dev/sda2[/nix/store] ext4       467.4G 439.7G   1%
/sys/kernel/security                      securityfs            securityfs      0      0    -
/sys/fs/cgroup                            cgroup2               cgroup2         0      0    -
/sys/fs/pstore                            none                  pstore          0      0    -
/sys/firmware/efi/efivars                 efivarfs              efivarfs     192K 135.4K  27%
/sys/fs/bpf                               bpf                   bpf             0      0    -
/dev/hugepages                            hugetlbfs             hugetlbfs       0      0    -
/dev/mqueue                               mqueue                mqueue          0      0    -
/sys/kernel/debug                         debugfs               debugfs         0      0    -
/sys/kernel/tracing                       tracefs               tracefs         0      0    -
/run/credentials/systemd-journald.service none                  tmpfs          1M     1M   0%
/sys/fs/fuse/connections                  fusectl               fusectl         0      0    -
/sys/kernel/config                        configfs              configfs        0      0    -
/run/credentials/systemd-resolved.service none                  tmpfs          1M     1M   0%
/run/credentials/systemd-networkd.service none                  tmpfs          1M     1M   0%
/run/wrappers                             tmpfs                 tmpfs        7.7G   7.7G   0%
/boot                                     /dev/sda1             vfat        1022M 927.5M   9%
/run/credentials/getty@tty1.service       none                  tmpfs          1M     1M   0%
/run/user/1000                            tmpfs                 tmpfs        1.5G   1.5G   0%
```

## Partition UUIDs

```
/dev/sdb2: SEC_TYPE="msdos" LABEL_FATBOOT="VTOYEFI" LABEL="VTOYEFI" UUID="E039-AD96" BLOCK_SIZE="512" TYPE="vfat" PARTLABEL="VTOYEFI" PARTUUID="c720ee1f-5479-4faf-bb47-d4347eedc16c"
/dev/sdb1: LABEL="Ventoy" UUID="4E21-0000" BLOCK_SIZE="512" TYPE="exfat" PARTLABEL="Ventoy" PARTUUID="10332dd6-bc79-437d-b0e5-433b82ce6827"
/dev/sda2: LABEL="NIXHOME_PERSIST" UUID="a25be61c-fea9-4f28-b5ef-1d4298701933" BLOCK_SIZE="4096" TYPE="ext4" PARTLABEL="NIXHOME_PERSIST" PARTUUID="bd763ecb-c991-4ab7-a9e2-550e7de2e97c"
/dev/sda1: LABEL_FATBOOT="BOOT" LABEL="BOOT" UUID="D4C4-F64A" BLOCK_SIZE="512" TYPE="vfat" PARTLABEL="BOOT" PARTUUID="97616e2f-8c7e-4740-8b5a-5604b98eb69c"
```

## PCI devices

```

```

## Network

```
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP> 
eno1             UP             68:84:7e:71:19:a1 <BROADCAST,MULTICAST,UP,LOWER_UP> 

lo               UNKNOWN        127.0.0.1/8 ::1/128 
eno1             UP             192.168.2.73/24 2003:dc:7f47:d8b3:5145:4f44:8e8a:47fa/64 2003:dc:7f47:d8b3:49d4:8264:bb58:3311/64 2003:dc:7f47:d8b3:6783:5987:d8ef:4c89/64 2003:dc:7f47:d8b3:6a84:7eff:fe71:19a1/64 fe80::458f:97f6:ccfa:1021/64
```

## USB devices

```

```

## EFI boot entries

```

```

## Boot loader entries

```
total 16
drwxr-xr-x 2 root root 4096 Jun 15 14:28 .
drwxr-xr-x 4 root root 4096 Jun 15 14:29 ..
-rwxr-xr-x 1 root root  474 Jun 15 14:28 nixos-generation-1.conf
-rwxr-xr-x 1 root root  473 Jun 15 14:28 nixos-generation-2.conf

title NixOS
sort-key nixos
version Generation 1 NixOS Yarara 26.05.1550.bd0ff2d3eac2 (Linux 6.18.34), built on 2026-06-14
linux /EFI/nixos/c1zpblmjqf7bw47hca92rhm599ab7bsh-linux-6.18.34-bzImage.efi
initrd /EFI/nixos/3grmpdhjhjm87rfiplfsq58gfmbq0g3z-initrd-linux-6.18.34-initrd.efi
options init=/nix/store/yan1qncg483bhdlmwz5dzljdk7prpygw-nixos-system-nixos-26.05.1550.bd0ff2d3eac2/init root=fstab loglevel=4 lsm=landlock,yama,bpf
machine-id e62778ec1b5b4a23850bb783b7b61a12
title NixOS
sort-key nixos
version Generation 2 NixOS Yarara 26.05.1550.bd0ff2d3eac2 (Linux 6.18.34), built on 2026-06-15
linux /EFI/nixos/c1zpblmjqf7bw47hca92rhm599ab7bsh-linux-6.18.34-bzImage.efi
initrd /EFI/nixos/8rk1vr088w2a049mbz215ivv469sl9ls-initrd-linux-6.18.34-initrd.efi
options init=/nix/store/2idyrmmlr5p7z1afcdyviic3qhydkchz-nixos-system-q958-26.05.1550.bd0ff2d3eac2/init root=fstab loglevel=4 lsm=landlock,yama,bpf
machine-id e62778ec1b5b4a23850bb783b7b61a12
```

## Boot partition

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1      1022M   95M  928M  10% /boot

95M	/boot/EFI
32K	/boot/loader
```

## SMART /dev/sda

```

```

## Active NixOS config

```
{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "q958";
  networking.networkmanager.enable = true;
  networking.useDHCP = false;

  systemd.network.enable = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "eno1";
    networkConfig = {
      Address = "192.168.2.73/24";
      Gateway = "192.168.2.1";
      DNS = [ "192.168.2.1" "1.1.1.1" ];
    };
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.nixos = {
    isNormalUser = true;
    description = "Bootstrap admin";
    extraGroups = [ "wheel" "networkmanager" ];
    initialHashedPassword = "$6$Szy0soTzDMvTUJuJ$HmF.AsWEzL8EJ9kTAyZ28UM3nK.9tpC.5lC7sjVdEUuxnh4ozpA4An5mDkX4u7PnJbPm/MjtTKKTeO2LflS/Q.";
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  environment.systemPackages = with pkgs; [ vim wget git ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.05";
}
```

## Homelab flake present

```
-rwxr-xr-x 1 root root 1665 Jun  5 10:25 /etc/nixos/flake.nix
-rwxr-xr-x 1 root root 4645 Jun 14 22:50 /etc/nixos/hosts/q958/configuration.nix
```

## Boot cmdline

```
initrd=\EFI\nixos\8rk1vr088w2a049mbz215ivv469sl9ls-initrd-linux-6.18.34-initrd.efi init=/nix/store/2idyrmmlr5p7z1afcdyviic3qhydkchz-nixos-system-q958-26.05.1550.bd0ff2d3eac2/init root=fstab loglevel=4 lsm=landlock,yama,bpf
```

## Notes

- **Config I meant earlier**: the full Homelab setup under `/etc/nixos/hosts/q958/` (10-domain modules, Jellyfin, Home Assistant, impermanence, etc.) from your Obsidian `Nix Files/` repo. Install used a smaller bootstrap `configuration.nix` because the flake has a known error in `modules/30-storage.nix`.
- **Boot menu 'Startpunkt'**: aktiv in `/etc/nixos/configuration.nix` via `system.nixos.distroName = "Startpunkt"`. Default boot: `nixos-generation-3.conf`.
- **USB-Stick**: System bootet von interner SSD (`root=fstab` auf `sda2`). Ventoy-USB kann im UEFI-Menü noch sichtbar sein, ist aber nicht nötig.
