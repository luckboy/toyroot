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

. ./toys.txt

GCC="${GCC:=gcc}"
GCC_CFLAGS="${CFLAGS:=-Os}"

GXX="`echo "$GCC" | sed -e s/gcc$/g++/`"
OBJCOPY="`echo "$GCC" | sed -e s/gcc$/objcopy/`"
ROOT_DIR="`pwd`"
TARGET="`$GCC -dumpmachine`"
HOST="`gcc -dumpmachine`"
ARCH="`$GCC -dumpmachine | cut -d - -f 1`"
STRIP=strip
INCLUDE_DIR=/usr/include
if [ "$TARGET" != "$HOST" ]; then
	STRIP="$TARGET-strip"
	INCLUDE_DIR="/usr/$TARGET/include"
fi

ASM_INCLUDE_DIR="$INCLUDE_DIR/asm"
ASM_GENERIC_INCLUDE_DIR="$INCLUDE_DIR/asm-generic"
LINUX_INCLUDE_DIR="$INCLUDE_DIR/linux"

MUSL_GCC="$ROOT_DIR/bin/$ARCH/musl/bin/musl-gcc"
GXX_UC="$ROOT_DIR/bin/$ARCH/uClibc++-build/usr/uClibc++/bin/g++-uc"

case "$TARGET" in
	*-*-*eabi)	MUSL_TARGET="`echo "$TARGET" | sed 's/-[^-]*eabi$/-musleabi/'`";;
	*-*-*)		MUSL_TARGET="`echo "$TARGET" | sed 's/-[^-]*$/-musl/'`";;
esac

PKGS=""
ALL_PKGS=false
NO_EXTRA_PKGS=false
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
		*)
			PKGS="$PKGS $1"
			;;
	esac
	shift
done
[ "$PKGS" = "" -a $ALL_PKGS != true ] && PKGS="$PKGS `cat package_list.txt`"

. ./functions.sh

export REALGCC="$GCC"
export WRAPPER_INCLUDEDIR="-I$ROOT_DIR/bin/$ARCH/uClibc++-build/usr/uClibc++/include"
export WRAPPER_LIBDIR="-L$ROOT_DIR/bin/$ARCH/uClibc++-build/usr/uClibc++/lib"

download_source musl-$MUSL_VERSION.tar.gz $MUSL_DOWNLOAD_URL
download_source ncurses-$NCURSES_VERSION.tar.gz $NCURSES_DOWNLOAD_URL
download_source libedit-$LIBEDIT_VERSION.tar.gz $LIBEDIT_DOWNLOAD_URL
download_source sysvinit-$SYSVINIT_VERSION.tar.bz2 $SYSVINIT_DOWNLOAD_URL
download_source dash-$DASH_VERSION.tar.gz $DASH_DOWNLOAD_URL
download_source iputils-$IPUTILS_VERSION.tar.gz $IPUTILS_DOWNLOAD_URL $IPUTILS_VERSION.tar.gz
download_source dhcp-$DHCP_VERSION.tar.gz $DHCP_DOWNLOAD_URL
download_source toybox-$TOYBOX_VERSION.tar.bz2 $TOYBOX_DOWNLOAD_URL
download_source util-linux-$UTIL_LINUX_VERSION.tar.xz $UTIL_LINUX_DOWNLOAD_URL
download_source uClibc++-$UCLIBCXX_VERSION.tar.xz $UCLIBCXX_DOWNLOAD_URL
download_source shadow-$SHADOW_VERSION.tar.xz $SHADOW_DOWNLOAD_URL

