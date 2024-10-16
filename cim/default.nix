{ pkgs, lib, ... }: {

  imports = [
    ./raspi.nix
    ./networking.nix
    ./audio.nix
    ./users.nix
  ];

  time.timeZone = "America/Phoenix";

}
