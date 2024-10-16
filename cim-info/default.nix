{ pkgs, lib, ... }: {

  import = [
    ../cim/raspi.nix
    ./networking.nix
    ../cim/audio.nix
  ];

  time.timeZone = "America/Phoenix";

  users.users.root.initialPassword = "root";
  users.users.cim.initialPassword = "cim";

  security.rtkit.enable = true;

}
