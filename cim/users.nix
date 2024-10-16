{ pkgs, lib, ... }: {
  users.users.root.initialPassword = "root";
  users.users.cim.initialPassword = "cim";
}
