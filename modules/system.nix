{ config, pkgs, lib, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
  ];
  hardware.enableAllFirmware = true;
  security.polkit.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.swaylock.fprintAuth = true;
  services.fwupd.enable = true;
  environment.systemPackages = with pkgs; [
    fprintd    # gives you fprintd-enroll, fprintd-verify, etc.
    usbutils   # lsusb for quick sanity checks
  ];
 # Make finger-touch short-circuit auth for swaylock
  security.pam.services.swaylock.text = ''
    # Try fingerprint first; on success, stop (no password prompt needed)
    auth     sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so

    # Fall back to your normal login stack (password etc.)
    auth     include    login
    account  include    login
    password include    login
    session  include    login
  '';

  # Optional: same behavior for sudo
  security.pam.services.sudo.text = ''
    auth     sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so
    auth     include    login
    account  include    login
    password include    login
    session  include    login
  '';
  security.pam.services.login.fprintAuth = true;
  users.users.ml = {
    isNormalUser = true;
    description = "ml";
    extraGroups = [ "networkmanager" "kvm" "wheel" "docker" "libvirt"];
    packages = with pkgs; [];
  };

}
