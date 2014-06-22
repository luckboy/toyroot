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
# 3. Neither the name of the University nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
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

mkdir -p "$ROOT_FS_DIR"
cp -drP etc/ "$ROOT_FS_DIR"
chmod 755 "$ROOT_FS_DIR/etc/rcS"
chmod 755 "$ROOT_FS_DIR/etc/rc.shutdown"
chmod 755 "$ROOT_FS_DIR/etc/init.d/network"
ln -s ../init.d/network "$ROOT_FS_DIR/etc/rc.d/S10network"
ln -s ../init.d/network "$ROOT_FS_DIR/etc/rc.d/K10network"
chmod 755 "$ROOT_FS_DIR/etc/dhcp.script"
mkdir -p "$ROOT_FS_DIR/dev"
mkdir -p "$ROOT_FS_DIR/proc"
mkdir -p "$ROOT_FS_DIR/sys"
mkdir -p "$ROOT_FS_DIR/tmp"
mkdir -p "$ROOT_FS_DIR/var/run"
mkdir -p "$ROOT_FS_DIR/root"
mkdir -p "$ROOT_FS_DIR/home/child"
case "$ARCH" in
	arm)	ln -sf mmcblk0p1 "$ROOT_FS_DIR/dev/root";;
	*)	ln -sf sda1 "$ROOT_FS_DIR/dev/root";;
esac
echo -n > "$ROOT_FS_DIR/etc/mtab"

mkdir -p "$ROOT_FS_DIR/lib"
cp -dP "bin/$ARCH/musl/lib"/*.so "$ROOT_FS_DIR/lib"
echo /lib:/usr/lib > "$ROOT_FS_DIR/etc/ld-musl-$ARCH.path"
ln -s libc.so "$ROOT_FS_DIR/lib/ld-musl-$ARCH.so.1"

for libpkg in ncurses libedit; do
	[ -d "bin/$ARCH/$libpkg/lib" ] && mkdir -p "$ROOT_FS_DIR/lib" && cp -drP "bin/$ARCH/$libpkg/lib"/lib*.so "bin/$ARCH/$libpkg/lib"/lib*.so.* "$ROOT_FS_DIR/lib"
	[ -d "bin/$ARCH/$libpkg/usr/lib" ] && mkdir -p "$ROOT_FS_DIR/usr/lib" && cp -drP "bin/$ARCH/$libpkg/usr/lib"/lib*.so "bin/$ARCH/$libpkg/usr/lib"/lib*.so.* "$ROOT_FS_DIR/usr/lib"
done
mkdir -p "$ROOT_FS_DIR/usr/share"
cp -drP "bin/$ARCH/ncurses/usr/share"/* "$ROOT_FS_DIR/usr/share"

for pkg in sysvinit dash toybox util-linux; do
	cp -drP "bin/$ARCH/$pkg"/* "$ROOT_FS_DIR"
done
ln -sf dash "$ROOT_FS_DIR/bin/sh"

if [ -f packages.txt ]; then
	cat packages.txt | (while read line; do
		case $line in
			"#"*)	;;
			"")	;;
			*)	install_extra_package $line;;
		esac
	done)
fi

genext2fs -N 16386 -b 32768 -d "$ROOT_FS_DIR" -D device_table.txt -U "$ROOT_FS_IMG"

