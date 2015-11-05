# livessh

A framework for building Ubuntu "live CD" images that start an SSH server at boot.  The resulting images can be booted
in any way that normal Ubuntu images can be, including via PXE ("netbooting"), which is how I typically use them.

The images can, for example:

- set a predicatable hostname based on the machine's network interfaces' hardware addresses

- advertise via Zeroconf/Avahi

- have your SSH key(s) baked in

- automatically mount an NFS volume

## Building

- Change to the 'bin' directory.  (Sorry; yes, this must be your working directory.)

- Edit 'vars' if appropriate.

- Run

  - ./build-debootstrap-image.sh

    (This runs debootstrap inside a docker container.  It uses the mkimage scripts from the Docker repository.  This
    creates a pristine, baseline Ubuntu installation.)

  - ./build-customized-environment.sh

    (This exports the debootstrapped Docker container from the previous step into a temporary directory (BASE_PATH).
    Your pre-customize.d scripts are run on the host.  The 'customize.sh' script is invoked inside a container, which in
    turn runs your customize.d scripts.)  the container; see the 'customize.sh' script, which is the top-l

  - ./build-livecd-image.sh

    (This builds a squashfs from the filesystem created in the previous step, puts that, ISOLINUX, and a few
    configuration files into a temporary directory (IMAGE_PATH), and then builds an ISO from that directory.)

## Features

- openssh

    - By default, pulls in your SSH keys (~/.ssh/authorized_keys) at build time.

- avahi/hostname

    - Instead of "ubuntu", the live environment changes its hostname to e.g. "livessh-5254000f9ba9", where the latter is
      its MAC address.

    - The live environment runs the Avahi daemon, so you should be able to use 'avahi-browse -at' to see what IP address
      the machine has received via DHCP.  (If you have MDNS set up, you can also just use "livessh-5254000f9ba9.local"
      as a hostname.)

- Installs squid-deb-proxy-client, so if an apt proxy is being advertised via zeroconf, it will be automatically used,
  should you need to install new things after booting the image.

- Custom software is easy to add

- NFS mount

## Tips

- TODO: Testing in a libvirt/qemu/KVM guest

- TODO: PXE booting

## Troubleshooting

- If you are troubleshooting the early part of the booting process, you may need to inspect the initramfs.  The
  'bin/extract-initramfs.sh' script demonstrates how to do this.

- Normal tricks for getting access to a VM's filesystem for inspection purposes, like 'guestmount', won't work (because
  the guest's disk isn't being used; you're booting off a CD!).  However, the live environment's filesystem (the
  unpacked equivalent of the squashfs image in the ISO) is there for you to inspect (at BASE_PATH, right where it was
  built); you don't need direct access to the running guest!

## Nanual testing checklist

- Consoles

  - On the first virtual terminal (tty1), first two hardware serial consoles (ttyS0, ttyS1), and common virtual serial
    consoles (hvc0, others?)  a tty should be present.  If the autologin setting is enabled, agetty should be invoked
    with '--autologin root' so that there is a root shell on each of the above instead of a login prompt.

- Shell

  - If changing the default shell to /bin/zsh, check that we actually get zsh: from a prompt, ZSH_VERSION should be set
    and BASH_VERSION should be unset.  You can also verify that tmp/filesytem/etc/{passwd,adduser.conf} contain
    references to /bin/zsh instead of to /bin/bash.