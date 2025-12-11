{
  inputs,
  ...
}:
with inputs;
  nixpkgs.lib.nixosSystem {
    ## Setting system architecture.
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};

    ## Modules
    modules = [
      home-manager.nixosModules.home-manager
      disko.nixosModules.disko
      ../../modules/default.nix
      ./boot.nix
      ./disko.nix
      {
        # Enable modules for yalt (server machine)
        modules.server.enable = true;
        modules.editor.neovim = true;
        # modules.desktop.enable = false;  # No desktop on server
        # modules.dev.enable = false;
        # modules.pentest.enable = false;

        # Server-specific services
        services.openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "yes";
            PasswordAuthentication = false;
          };
        };

        users.users.ml.openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOJZEjixfR08o2MsqFto5Vs9Cfo2Gwsjd5WvR9dcuvAYXiT7qTRTu507IXwK3KqdQoY5RMLjKnSHCErRceEhGm92fo4I/+l0DgWuo6w1YRfquK2cKg/BcLZO3EKTJb5YVREIAD/5X42wPmiQyVExzPidpAwKdYHNGa99HcG4JUO5S+l6aLUk/0u7NL4af5tAYYVLT4AfVXAjjuVylB63EtbfLWQGTbLuwuXI9VxUwboyRu/mVaKWCXxh1VC0kfsfqsMSvIAHo1vEwUHLdZ7m6TyCiFbvtE7bqPJwBYU1/i+BSbktJTZLlSws02f2pl65mnImG5MSe+iFeqQTKP0ApeRRJ6CTqSYbI0l8kDJ5xAPLM7GhAR0xJ1fpLts0mFgyBcZAgT3Qb1RFNQWfgIsUdB/azON8p7Xud7VXvssK35JZRjxuLUgjMTRbZXMIGiFwkr+E1Qn/e2MIddjW+Sy7fg7ywVnVBFTa+WljhvLCl3fidb54uJYSyMQiCX73Ut7AjjJfR2HiwGwscKWxD3dVCb8SdBvvmFglc/IrAyBozBthSJzU1/w/wlBO4R7RvX1ixIl8NpIgGEx2GCYbbxYcCNgiZDgLVisPR8CAcKruwkoscd1jHEjdIfHrxE0aSUvA5QoE54H5DTIavbzowFdUnJn8fKpHL00YgHg1wLwhISzw== ml@roamer"
        ];

        services.i2p.enable = true;
      }
    ];
  }
