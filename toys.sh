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

MUSL_VERSION=1.0.3
NCURSES_VERSION=5.9
LIBEDIT_VERSION=20140213-3.1
SYSVINIT_VERSION=2.88dsf
DASH_VERSION=0.5.7
TOYBOX_VERSION=0.4.8
UTIL_LINUX_VERSION=2.24.2

GCC=${GCC:=gcc}

ROOT_DIR=`pwd`
TARGET=`$GCC -dumpmachine`
HOST=`gcc -dumpmachine`
ARCH=`$GCC -dumpmachine | cut -d - -f 1`
STRIP=strip
INCLUDE_DIR=/usr/include
if [ $TARGET != $HOST ]; then
	STRIP=$TARGET-strip
	INCLUDE_DIR=/usr/$TARGET/include
fi

ASM_INCLUDE_DIR=$INCLUDE_DIR/asm
ASM_GENERIC_INCLUDE_DIR=$INCLUDE_DIR/asm-generic
LINUX_INCLUDE_DIR=$INCLUDE_DIR/linux

MUSL_GCC=$ROOT_DIR/bin/$ARCH/musl/bin/musl-gcc

patch_package() {
	for p in `ls patch/$2-*.patch 2> /dev/null`; do
		patch -p1 -d build/$ARCH/$1 < $p
	done
}

export REALGCC=$GCC

mkdir -p src build/$ARCH bin/$ARCH

[ -f src/musl-$MUSL_VERSION.tar.gz ] || wget -P src http://www.musl-libc.org/releases/musl-$MUSL_VERSION.tar.gz
[ -f src/ncurses-$NCURSES_VERSION.tar.gz ] || wget -P src ftp://invisible-island.net/ncurses/ncurses-$NCURSES_VERSION.tar.gz
[ -f src/libedit-$LIBEDIT_VERSION.tar.gz ] || wget -P src http://thrysoee.dk/editline/libedit-$LIBEDIT_VERSION.tar.gz
[ -f src/sysvinit-$SYSVINIT_VERSION.tar.bz2 ] || wget -P src http://download.savannah.gnu.org/releases/sysvinit/sysvinit-$SYSVINIT_VERSION.tar.bz2
[ -f src/dash-$DASH_VERSION.tar.gz ] || wget -P src http://gondor.apana.org.au/~herbert/dash/files/dash-$DASH_VERSION.tar.gz
[ -f src/toybox-$TOYBOX_VERSION.tar.bz2 ] || wget -P src http://www.landley.net/toybox/downloads/toybox-$TOYBOX_VERSION.tar.bz2
[ -f src/util-linux-$UTIL_LINUX_VERSION.tar.xz ] || wget -P src https://www.kernel.org/pub/linux/utils/util-linux/v`echo $UTIL_LINUX_VERSION | cut -d . -f 1,2`/util-linux-$UTIL_LINUX_VERSION.tar.xz

for p in musl ncurses libedit sysvinit dash toybox util-linux; do
	mkdir -p build/$ARCH/$p
done

[ -d build/$ARCH/musl/musl-$MUSL_VERSION ] || (tar zxf src/musl-$MUSL_VERSION.tar.gz -C build/$ARCH/musl && patch_package musl musl-$MUSL_VERSION)
[ -d build/$ARCH/ncurses/ncurses-$NCURSES_VERSION ] || (tar zxf src/ncurses-$NCURSES_VERSION.tar.gz -C build/$ARCH/ncurses && patch_package ncurses ncurses-$NCURSES_VERSION)
[ -d build/$ARCH/libedit/libedit-$LIBEDIT_VERSION ] || (tar zxf src/libedit-$LIBEDIT_VERSION.tar.gz -C build/$ARCH/libedit && patch_package libedit libedit-$LIBEDIT_VERSION)
[ -d build/$ARCH/sysvinit/sysvinit-$SYSVINIT_VERSION ] || (tar jxf src/sysvinit-$SYSVINIT_VERSION.tar.bz2 -C build/$ARCH/sysvinit && patch_package sysvinit sysvinit-$SYSVINIT_VERSION)
[ -d build/$ARCH/dash/dash-$DASH_VERSION ] || (tar zxf src/dash-$DASH_VERSION.tar.gz -C build/$ARCH/dash && patch_package dash dash-$DASH_VERSION)
[ -d build/$ARCH/toybox/toybox-$TOYBOX_VERSION ] || (tar jxf src/toybox-$TOYBOX_VERSION.tar.bz2 -C build/$ARCH/toybox && patch_package toybox toybox-$TOYBOX_VERSION)
[ -d build/$ARCH/util-linux/util-linux-$UTIL_LINUX_VERSION ] || (tar Jxf src/util-linux-$UTIL_LINUX_VERSION.tar.xz -C build/$ARCH/util-linux && patch_package util-linux util-linux-$UTIL_LINUX_VERSION)

if [ ! -d $ROOT_DIR/bin/$ARCH/musl ]; then
	cd build/$ARCH/musl/musl-$MUSL_VERSION
	make clean
	(CC=$GCC ./configure --prefix=$ROOT_DIR/bin/$ARCH/musl $TARGET && make install) || exit 1
	ln -sf $ASM_INCLUDE_DIR $ASM_GENERIC_INCLUDE_DIR $LINUX_INCLUDE_DIR $ROOT_DIR/bin/$ARCH/musl/include
	cd ../../../..
