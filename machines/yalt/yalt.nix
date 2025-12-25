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
        modules.claude-sandbox.enable = true;
        modules.claude-sandbox.externalInterface = "eno1";
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
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDk+w+nz2OSjtZ9qFzZL0m74xLflL/jjvIPdx9bBLsiJcqQPxNYYhWOMUDKzBjl6sWKwKQq9/m1gA7Y5yNghS67wXj2lkvSQQr27RWCwlxUQfGgQi2sRhRVNkHq1GPJBeX3D/aaEkQG+Y+RZTpIXOMDgEjhrpCgKBnc2IJuKaOppjw2ePiyu4w5tE6OXze8HMT+1KEsM+7NJtWZyJbNzy+bCtv5v84Ho6sbUw4p71SnIF92OK80Oe1I9puWtfr9wjK+sRRcGLMGTjxoo4ZVnlwJGJ6aKixvkiJEOIzTYgjk17dQDUrsOUTsHNSJaFpa46laKw/XjdFgbzNw5td2mISqY4Azppo5ynOlcdeEzFiFgV9hzBAOe7kuZxOkEWwLXr/8/7SNi0VbZnn/gQIJJp8G/tF6cxu9iVBWl7EKYlPiDveq++vY6I74FZJbMR1Ge8wnSEWTHIFKoJe3hJDiw2PYPCorUBtuwQ/jS7DaT9dVp6liN+iOT06jhtXdYASQzic= ml@roamer"
        ];
      }
    ];
  }