extract_and_patch_package musl musl-$MUSL_VERSION.tar.gz musl-$MUSL_VERSION
extract_and_patch_package ncurses ncurses-$NCURSES_VERSION.tar.gz ncurses-$NCURSES_VERSION
extract_and_patch_package libedit libedit-$LIBEDIT_VERSION.tar.gz libedit-$LIBEDIT_VERSION
extract_and_patch_package sysvinit sysvinit-$SYSVINIT_VERSION.tar.bz2 sysvinit-$SYSVINIT_VERSION
extract_and_patch_package dash dash-$DASH_VERSION.tar.gz dash-$DASH_VERSION
extract_and_patch_package iputils iputils-$IPUTILS_VERSION.tar.gz iputils-$IPUTILS_VERSION
extract_and_patch_package dhcp dhcp-$DHCP_VERSION.tar.gz dhcp-$DHCP_VERSION
extract_and_patch_package toybox toybox-$TOYBOX_VERSION.tar.bz2 toybox-$TOYBOX_VERSION
extract_and_patch_package util-linux util-linux-$UTIL_LINUX_VERSION.tar.xz util-linux-$UTIL_LINUX_VERSION
extract_and_patch_package uClibc++ uClibc++-$UCLIBCXX_VERSION.tar.xz uClibc++-$UCLIBCXX_VERSION
extract_and_patch_package shadow shadow-$SHADOW_VERSION.tar.xz shadow-$SHADOW_VERSION

case "$ARCH" in
	i[3-9]86|x86_64)
		download_source grub-$GRUB_VERSION.tar.gz $GRUB_DOWNLOAD_URL
		
		extract_and_patch_package grub grub-$GRUB_VERSION.tar.gz grub-$GRUB_VERSION
		extract_and_patch_package grub-host grub-$GRUB_VERSION.tar.gz grub-$GRUB_VERSION
		;;
esac

mkdir -p "$ROOT_DIR/bin/$ARCH"

if [ ! -d "$ROOT_DIR/bin/$ARCH/musl" ]; then
	cd "build/$ARCH/musl/musl-$MUSL_VERSION"
	[ -f Makefile ] && make clean
	(CC="$GCC" CFLAGS="$GCC_CFLAGS" LDFLAGS=-s ./configure --prefix="$ROOT_DIR/bin/$ARCH/musl" "$TARGET" && make install) || exit 1
	ln -sf $ASM_INCLUDE_DIR $ASM_GENERIC_INCLUDE_DIR $LINUX_INCLUDE_DIR "$ROOT_DIR/bin/$ARCH/musl/include"
	cd ../../../..
	echo -n > "bin/$ARCH/musl.nonextra"
