{ pkgs, lib, ... }: {

  import = [
    ./raspi.nix
    ./networking.nix
    ./audio.nix
  ];

  time.timeZone = "America/Phoenix";

  users.users.root.initialPassword = "root";
  users.users.cim.initialPassword = "cim";

}
