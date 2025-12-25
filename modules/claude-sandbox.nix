{ config, lib, pkgs, ... }:
let
  cfg = config.modules.claude-sandbox;

  # Whonix CLI bundle (contains both Gateway + Workstation)
  whonixVersion = "18.0.8.7";
  whonixBundle = pkgs.fetchurl {
    url = "https://download.whonix.org/libvirt/${whonixVersion}/Whonix-CLI-${whonixVersion}.Intel_AMD64.qcow2.libvirt.xz";
    hash = "sha512-qqtJC+Z3NeXM6IGuovdyd+jqooIf6QCZSK44YQOtZ+o/XNKYLiP8IiK8+cESnkNgXHwkWzPnMsRLx0WQEmlj8w==";
  };

  # Extract qcow2 files from the libvirt bundle
  whonixImages = pkgs.runCommand "whonix-images" {
    nativeBuildInputs = [ pkgs.xz pkgs.libarchive ];
  } ''
    mkdir -p $out

    # Decompress and extract the tarball
    xz -dk < ${whonixBundle} > whonix.tar
    bsdtar -xf whonix.tar

    # Find and copy the qcow2 images
    find . -name "*.qcow2" -exec cp {} $out/ \;

    # Rename for consistency
    cd $out
    for f in *Gateway*.qcow2; do [ -f "$f" ] && mv "$f" gateway.qcow2; done
    for f in *Workstation*.qcow2; do [ -f "$f" ] && mv "$f" workstation.qcow2; done
  '';

  # Libvirt network XMLs
  whonixExternalNetXml = pkgs.writeText "whonix-external.xml" ''
    <network>
      <name>Whonix-External</name>
      <forward mode='nat'>
        <nat>
          <port start='1024' end='65535'/>
        </nat>
      </forward>
      <bridge name='virbr1' stp='on' delay='0'/>
      <ip address='10.0.2.2' netmask='255.255.255.0'>
        <dhcp>
          <range start='10.0.2.15' end='10.0.2.254'/>
        </dhcp>
      </ip>
    </network>
  '';

  whonixInternalNetXml = pkgs.writeText "whonix-internal.xml" ''
    <network>
      <name>Whonix-Internal</name>
      <bridge name='virbr2' stp='on' delay='0'/>
    </network>
  '';

  # Libvirt domain XMLs
  whonixGatewayDomainXml = pkgs.writeText "whonix-gateway-domain.xml" ''
    <domain type='kvm'>
      <name>Whonix-Gateway</name>
      <memory unit='GiB'>2</memory>
      <vcpu>2</vcpu>
      <os>
        <type arch='x86_64'>hvm</type>
        <boot dev='hd'/>
      </os>
      <features>
        <acpi/><apic/>
      </features>
      <cpu mode='host-passthrough'/>
      <devices>
        <disk type='file' device='disk'>
          <driver name='qemu' type='qcow2' cache='writeback'/>
          <source file='/var/lib/libvirt/images/whonix/gateway.qcow2'/>
          <target dev='vda' bus='virtio'/>
        </disk>
        <interface type='network'>
          <source network='Whonix-External'/>
          <model type='virtio'/>
        </interface>
        <interface type='network'>
          <source network='Whonix-Internal'/>
          <model type='virtio'/>
        </interface>
        <graphics type='spice' autoport='yes'/>
        <video><model type='qxl'/></video>
      </devices>
    </domain>
  '';

  whonixWorkstationDomainXml = pkgs.writeText "whonix-workstation-domain.xml" ''
    <domain type='kvm'>
      <name>Whonix-Workstation</name>
      <memory unit='GiB'>4</memory>
      <vcpu>4</vcpu>
      <os>
        <type arch='x86_64'>hvm</type>
        <boot dev='hd'/>
      </os>
      <features>
        <acpi/><apic/>
      </features>
      <cpu mode='host-passthrough'/>
      <devices>
        <disk type='file' device='disk'>
          <driver name='qemu' type='qcow2' cache='writeback'/>
          <source file='/var/lib/libvirt/images/whonix/workstation.qcow2'/>
          <target dev='vda' bus='virtio'/>
        </disk>
        <interface type='network'>
          <source network='Whonix-Internal'/>
          <model type='virtio'/>
        </interface>
        <graphics type='spice' autoport='yes'/>
        <video><model type='qxl'/></video>
      </devices>
    </domain>
  '';

