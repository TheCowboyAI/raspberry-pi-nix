{ pkgs, lib, ... }: {

  imports = [
    ./networking.nix
  ];

  time.timeZone = "America/Phoenix";

  users.users.root.initialPassword = "root";
  users.users.cim = {
    initialPassword = "cim";
    isNormalUser = true;
  };

  security.rtkit.enable = true;

  system.stateVersion = "24.05";

}
