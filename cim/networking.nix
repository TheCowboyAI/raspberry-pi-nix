{ pkgs, lib, ... }: {
  networking = {
    hostName = "cluster";
    domain = "cim.thecowboy.ai";
    useDHCP = false;
    interfaces = {
      wlan0.useDHCP = false;
      eth0 = {
        useDHCP = false;
        ipv4.addresses =
          [
            {
              address = "192.168.100.2";
              prefixLength = 24;
            }
          ];
          };
      };
    };
  }
