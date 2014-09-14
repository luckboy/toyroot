#!/bin/sh
# Copyright (c) 2014 Łukasz Szpakowski.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS''
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

ARCH="${ARCH:=`arch`}"

. ./functions.sh

PKGS=""
ALL_PKGS=false
NO_EXTRA_PKGS=false
PKG_SUFFIXES=""
FS_SIZE=65536
FS_INODES=32768
IS_FS_NAME=false
FS_NAME=""
ISO=false
READ_ONLY=false
ETC_HOSTNAME=toyroot.qemunet
while [ $# -gt 0 ]; do
	case "$1" in
		--pkg-list-file)
			PKGS="$PKGS `cat package_list.txt`"
			;;
		--pkg-list-file=*)
			PKG_LIST_FILE="`echo "$1" | sed 's/^[^=]*=//'`"
			PKGS="$PKGS `cat "$PKG_LIST_FILE"`"
			;;
		--all-pkgs)
			ALL_PKGS=true
			;;
		--no-extra-pkgs)
			NO_EXTRA_PKGS=true
			;;
		--pkg-suffixes=*)
			PKG_SUFFIXES="`echo "$1" | sed 's/^[^=]*=//'`"
			;;
		--fs-size=*)
			FS_SIZE="`echo "$1" | sed 's/^[^=]*=//'`"
			;;
		--fs-inodes=*)
			FS_INODES="`echo "$1" | sed 's/^[^=]*=//'`"
			;;
		--fs-name=*)
			FS_NAME="`echo "$1" | sed 's/^[^=]*=//'`"
			IS_FS_NAME=true
			;;
		--iso)
			ISO=true
			;;
		--read-only)
			READ_ONLY=true
			;;
		--hostname=*)
			ETC_HOSTNAME="`echo "$1" | sed 's/^[^=]*=//'`"
			;;
		*)
			PKGS="$PKGS $1"
			;;
	esac
	shift
done
PKG_SUFFIXES="`echo "$PKG_SUFFIXES" | sed 's/,/ /g'`"
if [ $IS_FS_NAME != true ]; then
	if [ $ISO != true ]; then
		FS_NAME=root
	else
		FS_NAME=iso
	fi
fi
[ $ISO = true ] && READ_ONLY=true
[ "$PKGS" = "" -a $ALL_PKGS != true ] && PKGS="$PKGS `cat package_list.txt`"

ROOT_FS_DIR="dist/$ARCH/fs/$FS_NAME"
ROOT_FS_IMG="dist/$ARCH/fs/$FS_NAME.img"

mkdir -p "$ROOT_FS_DIR"
cp -drp etc/ "$ROOT_FS_DIR"
chmod 755 "$ROOT_FS_DIR/etc/rcS"
chmod 755 "$ROOT_FS_DIR/etc/rc.shutdown"
chmod 755 "$ROOT_FS_DIR/etc/init.d/network"
ln -s ../init.d/network "$ROOT_FS_DIR/etc/rc.d/S10network"
ln -s ../init.d/network "$ROOT_FS_DIR/etc/rc.d/K10network"
chmod 600 "$ROOT_FS_DIR/etc/shadow"
mkdir -p "$ROOT_FS_DIR/dev"
mkdir -p "$ROOT_FS_DIR/proc"
mkdir -p "$ROOT_FS_DIR/sys"
mkdir -p "$ROOT_FS_DIR/tmp"
if [ $READ_ONLY != true ]; then
	mkdir -p "$ROOT_FS_DIR/var/db"
	mkdir -p "$ROOT_FS_DIR/var/run"
	mkdir -p "$ROOT_FS_DIR/var/tmp"
else
	mkdir -p "$ROOT_FS_DIR/var"
fi
mkdir -p "$ROOT_FS_DIR/root"
mkdir -p "$ROOT_FS_DIR/home/child"

echo "$ETC_HOSTNAME" > "$ROOT_FS_DIR/etc/hostname"
cat "$ROOT_FS_DIR/etc/fstab.head" > "$ROOT_FS_DIR/etc/fstab"
ROOT_FS_OPTS=defaults
[ $READ_ONLY = true ] && ROOT_FS_OPTS=ro
if [ $ISO != true ]; then
	cat >> "$ROOT_FS_DIR/etc/fstab" << EOT
/dev/root	/		ext2		$ROOT_FS_OPTS	0	1
EOT
else
	cat >> "$ROOT_FS_DIR/etc/fstab" << EOT
/dev/root	/		iso9660		$ROOT_FS_OPTS	0	0
EOT
fi
if [ $READ_ONLY = true ]; then
	cat >> "$ROOT_FS_DIR/etc/fstab" << EOT
tmpfs		/root		tmpfs		mode=755	0	0
tmpfs		/home/child	tmpfs		uid=1000,gid=1000,mode=755	0	0	
tmpfs		/tmp		tmpfs		mode=1777	0	0
tmpfs		/var		tmpfs		mode=755	0	0
EOT
fi
cat "$ROOT_FS_DIR/etc/fstab.tail" >> "$ROOT_FS_DIR/etc/fstab"

if [ $READ_ONLY != true ]; then
	echo -n > "$ROOT_FS_DIR/etc/mtab"
else
	ln -sf /proc/mounts "$ROOT_FS_DIR/etc/mtab"
	ln -sf /var/etc/resolv.conf "$ROOT_FS_DIR/etc/resolv.conf"
fi
mkdir -p "$ROOT_FS_DIR/sbin"
chmod 755 "$ROOT_FS_DIR/etc/dhclient-script"
ln -sf /etc/dhclient-script "$ROOT_FS_DIR/sbin/dhclient-script"

K_PKG_ROOT_DIR="$ROOT_FS_DIR"
install_kernel_package
if [ $ISO = true ]; then
	case "$ARCH" in
		i[3-9]86|x86_64)
			mkdir -p "$ROOT_FS_DIR/boot/grub" 
			cat > "$ROOT_FS_DIR/boot/grub/menu.lst" <<EOT
default 0
timeout 0
hiddenmenu
title Toyroot
	kernel $K_PKG_KERNEL_FILE root=/dev/sr0 devtmpfs.mount=1
EOT
			cp -dp "bin/$ARCH/grub/usr/lib/grub/$ARCH-pc/stage2_eltorito" "$ROOT_FS_DIR/boot/grub"
			;;
	esac
fi
NX_PKG_ROOT_DIR="$ROOT_FS_DIR"
install_non_extra_packages
if [ "$PKG_SUFFIXES" != "" ]; then
	for sfx in $PKG_SUFFIXES; do
		install_non_extra_packages_with_suffix "$sfx"
	done
fi

PKG_ROOT_DIR="$ROOT_FS_DIR"
process_extra_packages install_extra_package
select_programs
install_all_infos

if [ $ISO != true ]; then
	genext2fs -N "$FS_INODES" -b "$FS_SIZE" -d "$ROOT_FS_DIR" -D device_table.txt -U "$ROOT_FS_IMG"
else
	MKISOFS_OPTS_ARCH=""
	case "$ARCH" in
		i[3-9]86|x86_64)
			MKISOFS_OPTS_ARCH="-b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table"
			;;
	esac
	mkisofs -r $MKISOFS_OPTS_ARCH -o "$ROOT_FS_IMG" "$ROOT_FS_DIR"
fi
exit 0
