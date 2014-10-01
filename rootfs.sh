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

NAME=""
IS_NAME=false
PKGS=""
ALL_PKGS=false
NO_EXTRA_PKGS=false
PKG_SUFFIXES=""
FS_SIZE=65536
FS_INODES=32768
ROOT_DEV=""
IS_ROOT_DEV=false
ROOT_FS_KIND=rootfs
READ_ONLY=false
NO_BOOT=false
NO_KERNEL=false
VIDEO=""
IS_VIDEO=false
while [ $# -gt 0 ]; do
	case "$1" in
		--name=*)
			NAME="`echo "$1" | sed 's/^[^=]*=//'`"
			IS_NAME=true
			;;
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
		--root-dev=*)
			ROOT_DEV="`echo "$1" | sed 's/^[^=]*=//'`"
			IS_ROOT_DEV=true
			;;
		--initrd)
			ROOT_FS_KIND=initrd
			;;
		--iso)
			ROOT_FS_KIND=iso
			;;
		--read-only)
			READ_ONLY=true
			;;
		--no-boot)
			NO_BOOT=true
			;;
		--no-kernel)
			NO_KERNEL=true
			;;
		--video)
			VIDEO=cirrusfb:800x600-16
			IS_VIDEO=true
			;;
		--video=*)
			VIDEO="`echo "$1" | sed 's/^[^=]*=//'`"
			IS_VIDEO=true
			;;

		*)
			PKGS="$PKGS $1"
			;;
	esac
	shift
done
if [ $IS_NAME != true ]; then
	case $ROOT_FS_KIND in
		initrd)	NAME=initrd;;
		iso)	NAME=iso;;
		*)	NAME=root;;
	esac
fi
PKG_SUFFIXES="`echo "$PKG_SUFFIXES" | sed 's/,/ /g'`"
[ $ROOT_FS_KIND = iso ] && READ_ONLY=true
[ $ROOT_FS_KIND = initrd ] && NO_KERNEL=true
[ "$PKGS" = "" -a $ALL_PKGS != true ] && PKGS="$PKGS `cat package_list.txt`"

ROOT_FS_DIR="dist/$ARCH/fs/$NAME"
ROOT_FS_IMG="dist/$ARCH/fs/$NAME.img"
case $ROOT_FS_KIND in
	initrd)	ROOT_FS_TYPE=rootfs;;
	iso)	ROOT_FS_TYPE=iso9660;;
	*)	ROOT_FS_TYPE=ext2;;
esac
PROFILE_DIR="profile/$NAME"

#
# A root file system.
#

mkdir -p "$ROOT_FS_DIR"
[ $ROOT_FS_KIND = initrd ] && ln -sf /sbin/init "$ROOT_FS_DIR/init"
cp -drp etc "$ROOT_FS_DIR"
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
mkdir "$ROOT_FS_DIR/xdg"
mkdir -p "$ROOT_FS_DIR/root"
mkdir -p "$ROOT_FS_DIR/home/child"
# Copies the profile directory to the /etc directory.
[ -d "$PROFILE_DIR" ] && cp -drpT "$PROFILE_DIR" "$ROOT_FS_DIR/etc"

#
# A /etc directory.
#

[ $READ_ONLY = true ] && ROOT_FS_OPTS=ro
if [ ! -e "$ROOT_FS_DIR/etc/fstab" ]; then
	cat "$ROOT_FS_DIR/etc/fstab.head" > "$ROOT_FS_DIR/etc/fstab"
	ROOT_FS_OPTS=defaults
	[ $READ_ONLY = true ] && ROOT_FS_OPTS=ro
	if [ $ROOT_FS_KIND != initrd ]; then
		cat >> "$ROOT_FS_DIR/etc/fstab" <<EOT
/dev/root	/		$ROOT_FS_TYPE		$ROOT_FS_OPTS	0	1
EOT
	else
		cat >> "$ROOT_FS_DIR/etc/fstab" <<EOT
rootfs		/		$ROOT_FS_TYPE		$ROOT_FS_OPTS	0	1
EOT
	fi
	if [ $READ_ONLY = true ]; then
		cat >> "$ROOT_FS_DIR/etc/fstab" <<EOT
tmpfs		/root		tmpfs		mode=755	0	0
tmpfs		/home/child	tmpfs		uid=1000,gid=1000,mode=755	0	0	
tmpfs		/tmp		tmpfs		mode=1777	0	0
tmpfs		/var		tmpfs		mode=755	0	0
EOT
	fi
	cat "$ROOT_FS_DIR/etc/fstab.tail" >> "$ROOT_FS_DIR/etc/fstab"
