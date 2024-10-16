# Intent
We are building a [CIM](https://github.com/thecowboyai/cim-start) - a Composable Information Machine...

What does that even mean?

>A CIM is a way to build a distributed platform to operate an information system.

*Lovely, what does THAT mean?*

It means: I have a pile of hardware, some accounts with cloud providers, and some intended use of information.

I may or may not know exactly what all this hardware does, or even how to connect to a cloud provider account. I do know some things I need to do.

Typically this means reading a mountain of documentation and still being lost. We can build this all manually and that is terrific for experimenting... Once I am done experimenting how do I actually implement everything?

Where do I go AFTER doing the tutorial stuff?

Am I expected to sit in front of every piece of technology we use in order to link it together into a reasonably connected system?

Yes. That is what you are offered when you are presented with build a new "information system".

How will you manage "EVERYTHING?"

I mean exactly that... how do I manage the entire structure, all it's systems, all the structure and all the data?

"Composable" means I turn everything into modules with inputs, transition, and outputs.

NixOS is a deterministic system, meaning you already know what you want, you configure it, and Nix makes it happen.

"Managing" all the information, including the system itself, that is what a CIM does.  We "compose" everything together from smaller pieces to create a whole. We are assembling known things.

Installers are made because the manufacturer doesn't know what you want. We already know our design, we will create a "domain", and then implement it.

I can build from kernel source, or I can import a bunch of binaries. It doesn't matter. What matters is that you can configure this in a reasonable way so I am not continually lost in technological limbo.

CIM, being built on Nix, unifies all this into a single configuration language, Nix, which will make sure that whatever it is you are connecting, get it's configuration set up correctly and repeatably.

We want a fully configured system that starts.
We *don't* want to "install" it after initial boot.
This should be repeatable and I should be able to test that I get the same thing every time.

I should get a list of Events created that I can log or persist to an Event Store to see the sequence of everything that happened.

We want a no-touch deployment, where we can either use an SD Card or a Network Boot, let it boot and it joins the system.

Can't I just start the initial system and connect everything to that? Yes, that is exactly what this guide will do. We start with a single Raspberry Pi and let the system evolve itself.

For our Initial System, we may need an SD Card, but certainly we don't really want to be creating new SD Cards every time we want to add metal. This should be nearly automatic.  All I need to know is the identifying information of the inventory and I should be able to just configure it.

We can accomplish this in two ways:
1. Make an initial SD Card that boots to some sort of "controller".
2. Make a network boot system and add it to our router. Ok, but that means I need a router. You will anyway to connect to the internet.

Let's look at both options:
1. Define a NixOS Configuration for a controller that allows other systems to connect.

This seems very reasonable, I really don't want to duplicate configurations just to change a single line attribute, the hostname.  That is where Nix shines, we can share most of the configurations and know in advance, they work. Then we adjust the deafults to make a real system.

I don't need to run nixos-generate-config, I already know what hardware-configuration will be, this is a raspberry pi 4 model B+ and I have 4 of them, they won't ever change.

This then leads us directly to number two, netbooting. We can actually combine the approaches.

Make an SD card that starts and configures a network I can just attach things to, then they should auto-configure themselves based on the Inventory.

You may already be familiar with similar concepts such as "OpenStack" or "Metal As A Service" that have similar concepts.

The difference in a CIM, is that we care about the abstractions, not the typical implementation details.

We care about WHAT we want to accomplish, then figure out HOW and templatize that workflow.

# Goal System
  CIM Controller
  CIM Worker 1
  CIM Worker 2
  CIM Worker 3
  5 Port Network Switch
  Virtual Internal Network
  Internet Connection via edge gateway connected to switch

This means 4 separate machines, in this guide we use Raspberry Pi 4B+, but you could use any machine you have the full hardware configuration for.

For a CIM, we will have a Configuration.
This is a 3-Part configuration in NixOS:
  1.  flake.nix
  collectively holds all inputs and outputs and individual hosts
  2. configuration.nix
  software settings
  3. hardware-configuration.nix
  hardware settings

These are not hard rules, technically, you can put hardware into configuration.nix, but we intentionally want to separate these to share them.

Nix is built on a module system and so is a CIM.

A git repository contains all the information required to create your "controller". We will refer to this as the "Genesis Device".

The "Genesis Device" is simply the initial constructor for our CIM.

We should also have a way to extract information from the devices before adding them to the CIM.

This allows us to plug in a new device and have it display some vital information before we allow it to join the network.  With this information we can automatically add it, or require someone to authorize the input.

This is simple a way for us to get vital hardware information used to assign the proper boot sequence.

We want the following:
  CPU ID
  eth0 MAC Address
  wlan0 MAC Address

Additionally, Raspberry Pi features a One Time Programmable Memory Store that will allow us to add our own unique identifier, such as a AssetTag.

This is the first time we have talked about Inventory, so let's discuss that a little more.

# Inventory
Inventory is the collection of devices we use as resources.
Each Inventory Item has uniquely identifying information.

We have a distinguishing Key for every Device that is used, to identify it uniquely in the system.

We don't want to use the "natural key" for this, but we do want to use the "natural key" to validate it.

Each Device:
  CPU ID
  Mac Address eth0
  Mac Address wlan0

We will create:
  Unique System ID

Assign a hostname

These 5 fields:
  Name
  CpuId
  Mac
  Mac
  DeviceId

make up the "natural key", once created, this is immutable.
It is added to the Event Store and a Hash of the Natural Key is made.

Then the system can assign IP addresses and know with certainty we are not assiging unknown devices.

Our "Information System" has to know about itself, and we do this by direct relationships between equipment, software, and their configurations.

We can obtain this by booting the info-sd and reading what it collects, then populate inventory.yaml.

You can certainly change hostnames, or mac addresses, but then that is considered a different device, and you should have a migration from the old device to the new if you are replacing hardware.

This can be as simple a, drop deviceA and add deviceAPrime.
The fact we identify the hardware before using it is important. We will talk about this workflow at length as we proceed because it is a vital part of how a CIM works.

# Collecting Inventory
The Info SD is a configuration that boots and displays identifying information. We can't get this without booting, and we don't rely on the network, because mac addresses can be "spoofed".

Boot the info-sd
This will write out <fqdn>.hw.yaml
We use this to create the SD, or respond to the Network Boot.

We should only need to do this once, but what if I need to configure remote systems, yes, now you see why we are doing this stuff. We have a few choices, we can boot the device offline, get the hardware info an add it, or we can netboot and collect it there, but that requires being setup first.

