{ config, lib, pkgs, ... }:
let
  cfg = config.modules.claude-sandbox;

  # Whonix network definitions as libvirt XML
  whonixExternalXml = pkgs.writeText "whonix-external.xml" ''
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

  whonixInternalXml = pkgs.writeText "whonix-internal.xml" ''
    <network>
      <name>Whonix-Internal</name>
      <bridge name='virbr2' stp='on' delay='0'/>
      <!-- No DHCP - Whonix uses static IPs -->
      <!-- Gateway: 10.152.152.10, Workstation: 10.152.152.11 -->
    </network>
  '';

  # Setup script for Whonix VM import
  whonixSetupScript = pkgs.writeShellScriptBin "whonix-setup" ''
    #!/usr/bin/env bash
    set -euo pipefail

    WHONIX_VERSION="17.2.3.7"
    WHONIX_DIR="/var/lib/libvirt/images/whonix"
    DOWNLOAD_URL="https://download.whonix.org/libvirt/$WHONIX_VERSION"

    echo "=== Whonix Setup Script ==="
    echo ""

    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
      echo "This script must be run as root (sudo)"
      exit 1
    fi

    # Create directories
    mkdir -p "$WHONIX_DIR"
    cd "$WHONIX_DIR"

    # Define/start networks if not already present
    echo "[1/5] Setting up libvirt networks..."
    if ! virsh net-info Whonix-External &>/dev/null; then
      virsh net-define ${whonixExternalXml}
      virsh net-start Whonix-External
      virsh net-autostart Whonix-External
      echo "  ✓ Whonix-External network created"
    else
      echo "  → Whonix-External already exists"
    fi

    if ! virsh net-info Whonix-Internal &>/dev/null; then
      virsh net-define ${whonixInternalXml}
      virsh net-start Whonix-Internal
      virsh net-autostart Whonix-Internal
      echo "  ✓ Whonix-Internal network created"
    else
      echo "  → Whonix-Internal already exists"
    fi

    # Download Whonix images if not present
    echo ""
    echo "[2/5] Downloading Whonix images (if needed)..."

    GW_QCOW="Whonix-Gateway-Xfce-$WHONIX_VERSION.Intel_AMD64.qcow2"
    WS_QCOW="Whonix-Workstation-Xfce-$WHONIX_VERSION.Intel_AMD64.qcow2"

    if [[ ! -f "$GW_QCOW" ]]; then
      echo "  Downloading Gateway image..."
      ${pkgs.curl}/bin/curl -L -O "$DOWNLOAD_URL/$GW_QCOW"
      ${pkgs.curl}/bin/curl -L -O "$DOWNLOAD_URL/$GW_QCOW.asc"
    else
      echo "  → Gateway image exists"
    fi

    if [[ ! -f "$WS_QCOW" ]]; then
      echo "  Downloading Workstation image..."
      ${pkgs.curl}/bin/curl -L -O "$DOWNLOAD_URL/$WS_QCOW"
      ${pkgs.curl}/bin/curl -L -O "$DOWNLOAD_URL/$WS_QCOW.asc"
    else
      echo "  → Workstation image exists"
    fi

    # Verify signatures (optional but recommended)
    echo ""
    echo "[3/5] Verifying signatures..."
    echo "  ⚠ Manual verification recommended: gpg --verify $GW_QCOW.asc"
    echo "  ⚠ Whonix signing key: https://www.whonix.org/wiki/Signing_Key"

    # Create VM definitions
    echo ""
    echo "[4/5] Creating VM definitions..."

    # Whonix Gateway VM
    if ! virsh dominfo Whonix-Gateway &>/dev/null; then
      virsh define /dev/stdin <<GWXML
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
          <source file='$WHONIX_DIR/$GW_QCOW'/>
          <target dev='vda' bus='virtio'/>
        </disk>
        <!-- External network (NAT to internet for Tor) -->
        <interface type='network'>
          <source network='Whonix-External'/>
          <model type='virtio'/>
        </interface>
        <!-- Internal network (to Workstation) -->
        <interface type='network'>
          <source network='Whonix-Internal'/>
          <model type='virtio'/>
        </interface>
        <graphics type='spice' autoport='yes'/>
        <video><model type='qxl'/></video>
        <channel type='unix'>
          <target type='virtio' name='org.qemu.guest_agent.0'/>
        </channel>
      </devices>
    </domain>