fi
if [ $READ_ONLY != true ]; then
	echo -n > "$ROOT_FS_DIR/etc/mtab"
else
	ln -sf /proc/mounts "$ROOT_FS_DIR/etc/mtab"
	ln -sf /var/etc/resolv.conf "$ROOT_FS_DIR/etc/resolv.conf"
fi

#
# A /sbin directory.
#

mkdir -p "$ROOT_FS_DIR/sbin"
chmod 755 "$ROOT_FS_DIR/etc/dhclient-script"
ln -sf /etc/dhclient-script "$ROOT_FS_DIR/sbin/dhclient-script"

#
# A kernel and a /boot/ directory.
#

if [ $NO_KERNEL != true ]; then
	K_PKG_ROOT_DIR="$ROOT_FS_DIR"
	install_kernel_package
	if [ $NO_BOOT != true ]; then
		case "$ARCH" in
			i[3-9]86|x86_64)
				KERNEL_ARG_VIDEO=""
				[ $IS_VIDEO = true ] && KERNEL_ARG_VIDEO="video=$VIDEO";
				if [ $IS_ROOT_DEV != true ]; then
					if [ $ROOT_FS_KIND != iso ]; then
						ROOT_DEV=/dev/sda1
					else
						ROOT_DEV=/dev/sr0
					fi
				fi
				mkdir -p "$ROOT_FS_DIR/boot/grub"
				cat > "$ROOT_FS_DIR/boot/grub/menu.lst" <<EOT
default 0
timeout 0
hiddenmenu
title Toyroot
	kernel $K_PKG_KERNEL_FILE root=$ROOT_DEV rootfstype=$ROOT_FS_TYPE logo.nologo devtmpfs.mount=1 $KERNEL_ARG_VIDEO
EOT
				if [ $ROOT_FS_KIND != iso ]; then
					for name in stage1 e2fs_stage1_5 stage2; do
						cp -dp "bin/$ARCH/grub/usr/lib/grub/i386-pc/$name" "$ROOT_FS_DIR/boot/grub"
					done
				else
					cp -dp "bin/$ARCH/grub/usr/lib/grub/i386-pc/stage2_eltorito" "$ROOT_FS_DIR/boot/grub"
				fi
				;;
		esac
	fi
fi

#
# Packages.
#

NX_PKG_ROOT_DIR="$ROOT_FS_DIR"
install_non_extra_packages
if [ "$PKG_SUFFIXES" != "" ]; then
	for sfx in $PKG_SUFFIXES; do
		install_non_extra_packages_with_suffix "$sfx"
	done
fi

PKG_ROOT_DIR="$ROOT_FS_DIR"
process_extra_packages install_extra_package
process_extra_packages configure_extra_package
select_programs
install_all_infos

#
# A root image.
#

case $ROOT_FS_KIND in
	initrd)
		chmod 1777 "$ROOT_FS_DIR/tmp"
		SAVED_PWD="`pwd`"
		cd "$ROOT_FS_DIR"
		find ./ | sed '/.\/home\/child/d' | cpio -H newc -R 0:0 -o > "$SAVED_PWD/dist/$ARCH/fs/$NAME.tmp"
		echo ./home/child | cpio -A -H newc -R 1000:1000 -F "$SAVED_PWD/dist/$ARCH/fs/$NAME.tmp" -o
		cd "$SAVED_PWD"
		cat "dist/$ARCH/fs/$NAME.tmp" | gzip -9c > "$SAVED_PWD/$ROOT_FS_IMG"
		rm -f "dist/$ARCH/fs/$NAME.tmp"
		chmod 755 "$ROOT_FS_DIR/tmp"
		;;
	iso)
		MKISOFS_OPTS_ARCH=""
		case "$ARCH" in
			i[3-9]86|x86_64)
				MKISOFS_OPTS_ARCH="-b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table"
				;;
		esac
		mkisofs -uid 0 -gid 0 -R $MKISOFS_OPTS_ARCH -o "$ROOT_FS_IMG" "$ROOT_FS_DIR"
		;;
	*)
		genext2fs -N "$FS_INODES" -b "$FS_SIZE" -d "$ROOT_FS_DIR" -D device_table.txt -U "$ROOT_FS_IMG"
		;;
esac
exit 0