fi
echo $TARGET $HOST
if [ ! -d $ROOT_DIR/bin/$ARCH/ncurses ]; then
	cd build/$ARCH/ncurses/ncurses-$NCURSES_VERSION
	make clean
	(CC=$MUSL_GCC ./configure --target=$TARGET --host=$TARGET --prefix=/usr --with-shared --without-debug --without-cxx --without-cxx-binding --without-ada --with-normal && make install DESTDIR=$ROOT_DIR/bin/$ARCH/ncurses) || exit 1
	cd ../../../..
fi
if [ ! -d $ROOT_DIR/bin/$ARCH/libedit ]; then
	cd build/$ARCH/libedit/libedit-$LIBEDIT_VERSION
	make clean
	(CC=$MUSL_GCC CFLAGS="-I$ROOT_DIR/bin/$ARCH/ncurses/usr/include -I$ROOT_DIR/bin/$ARCH/ncurses/usr/include/ncurses" LDFLAGS=-L$ROOT_DIR/bin/$ARCH/ncurses/usr/lib ./configure --host=$TARGET --prefix=/usr && make install DESTDIR=$ROOT_DIR/bin/$ARCH/libedit) || exit 1
	cd ../../../..
fi
if [ ! -d $ROOT_DIR/bin/$ARCH/sysvinit ]; then
	cd build/$ARCH/sysvinit/sysvinit-$SYSVINIT_VERSION
	make clean
	make CC=$MUSL_GCC LDFLAGS=-s ROOT=$ROOT_DIR/bin/$ARCH/sysvinit DISTRO=Toyroot all install || exit 1
	rm -fr $ROOT_DIR/bin/$ARCH/sysvinit/usr/include
	cd ../../../..
fi
if [ ! -d $ROOT_DIR/bin/$ARCH/dash ]; then
	cd build/$ARCH/dash/dash-$DASH_VERSION
	make clean
	(CC=$MUSL_GCC CFLAGS="-I$ROOT_DIR/bin/$ARCH/ncurses/usr/include -I$ROOT_DIR/bin/$ARCH/ncurses/usr/include/ncurses -I$ROOT_DIR/bin/$ARCH/libedit/usr/include" LDFLAGS="-L$ROOT_DIR/bin/$ARCH/ncurses/usr/lib -L$ROOT_DIR/bin/$ARCH/libedit/usr/lib -s" LIBS="-ledit -lncurses" ./configure --host=$TARGET --prefix=/ --datarootdir=/usr/share --with-libedit && make install CC_FOR_BUILD=gcc DESTDIR=$ROOT_DIR/bin/$ARCH/dash) || exit 1
	cd ../../../..
fi
if [ ! -d $ROOT_DIR/bin/$ARCH/toybox ]; then
	cd build/$ARCH/toybox/toybox-$TOYBOX_VERSION
	make clean
	cp $ROOT_DIR/toybox.config .config
	make CC=$MUSL_GCC STRIP=$STRIP PREFIX=$ROOT_DIR/bin/$ARCH/toybox all install || exit 1
	cd ../../../..
fi
if [ ! -d $ROOT_DIR/bin/$ARCH/util-linux ]; then
	cd $ROOT_DIR/bin/$ARCH/toybox
	TOYBOX_FILES=`find`
	cd ../../..
	cd build/$ARCH/util-linux/util-linux-$UTIL_LINUX_VERSION
	make clean
	find 
	(CC=$MUSL_GCC CFLAGS="-I$ROOT_DIR/bin/$ARCH/ncurses/usr/include -I$ROOT_DIR/bin/$ARCH/ncurses/usr/include/ncurses" LDFLAGS="-L$ROOT_DIR/bin/$ARCH/ncurses/usr/lib -lc -s" LIBS="-lncurses" ./configure --host=$TARGET --prefix=/usr --sysconfdir=/etc \
		--enable-shared \
		--disable-static \
		--disable-losetup \
		--disable-cytune \
		--disable-partx \
		--disable-uuidd \
		--disable-mountpoint \
		--disable-fallocate \
		--disable-unshare \
		--disable-nsenter \
		--disable-setpriv \
		--disable-eject \
		--disable-agetty \
		--disable-cramfs \
		--disable-bfs \
		--disable-fdformat \
		--disable-hwclock \
		--disable-wdctl \
		--disable-switch_root \
		--disable-pivot_root \
		--disable-kill \
		--disable-last \
		--disable-utmpdump \
		--disable-mesg \
		--disable-raw \
		--disable-rename \
		--disable-login \
		--disable-nologin \
		--disable-runuser \
		--disable-ul \
		--disable-more \
		--disable-pg \
		--disable-schedutils \
		--disable-wall \
		--without-systemdsystemunitdir \
		PKG_CONFIG="" \
		&& make install DESTDIR=$ROOT_DIR/bin/$ARCH/util-linux) || exit 1
	for file in $TOYBOX_FILES; do
		[ -e "$ROOT_DIR/bin/$ARCH/util-linux/$file" -a ! -d "$ROOT_DIR/bin/$ARCH/util-linux/$file" ] && rm -f "$ROOT_DIR/bin/$ARCH/util-linux/$file"
	done
	rm -fr $ROOT_DIR/bin/$ARCH/util-linux/usr/include
	rm -f $ROOT_DIR/bin/$ARCH/util-linux/usr/lib/*.la
	rm -fr $ROOT_DIR/bin/$ARCH/util-linux/usr/lib/pkgconfig
	rm -fr $ROOT_DIR/bin/$ARCH/util-linux/usr/share/bash-completion
	rm -fr $ROOT_DIR/bin/$ARCH/util-linux/usr/share/doc
	cd ../../../..
fi

