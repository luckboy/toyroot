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
ROOT_FS_DIR="dist/$ARCH/rootfs"
ROOT_FS_IMG="dist/$ARCH/rootfs.img"

. ./functions.sh

PKGS=""
ALL_PKGS=false
NO_EXTRA_PKGS=false
PKG_SUFFIXES=""
FS_SIZE=65536
FS_INODES=32768
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
		*)
			PKGS="$PKGS $1"
			;;
	esac
	shift
done
[ "$PKGS" = "" -a $ALL_PKGS != true ] && PKGS="$PKGS `cat package_list.txt`"
PKG_SUFFIXES="`echo "$PKG_SUFFIXES" | sed 's/,/ /g'`"

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
mkdir -p "$ROOT_FS_DIR/var/db"
mkdir -p "$ROOT_FS_DIR/var/run"
mkdir -p "$ROOT_FS_DIR/var/tmp"
mkdir -p "$ROOT_FS_DIR/root"
mkdir -p "$ROOT_FS_DIR/home/child"
case "$ARCH" in
	arm)	ln -sf mmcblk0p1 "$ROOT_FS_DIR/dev/root";;
	*)	ln -sf sda1 "$ROOT_FS_DIR/dev/root";;
esac
echo -n > "$ROOT_FS_DIR/etc/mtab"
mkdir -p "$ROOT_FS_DIR/sbin"
chmod 755 "$ROOT_FS_DIR/etc/dhclient-script"
ln -sf /etc/dhclient-script "$ROOT_FS_DIR/sbin/dhclient-script"

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

genext2fs -N "$FS_INODES" -b "$FS_SIZE" -d "$ROOT_FS_DIR" -D device_table.txt -U "$ROOT_FS_IMG"