fi
if [ ! -d "$ROOT_DIR/bin/$ARCH/ncurses" ]; then
	cd "build/$ARCH/ncurses/ncurses-$NCURSES_VERSION"
	[ -f Makefile ] && make clean
	(CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS" LDFLAGS=-s ./configure --target="$TARGET" --host="$TARGET" --prefix=/usr --with-shared --without-debug --without-cxx --without-cxx-binding --without-ada --with-normal && make install DESTDIR="$ROOT_DIR/bin/$ARCH/ncurses") || exit 1
	cd ../../../..
	compress_man_files ncurses
	echo -n > "bin/$ARCH/ncurses.nonextra"
fi
if [ ! -d "$ROOT_DIR/bin/$ARCH/libedit" ]; then
	cd "build/$ARCH/libedit/libedit-$LIBEDIT_VERSION"
	[ -f Makefile ] && make clean
	(CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS -I$ROOT_DIR/bin/$ARCH/ncurses/usr/include -I$ROOT_DIR/bin/$ARCH/ncurses/usr/include/ncurses" LDFLAGS="-L$ROOT_DIR/bin/$ARCH/ncurses/usr/lib -s" ./configure --host="$TARGET" --prefix=/usr && make install DESTDIR="$ROOT_DIR/bin/$ARCH/libedit") || exit 1
	"$STRIP" "$ROOT_DIR/bin/$ARCH/libedit/"usr/lib/libedit.so.0.0.*
	cd ../../../..
	compress_man_files libedit
	echo -n > "bin/$ARCH/libedit.nonextra"
fi
if [ ! -d "$ROOT_DIR/bin/$ARCH/sysvinit" ]; then
	cd "build/$ARCH/sysvinit/sysvinit-$SYSVINIT_VERSION"
	[ -f Makefile ] && make clean
	make CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS" LDFLAGS=-s ROOT="$ROOT_DIR/bin/$ARCH/sysvinit" DISTRO=Toyroot all install || exit 1
	rm -fr $ROOT_DIR/bin/$ARCH/sysvinit/usr/include
	cd ../../../..
	create_man_package_from_package sysvinit
	echo -n > "bin/$ARCH/sysvinit.nonextra"
fi
if [ ! -d "$ROOT_DIR/bin/$ARCH/dash" ]; then
	cd "build/$ARCH/dash/dash-$DASH_VERSION"
	[ -f Makefile ] && make clean
	(CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS -I$ROOT_DIR/bin/$ARCH/ncurses/usr/include -I$ROOT_DIR/bin/$ARCH/ncurses/usr/include/ncurses -I$ROOT_DIR/bin/$ARCH/libedit/usr/include" LDFLAGS="-L$ROOT_DIR/bin/$ARCH/ncurses/usr/lib -L$ROOT_DIR/bin/$ARCH/libedit/usr/lib -s" LIBS="-ledit -lncurses" ./configure --host="$TARGET" --prefix=/ --datarootdir=/usr/share --with-libedit && make install CC_FOR_BUILD=gcc DESTDIR="$ROOT_DIR/bin/$ARCH/dash") || exit 1
	cd ../../../..
	create_man_package_from_package dash
	echo -n > "bin/$ARCH/sysvinit.nonextra"
fi
if [ ! -d "$ROOT_DIR/bin/$ARCH/dhcp-dhclient" ]; then
	cd "build/$ARCH/dhcp/dhcp-$DHCP_VERSION"
	[ -f Makefile ] && make clean
	echo ac_cv_file__dev_random=yes > config.cache
	(CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS -fno-strict-aliasing" LDFLAGS=-s ./configure --host="$TARGET" --prefix=/ --datarootdir=/usr/share --includedir=/usr/include --libdir=/usr/lib --cache-file=config.cache && make install DESTDIR="$ROOT_DIR/bin/$ARCH/dhcp" CFLAGS="-I$ROOT_DIR/bin/$ARCH/dhcp/usr/include") || exit 1
	rm -fr "$ROOT_DIR/bin/$ARCH/dhcp/etc"
	mkdir -p "$ROOT_DIR/bin/$ARCH/dhcp-dhclient/bin"
	mv "$ROOT_DIR/bin/$ARCH/dhcp/bin/omshell" "$ROOT_DIR/bin/$ARCH/dhcp-dhclient/bin"
	mkdir -p "$ROOT_DIR/bin/$ARCH/dhcp-dhclient/sbin"
	mv "$ROOT_DIR/bin/$ARCH/dhcp/sbin/dhclient" "$ROOT_DIR/bin/$ARCH/dhcp-dhclient/sbin"
	mkdir -p "$ROOT_DIR/bin/$ARCH/dhcp-dhclient/usr/share/man/man1"
	mv "$ROOT_DIR/bin/$ARCH/dhcp/usr/share/man/man1"/* "$ROOT_DIR/bin/$ARCH/dhcp-dhclient/usr/share/man/man1"
	rm -fr "$ROOT_DIR/bin/$ARCH/dhcp/usr/share/man/man1"
	mkdir -p "$ROOT_DIR/bin/$ARCH/dhcp-dhclient/usr/share/man/man5"
	mv "$ROOT_DIR/bin/$ARCH/dhcp/usr/share/man/man5"/dhclient* "$ROOT_DIR/bin/$ARCH/dhcp-dhclient/usr/share/man/man5"
	mkdir -p "$ROOT_DIR/bin/$ARCH/dhcp-dhclient/usr/share/man/man8"
	mv "$ROOT_DIR/bin/$ARCH/dhcp/usr/share/man/man8"/dhclient* "$ROOT_DIR/bin/$ARCH/dhcp-dhclient/usr/share/man/man8"
	cd ../../../..
	create_man_package_from_package dhcp-dhclient
	create_man_package_from_package dhcp
	create_dev_package_from_package dhcp
	echo -n > "bin/$ARCH/dhcp-dhclient.nonextra"
fi
if [ ! -d "$ROOT_DIR/bin/$ARCH/iputils-ping" ]; then
	cd "build/$ARCH/iputils/iputils-$IPUTILS_VERSION"
	[ -f Makefile ] && make clean
	make CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS" LDLIB=-s USE_CAP=no USE_SYSFS=no USE_IDN=no USE_GNUTLS=no USE_CRYPTO=no SHELL=/bin/bash all man || exit 1
	mkdir -p "$ROOT_DIR/bin/$ARCH/iputils-ping/bin"
	cp -dp ping ping6 "$ROOT_DIR/bin/$ARCH/iputils-ping/bin"
	mkdir -p "$ROOT_DIR/bin/$ARCH/iputils-ping/usr/share/man/man8"
	cp doc/ping.8 "$ROOT_DIR/bin/$ARCH/iputils-ping/usr/share/man/man8"
	ln -sf ping.8 "$ROOT_DIR/bin/$ARCH/iputils-ping/usr/share/man/man8/ping6.8"
	mkdir -p "$ROOT_DIR/bin/$ARCH/iputils/usr/bin"
	cp -dp clockdiff tracepath tracepath6 traceroute6 "$ROOT_DIR/bin/$ARCH/iputils/usr/bin"
	mkdir -p "$ROOT_DIR/bin/$ARCH/iputils/usr/sbin"
	cp -dp arping rarpd rdisc tftpd "$ROOT_DIR/bin/$ARCH/iputils/usr/sbin"
	mkdir -p "$ROOT_DIR/bin/$ARCH/iputils/usr/share/man/man8"
	cp doc/arping.8 doc/clockdiff.8 doc/tracepath.8 doc/traceroute6.8 "$ROOT_DIR/bin/$ARCH/iputils/usr/share/man/man8"
	ln -sf tracepath.8 "$ROOT_DIR/bin/$ARCH/iputils/usr/share/man/man8/tracepath6.8"
	cd ../../../..
	create_man_package_from_package iputils-ping
	create_man_package_from_package iputils
	echo -n > "bin/$ARCH/iputils-ping.nonextra"
fi
if [ ! -d "$ROOT_DIR/bin/$ARCH/toybox" ]; then
	cd "build/$ARCH/toybox/toybox-$TOYBOX_VERSION"
	[ -f Makefile ] && make clean
	cp "$ROOT_DIR/config/toybox-$TOYBOX_VERSION.config" .config
	make CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS" STRIP="$STRIP" PREFIX="$ROOT_DIR/bin/$ARCH/toybox" all install || exit 1
	rm -f "$ROOT_DIR/bin/$ARCH/toybox/usr/bin/traceroute6"
	cd ../../../..
	echo -n > "bin/$ARCH/toybox.nonextra"
fi
if [ ! -d "$ROOT_DIR/bin/$ARCH/util-linux-mount" ]; then
	cd "$ROOT_DIR/bin/$ARCH/toybox"
	TOYBOX_FILES="`find`"
	cd ../../..
	cd "build/$ARCH/util-linux/util-linux-$UTIL_LINUX_VERSION"
	[ -f Makefile ] && make clean
	find 
	(CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS -I$ROOT_DIR/bin/$ARCH/ncurses/usr/include -I$ROOT_DIR/bin/$ARCH/ncurses/usr/include/ncurses" LDFLAGS="-L$ROOT_DIR/bin/$ARCH/ncurses/usr/lib -lc -s" LIBS="-lncurses" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
		--enable-shared \
		--disable-losetup \
		--disable-mountpoint \
		--disable-unshare \
		--disable-eject \
		--disable-agetty \
		--disable-switch_root \
		--disable-pivot_root \
		--disable-kill \
		--disable-last \
		--disable-login \
		--disable-nologin \
		--disable-more \
		--disable-use-tty-group \
		--without-systemd \
		--without-python \
		--without-systemdsystemunitdir \
		PKG_CONFIG="" \
		&& make install DESTDIR="$ROOT_DIR/bin/$ARCH/util-linux") || exit 1
	for file in $TOYBOX_FILES; do
		if [ -e "$ROOT_DIR/bin/$ARCH/util-linux/$file" -a ! -d "$ROOT_DIR/bin/$ARCH/util-linux/$file" ]; then 
			rm -f "$ROOT_DIR/bin/$ARCH/util-linux/$file"
			name="`basename "$file"`"
			rm -f "$ROOT_DIR/bin/$ARCH/util-linux/usr/share/man"/man?/"$name".*
		fi
	done
	chmod 755 "$ROOT_DIR/bin/$ARCH/util-linux/bin/mount"
	chmod 755 "$ROOT_DIR/bin/$ARCH/util-linux/bin/umount"
	rm -fr "$ROOT_DIR/bin/$ARCH/util-linux/usr/share/bash-completion"
	mkdir -p "$ROOT_DIR/bin/$ARCH/util-linux-mount/bin"
	mv "$ROOT_DIR/bin/$ARCH/util-linux/bin/mount" "$ROOT_DIR/bin/$ARCH/util-linux-mount/bin"
	mv "$ROOT_DIR/bin/$ARCH/util-linux/bin/umount" "$ROOT_DIR/bin/$ARCH/util-linux-mount/bin"
	mkdir -p "$ROOT_DIR/bin/$ARCH/util-linux-mount/lib"
	for name in blkid mount uuid; do
		mv "$ROOT_DIR/bin/$ARCH/util-linux/lib/lib$name".so.* "$ROOT_DIR/bin/$ARCH/util-linux-mount/lib"
	done
	mkdir -p "$ROOT_DIR/bin/$ARCH/util-linux-mount/usr/lib"
	for name in blkid mount uuid; do
		mv "$ROOT_DIR/bin/$ARCH/util-linux/usr/lib/lib$name".so "$ROOT_DIR/bin/$ARCH/util-linux-mount/usr/lib"
	done
	mkdir -p "$ROOT_DIR/bin/$ARCH/util-linux-mount/usr/share/man/man8"
	mv "$ROOT_DIR/bin/$ARCH/util-linux/usr/share/man/man8"/mount.8 "$ROOT_DIR/bin/$ARCH/util-linux-mount/usr/share/man/man8"
	mv "$ROOT_DIR/bin/$ARCH/util-linux/usr/share/man/man8"/umount.8 "$ROOT_DIR/bin/$ARCH/util-linux-mount/usr/share/man/man8"
	cd ../../../..
	create_man_package_from_package util-linux-mount
	create_man_package_from_package util-linux
	create_dev_package_from_package util-linux
	echo -n > "bin/$ARCH/util-linux-mount.nonextra"
fi
if [ ! -d "$ROOT_DIR/bin/$ARCH/uClibc++-build" ]; then
	cd "build/$ARCH/uClibc++/uClibc++-$UCLIBCXX_VERSION"
	[ -f Makefile ] && make clean
	(make defconfig && make CC="$MUSL_GCC" CXX="$GXX -specs $ROOT_DIR/bin/$ARCH/musl/lib/musl-gcc.specs" OPTIMIZATION="$GCC_CFLAGS" STRIPTOOL="$STRIP" PREFIX="$ROOT_DIR/bin/$ARCH/uClibc++-build" all install) || exit 1
	mkdir -p "$ROOT_DIR/bin/$ARCH/uClibc++"
	cp -drp "$ROOT_DIR/bin/$ARCH/uClibc++-build/"* "$ROOT_DIR/bin/$ARCH/uClibc++"
	for lib in `ls "$ROOT_DIR/bin/$ARCH/uClibc++/usr/uClibc++/lib"`; do
		case "$lib" in
			lib*.so|lib*.so.*)
				mkdir -p "$ROOT_DIR/bin/$ARCH/uClibc++/usr/lib"
				ln -sf "../uClibc++/lib/$lib" "$ROOT_DIR/bin/$ARCH/uClibc++/usr/lib/$lib"
				;;
		esac
	done
	mkdir -p "$ROOT_DIR/bin/$ARCH/uClibc++/usr/bin"
	ln -sf ../uClibc++/bin/g++-uc "$ROOT_DIR/bin/$ARCH/uClibc++/usr/bin/g++-uc"
	cd ../../../..
	mkdir -p "$ROOT_DIR/bin/$ARCH/uClibc++_dev/usr/uClibc++/include"
	mv "$ROOT_DIR/bin/$ARCH/uClibc++/usr/uClibc++/include"/* "$ROOT_DIR/bin/$ARCH/uClibc++_dev/usr/uClibc++/include"
	rm -fr "$ROOT_DIR/bin/$ARCH/uClibc++/usr/uClibc++/include"
	mkdir -p "$ROOT_DIR/bin/$ARCH/uClibc++_dev/usr/uClibc++/lib"
	mv "$ROOT_DIR/bin/$ARCH/uClibc++/usr/uClibc++/lib"/*.a "$ROOT_DIR/bin/$ARCH/uClibc++_dev/usr/uClibc++/lib"
	mkdir -p "$ROOT_DIR/bin/$ARCH/uClibc++_dev/usr/uClibc++/bin"
	sed -e 's/^exec [^ ]* [^ ]* [^ ]*/exec g++/' -e "s/WRAPPER_LIBS=\" -L[^ ]*/WRAPPER_LIBS=\" -L\\/usr\\/lib\\/gcc\\/""$MUSL_TARGET""\\/\`readlink \\/etc\\/selectgcc\\/bin\\/g++ | cut -d - -f 2\`/" "$ROOT_DIR/bin/$ARCH/uClibc++/usr/uClibc++/bin/g++-uc" > "$ROOT_DIR/bin/$ARCH/uClibc++_dev/usr/uClibc++/bin/g++-uc"
	chmod 755 "$ROOT_DIR/bin/$ARCH/uClibc++_dev/usr/uClibc++/bin/g++-uc"
	rm -fr "$ROOT_DIR/bin/$ARCH/uClibc++/usr/uClibc++/bin"
	mkdir -p "$ROOT_DIR/bin/$ARCH/uClibc++_dev/usr/bin"
	mv "$ROOT_DIR/bin/$ARCH/uClibc++/usr/bin/g++-uc" "$ROOT_DIR/bin/$ARCH/uClibc++_dev/usr/bin"
	rm -fr "$ROOT_DIR/bin/$ARCH/uClibc++/usr/bin"
	echo -n > "bin/$ARCH/uClibc++-build.nonextra"
fi
if [ ! -d "$ROOT_DIR/bin/$ARCH/shadow-login" ]; then
	cd "build/$ARCH/shadow/shadow-$SHADOW_VERSION"
	[ -f Makefile ] && make clean
	(CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS" LDFLAGS=-s ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-subordinate-ids -without-libpam --without-nscd &&
		echo "#define ENABLE_SUBIDS 1" >> config.h &&
		cp src/Makefile src/Makefile.orig &&
		cat src/Makefile.orig | sed -e 's/^#am__append_1 = newgidmap newuidmap$/ubin_PROGRAMS += newgidmap\$\(EXEEXT\) newuidmap\$\(EXEEXT\)/' > src/Makefile &&
		make all install DESTDIR="$ROOT_DIR/bin/$ARCH/shadow") || exit 1
	cp "$ROOT_DIR/bin/$ARCH/shadow/etc/login.defs" "$ROOT_DIR/bin/$ARCH/shadow/etc/login.defs.tmp"
	cat "$ROOT_DIR/bin/$ARCH/shadow/etc/login.defs.tmp" |  sed 's/^MAIL_CHECK_ENAB.*$/MAIL_CHECK_ENAB\t\tno/' > "$ROOT_DIR/bin/$ARCH/shadow/etc/login.defs"
	rm -f "$ROOT_DIR/bin/$ARCH/shadow/etc/login.defs.tmp"
	rm -f "$ROOT_DIR/bin/$ARCH/shadow/bin/groups"
	rm -f "$ROOT_DIR/bin/$ARCH/shadow/usr/share/man/man1/groups.1"
	cp man/man1/newgidmap.1 man/man1/newuidmap.1 "$ROOT_DIR/bin/$ARCH/shadow/usr/share/man/man1"
	cp man/man5/subgid.5 man/man5/subuid.5 "$ROOT_DIR/bin/$ARCH/shadow/usr/share/man/man5"
	rm -fr "$ROOT_DIR/bin/$ARCH/shadow/usr/share/man/man3"
	mkdir -p "$ROOT_DIR/bin/$ARCH/shadow-login/etc"
	mv "$ROOT_DIR/bin/$ARCH/shadow/etc"/login.* "$ROOT_DIR/bin/$ARCH/shadow-login/etc"
	mkdir -p "$ROOT_DIR/bin/$ARCH/shadow-login/bin"
	mv "$ROOT_DIR/bin/$ARCH/shadow/bin/login" "$ROOT_DIR/bin/$ARCH/shadow-login/bin"
	mkdir -p "$ROOT_DIR/bin/$ARCH/shadow-login/usr/share/man/man1"
	mv "$ROOT_DIR/bin/$ARCH/shadow/usr/share/man/man1/login.1" "$ROOT_DIR/bin/$ARCH/shadow-login/usr/share/man/man1"
	cd ../../../..
	create_man_package_from_package shadow-login
	create_man_package_from_package shadow
	echo -n > "bin/$ARCH/shadow-login.nonextra"
fi
if [ ! -d "$ROOT_DIR/bin/$ARCH/toyroot-utils" ]; then
	mkdir -p "$ROOT_DIR/build/$ARCH/toyroot-utils/utils"
	cd "$ROOT_DIR/build/$ARCH/toyroot-utils/utils"
	cp -r "$ROOT_DIR/utils"/* ./
	make clean
	make install DESTDIR="$ROOT_DIR/bin/$ARCH/toyroot-utils" CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS" LDFLAGS=-s
	cd ../../../..
fi

case "$ARCH" in
	i[3-9]86|x86_64)
		if [ ! -d "$ROOT_DIR/bin/$ARCH/grub" ]; then
			cd "build/$ARCH/grub/grub-$GRUB_VERSION"
			[ -f Makefile ] && make clean
			echo '#!/bin/sh' > ../grub-gcc
			echo 'M32=false' >> ../grub-gcc
			echo 'for a in $*; do [ "$a" = -m32 ] && M32=true; done' >> ../grub-gcc
			echo 'if [ $M32 != true ]; then' >> ../grub-gcc
			echo "$GCC -specs $ROOT_DIR/bin/$ARCH/musl/lib/musl-gcc.specs"' $*' >> ../grub-gcc
			echo 'else' >> ../grub-gcc
			echo "$GCC"' $*' >> ../grub-gcc
			echo 'fi' >> ../grub-gcc
			chmod 755 ../grub-gcc
			(CC="$ROOT_DIR/build/$ARCH/grub/grub-gcc" OBJCOPY="$OBJCOPY -R .note.gnu.build-id" ./configure --host="$TARGET" --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --cache-file=config.cache && make DESTDIR="$ROOT_DIR/bin/$ARCH/grub" install) || exit 1
			rm -f "$ROOT_DIR/bin/$ARCH/grub/usr/share/info/dir"
			cd ../../../..
			create_man_package_from_package grub
		fi
		if [ ! -d "$ROOT_DIR/bin/$ARCH/grub-host" ]; then
			cd "build/$ARCH/grub-host/grub-$GRUB_VERSION"
			[ -f Makefile ] && make clean
			(OBJCOPY="$OBJCOPY -R .note.gnu.build-id" ./configure --host="$HOST" --prefix="$ROOT_DIR/bin/$ARCH/grub-host" --cache-file=config.cache && make install) || exit 1
			rm -f "$ROOT_DIR/bin/$ARCH/grub-host/lib/grub/i386-pc"/*
			cp -dp "$ROOT_DIR/bin/$ARCH/grub/usr/lib/grub/i386-pc"/* "$ROOT_DIR/bin/$ARCH/grub-host/lib/grub/i386-pc"
			cd ../../../..
			echo -n > "bin/$ARCH/grub-host.nonextra"
		fi
		;;
esac

INIT_PKG_CFLAGS="$GCC_CFLAGS -I$ROOT_DIR/bin/$ARCH/ncurses/usr/include -I$ROOT_DIR/bin/$ARCH/ncurses/usr/include/ncurses"
INIT_PKG_LDFLAGS="-L$ROOT_DIR/bin/$ARCH/ncurses/usr/lib -L$ROOT_DIR/bin/$ARCH/libedit/usr/lib -s"
INIT_PKG_LIBS=""
process_extra_packages build_extra_package
exit 0