GWXML
      echo "  ✓ Whonix-Gateway VM defined"
    else
      echo "  → Whonix-Gateway already exists"
    fi

    # Whonix Workstation VM
    if ! virsh dominfo Whonix-Workstation &>/dev/null; then
      virsh define /dev/stdin <<WSXML
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
          <source file='$WHONIX_DIR/$WS_QCOW'/>
          <target dev='vda' bus='virtio'/>
        </disk>
        <!-- Internal network ONLY (isolated, Tor-forced) -->
        <interface type='network'>
          <source network='Whonix-Internal'/>
          <model type='virtio'/>
        </interface>
        <graphics type='spice' autoport='yes'/>
        <video><model type='qxl'/></video>
        <channel type='unix'>
          <target type='virtio' name='org.qemu.guest_agent.0'/>
        </channel>
      </devices>
    </domain>
WSXML
      echo "  ✓ Whonix-Workstation VM defined"
    else
      echo "  → Whonix-Workstation already exists"
    fi

    echo ""
    echo "[5/5] Setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Start Gateway:    sudo virsh start Whonix-Gateway"
    echo "  2. Start Workstation: sudo virsh start Whonix-Workstation"
    echo "  3. Complete Whonix first-run wizard in each VM"
    echo "  4. In Workstation, create 'pentest' user and install tools:"
    echo "       sudo adduser pentest"
    echo "       sudo apt install nmap sqlmap gobuster netcat-openbsd ..."
    echo "  5. Add SSH key from /var/lib/claude-sandbox/ssh/whonix_key.pub"
    echo "       to Workstation's /home/pentest/.ssh/authorized_keys"
    echo ""
    echo "To connect via virt-manager: virt-manager"
    echo "To connect via console: virsh console Whonix-Gateway"
  '';

  # Script to generate SSH key for claude-sandbox
  claudeSshSetupScript = pkgs.writeShellScriptBin "claude-sandbox-ssh-setup" ''
    #!/usr/bin/env bash
    set -euo pipefail

    SSH_DIR="/var/lib/claude-sandbox/ssh"

    if [[ $EUID -ne 0 ]]; then
      echo "Run as root: sudo claude-sandbox-ssh-setup"
      exit 1
    fi

    mkdir -p "$SSH_DIR"

    if [[ ! -f "$SSH_DIR/whonix_key" ]]; then
      echo "Generating SSH key for claude-sandbox..."
      ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f "$SSH_DIR/whonix_key" -N "" -C "claude-sandbox"
      chown -R 1000:1000 "$SSH_DIR"
      chmod 600 "$SSH_DIR/whonix_key"
      chmod 644 "$SSH_DIR/whonix_key.pub"
      echo ""
      echo "✓ SSH key generated!"
      echo ""
      echo "Add this public key to Whonix-Workstation:"
      echo "─────────────────────────────────────────────"
      cat "$SSH_DIR/whonix_key.pub"
      echo "─────────────────────────────────────────────"
      echo ""
      echo "On Whonix-WS run:"
      echo "  mkdir -p ~/.ssh && echo 'THE_KEY_ABOVE' >> ~/.ssh/authorized_keys"
    else
      echo "SSH key already exists at $SSH_DIR/whonix_key"
      echo ""
      echo "Public key:"
      cat "$SSH_DIR/whonix_key.pub"
    fi
  '';

