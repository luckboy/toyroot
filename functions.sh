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

download_source() {
	mkdir -p src
	[ ! -f "src/$1" ] && wget -P src "$2/$1"
}

extract_package() {
	mkdir -p "build/$ARCH/$1"
	if [ ! -d "build/$ARCH/$1/$3" ]; then
		case "$2" in
			*.tar)
				tar xf "src/$2" -C "build/$ARCH/$1"
				;;
			*.tar.gz|*.tgz)
				tar zxf "src/$2" -C "build/$ARCH/$1"
				;;
			*.tar.bz2|*.tbz2|*.tar.bz|*.tbz)
				tar jxf "src/$2" -C "build/$ARCH/$1"
				;;
			*.tar.xz|*.txz)
				tar Jxf "src/$2" -C "build/$ARCH/$1"
				;;
			*.zip)
				unzip "src/$2" -d "build/$ARCH/$1"
				;;
			*)
				echo "Unsupported extension" >&2
				return 1
				;;
		esac
		return $?
	else
		return 1
	fi
}

patch_package() {
	for p in `ls patch/$2-*.patch 2> /dev/null`; do
		patch -p1 -d "build/$ARCH/$1" < "$p" && return 1
	done
	return 0
}

extract_and_patch_package() {
	extract_package "$1" "$2" "$3" && patch_package "$1" "$3"
}

package_bin_dir() {
	echo "$ROOT_DIR/bin/$ARCH/$1"
}

set_extra_package_cflags() {
	PKG_CFLAGS="$INIT_PKG_CFLAGS"
	for lp in $LIBPKGS; do
		[ -d "$ROOT_DIR/bin/$ARCH/$lp/include" ] && PKG_CFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/$lp/include"
		[ -d "$ROOT_DIR/bin/$ARCH/$lp/usr/include" ] && PKG_CFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/$lp/usr/include"
	done
}

set_extra_package_ldflags() {
	PKG_LDFLAGS="$INIT_PKG_LDFLAGS"
	for lp in $LIBPKGS; do
		[ -d "$ROOT_DIR/bin/$ARCH/$lp/lib" ] && PKG_LDFLAGS="$PKG_LDFLAGS -L$ROOT_DIR/bin/$ARCH/$lp/lib"
		[ -d "$ROOT_DIR/bin/$ARCH/$lp/usr/lib" ] && PKG_LDFLAGS="$PKG_LDFLAGS -L$ROOT_DIR/bin/$ARCH/$lp/usr/lib"
	done
}

set_extra_package_libs() {
	PKG_LIBS="$INIT_PKG_LIBS"
}

build_extra_package() {
	local PKG_TYPE="$1"
	local PKG_NAME="$2"
	local PKG_VERSION="$3"
	local PKG_SRC_EXT="$4"
	local PKG_DOWNLOAD_URL="$5"
	local PKG_SRC_FORMAT="$6"
	local PKG_BUILD_DIR_FORMAT="$7"
	[ "$PKG_SRC_FORMAT" = "" ] && PKG_SRC_FORMAT="%p-%v.%e"
	[ "$PKG_BUILD_DIR_FORMAT" = "" ] && PKG_BUILD_DIR_FORMAT="%p-%v"
	set_extra_package_cflags
	set_extra_package_ldflags
	set_extra_package_libs
	case "$PKG_TYPE" in
		libpkg)	LIBPKGS="$LIBPKGS $PKG_NAME";;
	esac
	if [ ! -d "bin/$ARCH/$PKG_NAME" ]; then
		local PKG_SRC=`echo "$PKG_SRC_FORMAT" | sed -e "s/%p/$PKG_NAME/" -e "s/%v/$PKG_VERSION/" -e "s/%e/$PKG_SRC_EXT/"`
		local PKG_BUILD_DIR=`echo "$PKG_BUILD_DIR_FORMAT" | sed -e "s/%p/$PKG_NAME/" -e "s/%v/$PKG_VERSION/"`
		download_source "$PKG_SRC" "$PKG_DOWNLOAD_URL"
		extract_package "$PKG_NAME" "$PKG_SRC" "$PKG_BUILD_DIR" &&
		patch_package "$PKG_NAME" "$PKG_BUILD_DIR"
		local SAVED_PWD=`pwd`
		cd "build/$ARCH/$PKG_NAME/$PKG_BUILD_DIR"
		if [ -f "$ROOT_DIR/pkg/$PKG_NAME.sh" ]; then
			. "$ROOT_DIR/pkg/$PKG_NAME.sh" || exit 1
		else
			[ -f Makefile ] && make clean
			(CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME") || exit 1
		fi
		cd "$SAVED_PWD"
		[ $? != 0 ] && exit 1
	fi
}

install_extra_package() {
	local PKG_TYPE="$1"
	local PKG_NAME="$2"
	case "$PKG_TYPE" in
		libpkg)
			mkdir -p "$ROOT_FS_DIR"
			cp -drP "bin/$ARCH/$PKG_NAME"/* "$ROOT_FS_DIR"
			rm -fr "$ROOT_FS_DIR/usr/include"
			rm -f "$ROOT_FS_DIR/lib"/lib*.la "$ROOT_FS_DIR/usr/lib"/lib*.la
			rm -f "$ROOT_FS_DIR/lib"/lib*.a "$ROOT_FS_DIR/usr/lib"/lib*.a
			rm -fr "$ROOT_FS_DIR/usr/lib"/pkgconfig
			;;
		*)
			mkdir -p "$ROOT_FS_DIR"
			cp -drP "bin/$ARCH/$PKG_NAME"/* "$ROOT_FS_DIR"
			;;
	esac
}

