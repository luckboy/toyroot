# Toyroot 

This build system is build system to build small linux distribution. This distribution is based musl C library and
toybox. This distribution can be compiled on ARM and x86_64 and tested on qemu emulator. You can build and run your
small linux distribution by invoke commands:

        ./kernel.sh # compile kernel
        ./toys.sh # compile programs (toys)
        ./rootfs.sh # generate root file system
        ./play.sh # run built system on qemu emulator

The built system automatically configure network for the ethernet card. You can choose the static network
configuration or the dynamic network configuration by the DHCP client. The configuration network is at
the /etc/network.conf file.

## Packages

The built system contains the following core packages:

  * musl
  * ncurses
  * libedit
  * sysvinit
  * iputils (ping and ping6)
  * dchp-client (DHCP client)
  * dash
  * toybox
  * util-linux-mount (mount and umount)
  * uClibc++-build (only to build)
  * shadow-login (login)
  * grub-host (grub for host)

You can choose packages by editing of the package_list.txt file. The packages.txt file contains the descriptions
of all extra packages which may be in built system.

## Package suffixes

Any package can have the additional packages with the suffixes. The package suffix specifies the type of
the additional package. The package suffixes:

  * man - manuals and infos
  * doc - documentation
  * dev - headers and static libraries
  
## Scripts

This build system contains scripts:

  * kernel.sh - compile kernel
  * toys.sh - compile programs (toys)
  * rootfs.sh - generate root file system
  * disk.sh - generate disk image
  * play.sh - run built system on qemu emulator
  * clean.sh - remove work directories without sources

## Directories

The toyroot directory contains the following subdirectories:

  * etc - configuration directory
  * patch - directory with patches

After compilation, this directory also contains the subdirectories:

  * src - directory of downloaded files
  * build - building directory
  * bin - directory of binary packages
  * kernel_config -  directory of kernel configurations
  * profile - directory of system configuration for specified profiles

After generating of root file system, the directory also contains the subdirectory:

  * dist - directory with root file system directory and image of root file system

## Profiles

Profles allow you to build many systems. The `rootfs.sh` script and the `disk.sh` script  generate the root file
system and the disk image for the specified profile. Any profile can have the root file system and/or the disk image.
The profile is specified by pass the `--name` option with the profile name. You can build the system for
own profile, and then run this system by invoke commands: 

        ./rootfs.sh --name=myprofile # generate root file system for your profile
        ./disk.sh --name=myprofile # generate disk image for your profile
        ./play --name=myprofile --disk # run system on disk image for your profile

You also create the specific files of the /etc directory for any profile. Any profile can have the system configuration at the profile/&lt;profile name&gt; directory. This build system has three default profiles:

  * root - profile for hard disk
  * initrd - profile for initrd
  * iso - profile for CDROM

Example:


## Compilation of kernel

You can compile the kernel by invoke `./kernel.sh`. This script will automatically download the kernel source
and then compile it.

Usage of this script:
  
        [GCC=<c compiler>] [PLATFORM=<platform for linux>] ./kernel.sh [<option> ...]
        
Options of this scirpt:

        --custom-config                 compile with the custom configuration. If the custom 
                                        configuration is nonexistent, this script invokes 
                                        the manual configuration with the default settings.
        --only-custom-config            same as --custom-config but without the default
                                        settings.
        --force-menuconfig              force the manual configuration.

Example:

        GCC=arm-linux-gnueabi-gcc PLATFORM=vexpress ./kernel.sh # compile for vexpress

## Compilation of programs (toys)
    
If you want compile the packages, you can do it by invoke `./toys.sh`. Also this script automatically download
the sources of the packages. This script compiles the non-extra packages and the extra packages from the
package_list.txt file. If you doesn't want compile the extra packages form this list file, you can pass the extra
packages as the arguments and/or the package list files with them. You also can compile only non-extra packages 
or all packages.

Usage of this script:
    
        [GCC=<c compiler>] ./toys.sh [<option> ...] [<package> ...]

Options of this script:

        --pkg-list-file[=<list file>]   add packages to compilation from a list file
                                        (default: package-list.txt).
        --all-pkgs                      compile all packages.
        --no-extra-pkgs                 just compile non-extra packages.

Example:

        GCC=arm-linux-gnueabi-gcc ./toys.sh # compile for ARM

## Generating of root file system

You can generate the root file system by invoke `./rootfs.sh`. This script generates the root file system with
the non-extra packages and the extra packages from the package-list.txt file. If you doesn't want generate built
system without the extra packages from the package_list.txt file, you can pass the extra packages as the
arguments and/or the package list files with them. You also can generate the root file system with only or all
packages.

Usage of this script:

        [ARCH=<architecture>] ./rootfs.sh [<option> ...] [<package> ...]

Options of this script:

        --name=<name>                   specify the profile name.
        --pkg-list-file[=<list file>]   add packages to the root file system from a list 
                                        file (default: package-list.txt).
        --all-pkgs                      generate the root file system with all packages.
        --no-extra-pkgs                 generate the root file system with only non-extra 
                                        packages.
        --pkg-suffixes=<suffix>,...     add additional packages with specified suffixes onto
                                        the root file system.
        --fs-size=<size>                specify the size of the root file system in blocks.
        --fs-inodes=<nodes>             specify the number of i-nodes of the root file
                                        system.
        --root-dev=<device>             specify the device of the root file system.
        --initrd                        generate the root file system for initrd.
        --iso                           generate the root file system for CDROM.
        --read-only                     generate the read-only root file system.
        --no-boot                       don't copy the bootloader files to the root file 
                                        system and don't install the bootloader for CDROM.
        --no-kernel                     don't copy the kernel to the root file system.
        --video=[<mode>]                add a video mode to the kernel arguments (default:
                                        cirrusfb:800x600-16)

Example:

        ARCH=arm ./toys.sh # generate root file system for ARM

## Generating of disk image

You can generate disk image with built system by invoke ./disk.sh. This script generates the disk image from
the generated root file system.

Usage of this script:

        [ARCH=<architecture>] ./disk.sh

Options of the script:

        --name=<name>                   specify the profile name.
        --disk-size=<size>              specify the size of the disk image in sectors.
        --fs-size=<size>                specify the size of the root file system in sectors.
        --cylinders=<cylinders>         specify the cylinders of the disk.
        --heads=<heads>                 specify the heads of the disk.
        --sectors=<sectors>             specify the sectors of the disk.
        --grub-dev=<decive>             specify the disk device for grub (default: (hd0)).
        --no-boot                       don't install bootloader on the disk image.

Example:

        ./disk.sh # generate disk image.

## Running of system

If you want run your system on qemu emulator, you can do it by invoke `./play.sh`.

Usage of this script:

        ./play.sh <architecture> [<machine for qemu>]

Options of this script:

        --name=<name>                  specify the profile name.
        --disk                         run system from disk image (only for x86_64).
        --initrd                       run system from initrd file system.
        --iso                          run system from CDROM image (only for x86_64).
        --video=[<mode>]                add a video mode to the kernel arguments (default:
                                        cirrusfb:800x600-16)
    
Example:

        ./play.sh arm vexpress-a9 # run system on qemu-system-arm

## Cleaning 

You can remove the building directories and root file systems by invoke `./clean.sh`. If you pass arguments, 
`clean.sh` just removes the specified packages from the building directory and the directory with packages. If
you uses the `--only-dist` option, `clean.sh` just removes the dist directory.

Usage of this script:

        ./clean.sh [<option> ...] [<package> ...]

Options of this script:

        --only-dist                     just remove the dist directory.