in
{
  config = lib.mkIf cfg.enable {

    # ═══════════════════════════════════════════════════════════════════
    # LIBVIRT / KVM SETUP FOR WHONIX VMs
    # ═══════════════════════════════════════════════════════════════════

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    # Add user to libvirt groups
    users.users.ml.extraGroups = [ "libvirtd" "kvm" ];

    # Management tools
    environment.systemPackages = [
      pkgs.virt-manager
      pkgs.libguestfs-with-appliance
      whonixSetupScript
      claudeSshSetupScript
    ];

    # ═══════════════════════════════════════════════════════════════════
    # CLAUDE-SANDBOX CONTAINER
    # ═══════════════════════════════════════════════════════════════════

    containers.claude-sandbox = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.200.1.1";
      localAddress = "10.200.1.2";

      # Bind mount for persistent data
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

        # Minimal environment - NO pentest tools
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

        # SSH config for Whonix-WS access
        programs.ssh.extraConfig = ''
          Host whonix-ws
            HostName ${cfg.whonixWsIp}
            User pentest
            StrictHostKeyChecking accept-new
            IdentityFile ~/.ssh/whonix_key
            # Timeout settings for Tor latency
            ConnectTimeout 60
            ServerAliveInterval 30
        '';

        networking.firewall.enable = false;
      };
    };

    # Persistent directories
    systemd.tmpfiles.rules = [
      "d /var/lib/claude-sandbox 0755 root root -"
      "d /var/lib/claude-sandbox/projects 0755 1000 1000 -"
      "d /var/lib/claude-sandbox/ssh 0700 1000 1000 -"
      "d /var/lib/claude-sandbox/claude-config 0755 1000 1000 -"
      "d /var/lib/libvirt/images/whonix 0755 root root -"
    ];

    # ═══════════════════════════════════════════════════════════════════
    # NETWORK / FIREWALL CONFIGURATION
    # ═══════════════════════════════════════════════════════════════════

    # Enable IP forwarding for routing between networks
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
    };

    networking.nftables = {
      enable = true;
      ruleset = ''
        table inet claude-sandbox {
          chain forward {
            type filter hook forward priority filter; policy drop;

            # Allow established/related
            ct state established,related accept

            # ─── Claude Container → Anthropic API ───
            # Cloudflare ranges (Anthropic uses Cloudflare)
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
              104.16.0.0/13,
              104.24.0.0/14,
              172.64.0.0/13,
              131.0.72.0/22
            } tcp dport 443 accept

            # ─── Claude Container → Whonix-WS SSH ───
            # Route through Whonix internal network bridge
            iifname "ve-claude-sa*" ip daddr ${cfg.whonixWsIp} tcp dport 22 accept

            # ─── DNS for API resolution ───
            iifname "ve-claude-sa*" udp dport 53 accept
            iifname "ve-claude-sa*" tcp dport 53 accept

            # ─── Allow Whonix internal network traffic ───
            iifname "virbr2" oifname "virbr2" accept

            # ─── Log blocked traffic ───
            iifname "ve-claude-sa*" log prefix "claude-blocked: " drop
          }
        }
      '';
    };

    # NAT for container and VM internet access
    networking.nat = {
      enable = true;
      internalInterfaces = [ "ve-claude-sa+" "virbr1" ];
      externalInterface = cfg.externalInterface;
    };

    # Add route from container network to Whonix internal network
    networking.interfaces."virbr2" = {
      ipv4.routes = [
        { address = "10.200.1.0"; prefixLength = 24; via = "10.200.1.1"; }
      ];
    };

    # Ensure host can route to Whonix internal network
    systemd.services."claude-sandbox-routing" = {
      description = "Setup routing for claude-sandbox to Whonix";
      after = [ "libvirtd.service" "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        # Wait for virbr2 to exist (created by libvirt)
        for i in {1..30}; do
          if ip link show virbr2 &>/dev/null; then
            break
          fi
          sleep 1
        done

        # Add host IP to internal bridge if not present
        if ! ip addr show virbr2 | grep -q "10.152.152.1"; then
          ip addr add 10.152.152.1/24 dev virbr2 || true
        fi

        # Route from claude-sandbox to Whonix internal
        ip route add 10.152.152.0/24 via 10.200.1.1 dev ve-claude-sandbox || true
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
}