in
{
  config = lib.mkIf cfg.enable {

    # ═══════════════════════════════════════════════════════════════════
    # LIBVIRT / KVM
    # ═══════════════════════════════════════════════════════════════════

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    users.users.ml.extraGroups = [ "libvirtd" "kvm" ];

    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
    ];

    # ═══════════════════════════════════════════════════════════════════
    # WHONIX VMs - DECLARATIVE SETUP
    # ═══════════════════════════════════════════════════════════════════

    # Copy qcow2 images to mutable location (VMs need write access)
    systemd.services.whonix-images = {
      description = "Deploy Whonix VM images";
      wantedBy = [ "multi-user.target" ];
      before = [ "libvirtd.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p /var/lib/libvirt/images/whonix

        if [ ! -f /var/lib/libvirt/images/whonix/gateway.qcow2 ]; then
          echo "Deploying Whonix Gateway image..."
          cp ${whonixImages}/gateway.qcow2 /var/lib/libvirt/images/whonix/
          chmod 644 /var/lib/libvirt/images/whonix/gateway.qcow2
        fi

        if [ ! -f /var/lib/libvirt/images/whonix/workstation.qcow2 ]; then
          echo "Deploying Whonix Workstation image..."
          cp ${whonixImages}/workstation.qcow2 /var/lib/libvirt/images/whonix/
          chmod 644 /var/lib/libvirt/images/whonix/workstation.qcow2
        fi
      '';
    };

    # Define libvirt networks and domains
    systemd.services.whonix-libvirt = {
      description = "Configure Whonix libvirt networks and domains";
      wantedBy = [ "multi-user.target" ];
      after = [ "libvirtd.service" "whonix-images.service" ];
      requires = [ "libvirtd.service" ];
      path = [ pkgs.libvirt ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # Wait for libvirtd socket
        while [ ! -S /var/run/libvirt/libvirt-sock ]; do
          sleep 1
        done

        # Networks
        if ! virsh net-info Whonix-External &>/dev/null; then
          virsh net-define ${whonixExternalNetXml}
          virsh net-start Whonix-External
          virsh net-autostart Whonix-External
        fi

        if ! virsh net-info Whonix-Internal &>/dev/null; then
          virsh net-define ${whonixInternalNetXml}
          virsh net-start Whonix-Internal
          virsh net-autostart Whonix-Internal
        fi

        # VMs
        if ! virsh dominfo Whonix-Gateway &>/dev/null; then
          virsh define ${whonixGatewayDomainXml}
        fi

        if ! virsh dominfo Whonix-Workstation &>/dev/null; then
          virsh define ${whonixWorkstationDomainXml}
        fi
      '';
    };

    # ═══════════════════════════════════════════════════════════════════
    # CLAUDE-SANDBOX CONTAINER
    # ═══════════════════════════════════════════════════════════════════

    containers.claude-sandbox = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.200.1.1";
      localAddress = "10.200.1.2";

      bindMounts = {
        "/home/claude/projects" = {
          hostPath = "/var/lib/claude-sandbox/projects";
          isReadOnly = false;
        };
        "/home/claude/.ssh" = {
          hostPath = "/var/lib/claude-sandbox/ssh";
          isReadOnly = false;
        };
        "/home/claude/.claude" = {
          hostPath = "/var/lib/claude-sandbox/claude-config";
          isReadOnly = false;
        };
      };

      config = { config, pkgs, ... }: {
        system.stateVersion = "24.11";
        nixpkgs.config.allowUnfree = true;

        environment.systemPackages = with pkgs; [
          claude-code
          openssh
          git
          jq
          ripgrep
        ];

        users.users.claude = {
          isNormalUser = true;
          home = "/home/claude";
          shell = pkgs.bash;
        };

        programs.ssh.extraConfig = ''
          Host whonix-ws
            HostName ${cfg.whonixWsIp}
            User pentest
            StrictHostKeyChecking accept-new
            IdentityFile ~/.ssh/whonix_key
            ConnectTimeout 60
            ServerAliveInterval 30
        '';

        networking.firewall.enable = false;
      };
    };

    # ═══════════════════════════════════════════════════════════════════
    # SSH KEY (generated on first activation)
    # ═══════════════════════════════════════════════════════════════════

    system.activationScripts.claude-sandbox-ssh = ''
      mkdir -p /var/lib/claude-sandbox/ssh
      if [ ! -f /var/lib/claude-sandbox/ssh/whonix_key ]; then
        ${pkgs.openssh}/bin/ssh-keygen -t ed25519 \
          -f /var/lib/claude-sandbox/ssh/whonix_key \
          -N "" -C "claude-sandbox"
        chown -R 1000:1000 /var/lib/claude-sandbox/ssh
        chmod 600 /var/lib/claude-sandbox/ssh/whonix_key
        chmod 644 /var/lib/claude-sandbox/ssh/whonix_key.pub
      fi
    '';

    systemd.tmpfiles.rules = [
      "d /var/lib/claude-sandbox 0755 root root -"
      "d /var/lib/claude-sandbox/projects 0755 1000 1000 -"
      "d /var/lib/claude-sandbox/ssh 0700 1000 1000 -"
      "d /var/lib/claude-sandbox/claude-config 0755 1000 1000 -"
    ];

    # ═══════════════════════════════════════════════════════════════════
    # NETWORK / FIREWALL
    # ═══════════════════════════════════════════════════════════════════

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking.nftables = {
      enable = true;
      ruleset = ''
        table inet claude-sandbox {
          chain forward {
            type filter hook forward priority filter; policy drop;

            ct state established,related accept

            # Claude → Anthropic API (Cloudflare)
            iifname "ve-claude-sa*" ip daddr {
              104.16.0.0/12,
              172.64.0.0/13,
              173.245.48.0/20,
              103.21.244.0/22,
              103.22.200.0/22,
              103.31.4.0/22,
              141.101.64.0/18,
              108.162.192.0/18,
              190.93.240.0/20,
              188.114.96.0/20,
              197.234.240.0/22,
              198.41.128.0/17,
              162.158.0.0/15,
              131.0.72.0/22
            } tcp dport 443 accept

            # Claude → Whonix-WS SSH
            iifname "ve-claude-sa*" ip daddr ${cfg.whonixWsIp} tcp dport 22 accept

            # DNS
            iifname "ve-claude-sa*" udp dport 53 accept
            iifname "ve-claude-sa*" tcp dport 53 accept

            # Whonix internal
            iifname "virbr2" oifname "virbr2" accept

            # Log blocked
            iifname "ve-claude-sa*" log prefix "claude-blocked: " drop
          }
        }
      '';
    };

    networking.nat = {
      enable = true;
      internalInterfaces = [ "ve-claude-sa+" "virbr1" ];
      externalInterface = cfg.externalInterface;
    };

    # Route claude-sandbox to Whonix internal network
    systemd.services.claude-sandbox-routing = {
      description = "Setup routing for claude-sandbox to Whonix";
      after = [ "libvirtd.service" "whonix-libvirt.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iproute2 ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        for i in $(seq 1 30); do
          if ip link show virbr2 &>/dev/null; then break; fi
          sleep 1
        done

        if ! ip addr show virbr2 | grep -q "10.152.152.1"; then
          ip addr add 10.152.152.1/24 dev virbr2 || true
        fi
      '';
    };
  };
}
