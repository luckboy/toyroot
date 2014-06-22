# Toyroot 

This build system is build system to build small linux distribution. This distribution is based  musl and toybox.
This distribution was compiled on ARM and x86_64 and tested on qemu emulator. You can build and run your small
linux distribution by invoke commands:

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
  * dash
  * toybox
  * util-linux (with selected programs)

You can choose packages by comment line of packages.txt. The packages.txt file contains the descriptions of
extra packages. The extra packages:

  * gzip
  * bzip2
  * tar
  * less
  * nano (editor)
  * nvi (vi editor)
  * openssl
  * wget
  * links (www browser)
  * tnftp (ftp client)
  
## Scripts

This build system contains scripts:

  * kernel.sh - compile kernel
  * toys.sh - compile programs (toys)
  * rootfs.sh - generate root file system
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

After generating of root file system, the directory also contains the subdirectory:

  * dist - directory with root file system directory and image of root file system

## Compilation of kernel

You can compile the kernel by invoke `./kernel.sh`. This script will automatically download the kernel source
and then compile it. Usage of this script:
  
        [GCC=<c compiler>] [PLATFORM=<platform for linux>] ./kernel.sh

Example:

        GCC=arm-linux-gnueabi-gcc PLATFORM=vexpress ./kernel.sh # compile for vexpress

## Compilation of programs (toys)
    
If you want compile the programs, you can do it by invoke `./toys.sh`. Also this script automatically download
the sources of the programs. Usage of this script:
    
        [GCC=<c compiler>] ./toys.sh

Example:

        GCC=arm-linux-gnueabi-gcc ./toys.sh # compile for ARM

## Generating of root file system

You can generate the root file system by invoke `./rootfs.sh`. Usage of this script:

        [ARCH=<architecture>] ./rootfs.sh

Example:

        ARCH=arm ./toys.sh # generate root file system for ARM

## Running of system

If you want run your system on qemu emulator, you can do it by invoke `./play.sh`. Usage of this script:

        ./play.sh <architecture> [<machine for qemu>]
    
Example:

        ./play.sh arm vexpress-a9 # run system on qemu-system-arm

## Cleaning 

You can remove the building directories and root file systems by invoke `./clean.sh`. If you pass arguments, 
clean.sh just removes the specified packages from the building directory and the directory with packages. If you
uses the `--only-dist` option, clean.sh just removes the dist directory. Usage of
this script:

        ./clean.sh [<package> ...]

