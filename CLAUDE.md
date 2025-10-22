# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS flake-based configuration for a Framework 13 laptop (AMD 7040) running Sway WM. The configuration is modular with separate files for different system components.

## Building and Deploying

### Test Configuration First
Before rebuilding, ALWAYS test that the configuration evaluates correctly:
```bash
nixos-rebuild dry-build --flake /home/ml/repos/flake#
```

This checks for syntax errors and evaluation issues WITHOUT requiring sudo.

### Rebuild System
```bash
sudo nixos-rebuild switch --flake /home/ml/repos/flake#
# Or use the configured alias:
nrs  # (defined in terminal.nix)
```

The flake hostname is `roamer` (defined in `flake.nix` and `roamer.nix`).

## Architecture

### Flake Structure

- **flake.nix**: Main entry point defining inputs (nixpkgs, home-manager, zen-browser, etc.) and outputs
- **roamer.nix**: System-specific configuration that imports the Framework 13 hardware module and home-manager
- **modules/default.nix**: Aggregates and imports all modular configuration files

### Module Organization

Configuration is split into focused modules in `modules/`:

- **browser.nix**: Zen Browser configuration via home-manager
- **sway.nix**: Sway window manager with embedded status bar script
- **terminal.nix**: Kitty, ZSH, and CLI tools (zoxide, bat)
- **system.nix**: System-level settings, fonts, users
- **boot.nix**: Boot loader configuration
- **networking.nix**: Network configuration
- **nix.nix**: Nix daemon and flake settings
- **locale.nix**: Localization settings
- **xdg.nix**: XDG directory configuration
- **dev.nix**: Development tools

### Key Patterns

**Home Manager Integration**: Most user-level configuration uses home-manager nested under system configuration:
```nix
home-manager.users.ml = {
  programs.kitty = { ... };
};
```

**Embedded Scripts**: Sway bar script is embedded using `pkgs.writeShellScript` with absolute paths to binaries, avoiding separate script files.

**Browser Profiles**: Zen Browser profiles MUST include `id = 0` to be accessible. Settings go in `profiles.default.settings`, while policies use `mkLockedAttrs` wrapper.

**Font Management**: FiraCode Nerd Font is installed system-wide via `fonts.packages` using the new `nerd-fonts.fira-code` namespace (not the deprecated `nerdfonts.override`).

## Important Configuration Details

### Zen Browser (browser.nix)

- Uses zen-browser flake's homeModules.beta
- Extensions installed via policies with `mkExtensionEntry` helper
- Extension IDs from addons.mozilla.org (e.g., `addon@karakeep.app` for Karakeep)
- Pinned extensions set `pinned = true` and use `default_area = "navbar"`
- Profile requires `id = 0` field
- UI customization via `userChrome` CSS (requires `toolkit.legacyUserProfileCustomizations.stylesheets = true`)

### Sway Configuration (sway.nix)

- Status bar script is embedded in the module using `let` binding
- Scripts must use absolute paths to binaries (e.g., `${pkgs.pamixer}/bin/pamixer`)
- Keyboard layout is German (`de`)
- Vim-style direction keys (hjkl)
- Window decorations: 2px borders, no titlebars

### Terminal Setup (terminal.nix)

- Kitty terminal with FiraCode Nerd Font
- ZSH with autosuggestions, completion, syntax highlighting
- Shell alias: `nrs` for NixOS rebuild

## Common Modifications

When adding new configuration:
- Create focused module files for new features
- Import them in `modules/default.nix`
- Use home-manager for user-specific configuration
- Embed small scripts rather than creating separate files
- Use absolute paths for all binaries in scripts

## Development Workflow

### Research Before Editing
When modifying Nix configuration, ALWAYS research using relevant documentation first:
- **NixOS options**: https://search.nixos.org/options
- **Home Manager options**: https://home-manager-options.extranix.com/
- **Flake-specific modules**: Check the flake's repository README (e.g., zen-browser-flake)
- **Package search**: https://search.nixos.org/packages

Do not guess at option names or syntax - verify them in the official documentation.

### Testing Changes
1. Test evaluation without sudo: `nixos-rebuild dry-build --flake /home/ml/repos/flake#`
2. If evaluation succeeds, rebuild: `nrs` or `sudo nixos-rebuild switch --flake /home/ml/repos/flake#`
3. Never commit untested configuration changes
