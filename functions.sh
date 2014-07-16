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

download_source() {
	mkdir -p src
	if [ "$3" = "" ]; then
		[ ! -f "src/$1" ] && wget -P src "$2/$1"
	else
		[ ! -f "src/$1" ] && wget "$2/$3" -O "src/$1"
	fi
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
		patch -p1 -d "build/$ARCH/$1" < "$p" || return 1
	done
	return 0
}

extract_and_patch_package() {
	extract_package "$1" "$2" "$3" && patch_package "$1" "$3"
}

install_non_extra_packages() {
	mkdir -p "$NX_PKG_ROOT_DIR/lib"
	cp -dp "bin/$ARCH/musl/lib"/*.so "$NX_PKG_ROOT_DIR/lib"
	echo /lib:/usr/lib > "$NX_PKG_ROOT_DIR/etc/ld-musl-$ARCH.path"
	ln -s libc.so "$NX_PKG_ROOT_DIR/lib/ld-musl-$ARCH.so.1"

	for libpkg in ncurses libedit; do
		[ -d "bin/$ARCH/$libpkg/lib" ] && mkdir -p "$NX_PKG_ROOT_DIR/lib" && cp -drp "bin/$ARCH/$libpkg/lib"/lib*.so "bin/$ARCH/$libpkg/lib"/lib*.so.* "$NX_PKG_ROOT_DIR/lib"
		[ -d "bin/$ARCH/$libpkg/usr/lib" ] && mkdir -p "$NX_PKG_ROOT_DIR/usr/lib" && cp -drp "bin/$ARCH/$libpkg/usr/lib"/lib*.so "bin/$ARCH/$libpkg/usr/lib"/lib*.so.* "$NX_PKG_ROOT_DIR/usr/lib"
	done
	mkdir -p "$NX_PKG_ROOT_DIR/usr/share"
	cp -drp "bin/$ARCH/ncurses/usr/share"/* "$NX_PKG_ROOT_DIR/usr/share"

	for pkg in sysvinit dash iputils-ping dhcp-dhclient toybox util-linux-mount shadow-login; do
		cp -drp "bin/$ARCH/$pkg"/* "$NX_PKG_ROOT_DIR"
	done
	ln -sf dash "$NX_PKG_ROOT_DIR/bin/sh"
}

install_non_extra_packages_with_suffix() {
	case "$1" in
		man)
			mkdir -p "$NX_PKG_ROOT_DIR/usr/share/man"
			for libpkg in ncurses libedit; do
				for s in 1 4 5 6 7 8; do
					[ -d "bin/$ARCH/$libpkg/usr/share/man/man$s" ] && mkdir -p "$NX_PKG_ROOT_DIR/usr/share/man/man$s" && cp -drp "bin/$ARCH/$libpkg/usr/share/man/man$s"/* "$NX_PKG_ROOT_DIR/usr/share/man/man$s"
				done
			done
			;;
		dev)
			mkdir -p "$NX_PKG_ROOT_DIR/usr/include"
			mkdir -p "$NX_PKG_ROOT_DIR/lib"
			mkdir -p "$NX_PKG_ROOT_DIR/usr/lib"
			cp -drp "bin/$ARCH/musl/include"/* "$NX_PKG_ROOT_DIR/usr/include"
			cp -drp "bin/$ARCH/musl/lib"/*.o "bin/$ARCH/musl/lib"/*.a "$NX_PKG_ROOT_DIR/lib"
			local ASM_INCLUDE_LINK="`readlink "bin/$ARCH/musl/include/asm"`"
			local ASM_GENERIC_INCLUDE_LINK="`readlink "bin/$ARCH/musl/include/asm-generic"`"
			local LINUX_INCLUDE_LINK="`readlink "bin/$ARCH/musl/include/linux"`"
			rm -f "$NX_PKG_ROOT_DIR/usr/include/asm"
			rm -f "$NX_PKG_ROOT_DIR/usr/include/asm-generic"
			rm -f "$NX_PKG_ROOT_DIR/usr/include/linux"
			mkdir -p "$NX_PKG_ROOT_DIR/usr/include/asm"
			cp -drp "$ASM_INCLUDE_LINK"/* "$NX_PKG_ROOT_DIR/usr/include/asm"
			cp -drp "$ASM_GENERIC_INCLUDE_LINK" "$NX_PKG_ROOT_DIR/usr/include"
			cp -drp "$LINUX_INCLUDE_LINK" "$NX_PKG_ROOT_DIR/usr/include"
			for libpkg in ncurses libedit; do
				[ -d "bin/$ARCH/$libpkg/usr/include" ] && mkdir -p "$NX_PKG_ROOT_DIR/usr/include" && cp -drp "bin/$ARCH/$libpkg/usr/include"/* "$NX_PKG_ROOT_DIR/usr/include"
				[ -d "bin/$ARCH/$libpkg/lib" ] && mkdir -p "$NX_PKG_ROOT_DIR/lib" && cp -drp "bin/$ARCH/$libpkg/lib"/lib*.a "$NX_PKG_ROOT_DIR/lib"
				[ -d "bin/$ARCH/$libpkg/usr/lib" ] && mkdir -p "$NX_PKG_ROOT_DIR/usr/lib" && cp -drp "bin/$ARCH/$libpkg/usr/lib"/lib*.a "$NX_PKG_ROOT_DIR/usr/lib"
				for s in 2 3; do
					[ -d "bin/$ARCH/$libpkg/usr/share/man/man$s" ] && mkdir -p "$NX_PKG_ROOT_DIR/usr/share/man/man$s" && cp -drp "bin/$ARCH/$libpkg/usr/share/man/man$s"/* "$NX_PKG_ROOT_DIR/usr/share/man/man$s"
				done
			done
			;;
	esac

	for pkg in sysvinit dash iputils-ping dhcp-dhclient toybox util-linux-mount; do
		if [ -d "bin/$ARCH/$pkg""_$1" ]; then
			mkdir -p "$NX_PKG_ROOT_DIR"
			cp -drp "bin/$ARCH/$pkg""_$1"/* "$NX_PKG_ROOT_DIR"
		fi
	done
}

is_non_empty_directory() {
	[ -d "$1" ] || return 1
	local FILES="`ls "$1"`"
	[ "$FILES" != "" ] || return 1
	return 0
}

remove_empty_directory() {
	if [ -d "$1" ]; then
		local FILES="`ls "$1"`"
		[ "$FILES" = "" ] && rmdir "$1"
	fi
}

compress_man_files() {
	for d in "$ROOT_DIR/bin/$ARCH/$1/usr/share/man"/*; do
		if is_non_empty_directory "$d"; then
			for f in "$d"/*; do
				case "$f" in
					*.gz)
						;;
					*)
						[ -f "$f"  -a ! -L "$f" ] && gzip -9 "$f"
						if [ -L "$f" ]; then
							local MAN_LINK="`readlink "$f"`"
							rm -f "$f"
							ln -sf "$MAN_LINK.gz" "$f.gz"
						fi
						;;
				esac
			done
		fi
	done
	if is_non_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share/info"; then
		for f in "$ROOT_DIR/bin/$ARCH/$1/usr/share/info"/*; do
			[ -f "$f" -a ! -L "$f" ] && gzip -9 "$f"
			if [ -L "$f" ]; then
				local INFO_LINK="`readlink "$f"`"
				rm -f "$f"
				ln -sf "$INFO_LINK.gz" "$f.gz"
			fi
		done
	fi
}

move_man_files_to_man_package() {
	for s in 1 4 5 6 7 8; do
		if is_non_empty_directory  "$ROOT_DIR/bin/$ARCH/$1/usr/share/man/man$s"; then
			mkdir -p "$ROOT_DIR/bin/$ARCH/$1""_man/usr/share/man/man$s"
			mv "$ROOT_DIR/bin/$ARCH/$1/usr/share/man/man$s"/* "$ROOT_DIR/bin/$ARCH/$1""_man/usr/share/man/man$s"
			remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share/man/man$s"
		fi
	done
	if is_non_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share/info"; then
		mkdir -p "$ROOT_DIR/bin/$ARCH/$1""_man/usr/share/info"
		mv "$ROOT_DIR/bin/$ARCH/$1/usr/share/info"/* "$ROOT_DIR/bin/$ARCH/$1""_man/usr/share/info"
		remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share/info"
	fi
	remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share/man"
	remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share/info"
	remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share"
	remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr"
}

create_man_package_from_package() {
	move_man_files_to_man_package "$1"
	compress_man_files "$1"_man
}

move_dev_files_to_dev_package() {
	if is_non_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/include"; then
		mkdir -p "$ROOT_DIR/bin/$ARCH/$1""_dev/usr/include"
		mv "$ROOT_DIR/bin/$ARCH/$1/usr/include"/* "$ROOT_DIR/bin/$ARCH/$1""_dev/usr/include"
		remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/include"
	fi
	if is_non_empty_directory "$ROOT_DIR/bin/$ARCH/$1/lib"; then
		if [ -e "`echo "$ROOT_DIR/bin/$ARCH/$1/lib"/lib*.a | cut -d ' ' -f 1`" ]; then
			mkdir -p "$ROOT_DIR/bin/$ARCH/$1""_dev/lib"
			mv "$ROOT_DIR/bin/$ARCH/$1/lib"/lib*.a "$ROOT_DIR/bin/$ARCH/$1""_dev/lib"
		fi
		if [ -e "`echo "$ROOT_DIR/bin/$ARCH/$1/lib"/lib*.la | cut -d ' ' -f 1`" ]; then
			mkdir -p "$ROOT_DIR/bin/$ARCH/$1""_dev/lib"
			mv "$ROOT_DIR/bin/$ARCH/$1/lib"/lib*.la "$ROOT_DIR/bin/$ARCH/$1""_dev/lib"
		fi
		remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/lib"
	fi
	if is_non_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/lib"; then
		if [ -e "`echo "$ROOT_DIR/bin/$ARCH/$1/usr/lib"/lib*.a | cut -d ' ' -f 1`" ]; then
			mkdir -p "$ROOT_DIR/bin/$ARCH/$1""_dev/usr/lib"
			mv "$ROOT_DIR/bin/$ARCH/$1/usr/lib"/lib*.a "$ROOT_DIR/bin/$ARCH/$1""_dev/usr/lib"
		fi
		if [ -e "`echo "$ROOT_DIR/bin/$ARCH/$1/usr/lib"/lib*.la | cut -d ' ' -f 1`" ]; then
			mkdir -p "$ROOT_DIR/bin/$ARCH/$1""_dev/usr/lib"
			mv "$ROOT_DIR/bin/$ARCH/$1/usr/lib"/lib*.la "$ROOT_DIR/bin/$ARCH/$1""_dev/usr/lib"
		fi
		remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/lib"
	fi
	for s in 2 3; do
		if is_non_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share/man/man$s"; then
			mkdir -p "$ROOT_DIR/bin/$ARCH/$1""_dev/usr/share/man/man$s"
			mv "$ROOT_DIR/bin/$ARCH/$1/usr/share/man/man$s"/* "$ROOT_DIR/bin/$ARCH/$1""_dev/usr/share/man/man$s"
			remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share/man/man$s"
		fi
	done
	remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/lib"
	remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/include"
	remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/lib"
	remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share/man"
	remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share"
	remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr"
}

create_dev_package_from_package() {
	move_dev_files_to_dev_package "$1"
	compress_man_files "$1"_dev
}

move_doc_files_to_doc_package() {
	if is_non_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share/doc"; then
		mkdir -p "$ROOT_DIR/bin/$ARCH/$1""_doc/usr/share/doc"
		mv "$ROOT_DIR/bin/$ARCH/$1/usr/share/doc"/* "$ROOT_DIR/bin/$ARCH/$1""_doc/usr/share/doc"
		remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share/doc"
	fi
	remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share/doc"
	remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr/share"
	remove_empty_directory "$ROOT_DIR/bin/$ARCH/$1/usr"
}

create_doc_package_from_package() {
	move_doc_files_to_doc_package "$1"
}

package_bin_dir() {
	echo "$ROOT_DIR/bin/$ARCH/$1"
}

set_extra_package_cflags() {
	PKG_CFLAGS="$INIT_PKG_CFLAGS"
	for dp in $DEV_PKGS; do
		[ -d "$ROOT_DIR/bin/$ARCH/$dp""_dev/include" ] && PKG_CFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/$dp""_dev/include"
		[ -d "$ROOT_DIR/bin/$ARCH/$dp""_dev/usr/include" ] && PKG_CFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/$dp""_dev/usr/include"
	done
}

set_extra_package_ldflags() {
	PKG_LDFLAGS="$INIT_PKG_LDFLAGS"
	for dp in $DEV_PKGS; do
		[ -d "$ROOT_DIR/bin/$ARCH/$dp/lib" ] && PKG_LDFLAGS="$PKG_LDFLAGS -L$ROOT_DIR/bin/$ARCH/$dp/lib"
		[ -d "$ROOT_DIR/bin/$ARCH/$dp/usr/lib" ] && PKG_LDFLAGS="$PKG_LDFLAGS -L$ROOT_DIR/bin/$ARCH/$dp/usr/lib"
		[ -d "$ROOT_DIR/bin/$ARCH/$dp""_dev/lib" ] && PKG_LDFLAGS="$PKG_LDFLAGS -L$ROOT_DIR/bin/$ARCH/$dp""_dev/lib"
		[ -d "$ROOT_DIR/bin/$ARCH/$dp""_dev/usr/lib" ] && PKG_LDFLAGS="$PKG_LDFLAGS -L$ROOT_DIR/bin/$ARCH/$dp""_dev/usr/lib"
	done
}

set_extra_package_libs() {
	PKG_LIBS="$INIT_PKG_LIBS"
}

extra_package_name() {
	echo "$1"
}

build_extra_package() {
	local PKG_NAME="$1"
	local PKG_VERSION="$2"
	local PKG_SRC_EXT="$3"
	local PKG_DOWNLOAD_URL="$4"
	local PKG_SRC_FORMAT="$5"
	local PKG_BUILD_DIR_FORMAT="$6"
	[ -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME.nonextra" ] && return 0
	[ "$PKG_VERSION" = "" ] && return 0
	[ "$PKG_SRC_FORMAT" = "" ] && PKG_SRC_FORMAT="%p-%v.%e"
	[ "$PKG_BUILD_DIR_FORMAT" = "" ] && PKG_BUILD_DIR_FORMAT="%p-%v"
	set_extra_package_cflags
	set_extra_package_ldflags
	set_extra_package_libs
	if [ ! -d "bin/$ARCH/$PKG_NAME" ]; then
		local PKG_SRC="`echo "$PKG_SRC_FORMAT" | sed -e "s/%p/$PKG_NAME/" -e "s/%v/$PKG_VERSION/" -e "s/%e/$PKG_SRC_EXT/"`"
		local PKG_BUILD_DIR="`echo "$PKG_BUILD_DIR_FORMAT" | sed -e "s/%p/$PKG_NAME/" -e "s/%v/$PKG_VERSION/"`"
		download_source "$PKG_SRC" "$PKG_DOWNLOAD_URL"
		extract_package "$PKG_NAME" "$PKG_SRC" "$PKG_BUILD_DIR" &&
		patch_package "$PKG_NAME" "$PKG_BUILD_DIR"
		local SAVED_PWD="`pwd`"
		[ ! -d "build/$ARCH/$PKG_NAME/$PKG_BUILD_DIR" ] && mkdir -p "build/$ARCH/$PKG_NAME/$PKG_BUILD_DIR"
		cd "build/$ARCH/$PKG_NAME/$PKG_BUILD_DIR"
		
		if [ -f "$ROOT_DIR/pkg/$PKG_NAME.sh" ]; then
			. "$ROOT_DIR/pkg/$PKG_NAME.sh" || exit 1
		else
			[ -f Makefile ] && make clean
			(CC="$MUSL_GCC" CXX="$GXX_UC" CFLAGS="$PKG_CFLAGS" CXXFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME") || exit 1
		fi
		cd "$SAVED_PWD"
		[ $? != 0 ] && exit 1
		[ -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/lib/charset.alias" ] && rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/lib/charset.alias"	
		[ -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/charset.alias" ] && rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/charset.alias"	
		[ -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/info/dir" ] && rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/info/dir"	
		create_man_package_from_package "$PKG_NAME"
		create_dev_package_from_package "$PKG_NAME"
		create_doc_package_from_package "$PKG_NAME"
	fi
	[ -d "bin/$ARCH/$PKG_NAME"_dev ] && DEV_PKGS="$DEV_PKGS $PKG_NAME"
}

install_extra_package() {
	local PKG_NAME="$1"
	[ -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME.nonextra" ] && return 0
	mkdir -p "$PKG_ROOT_DIR"
	[ -d "bin/$ARCH/$PKG_NAME" ] && cp -drp "bin/$ARCH/$PKG_NAME"/* "$PKG_ROOT_DIR"
	if [ "$PKG_SUFFIXES" != "" ]; then
		for sfx in $PKG_SUFFIXES; do
			[ -d "bin/$ARCH/$PKG_NAME""_$sfx" ] && cp -drp "bin/$ARCH/$PKG_NAME""_$sfx"/* "$PKG_ROOT_DIR"
		done
	fi
}

process_extra_packages() {
	if [ "$NO_EXTRA_PKGS" != true -a -f packages.txt ]; then
		cat packages.txt | (while read line; do
			case $line in
				"#"*)	;;
				"")	;;
				*)
					if [ "$ALL_PKGS" = true ]; then
						"$1" $line
					else
						(echo $PKGS | grep -q "`extra_package_name $line`") && "$1" $line
					fi
					;;
			esac
		done)
	fi
}

install_all_infos() {
	local INSTALL_INFO=install-info
	which ginstall-info > /dev/null && INSTALL_INFO=ginstall-info
	for i in "$PKG_ROOT_DIR/usr/share/info"/*; do
		"$INSTALL_INFO" --info-dir="$PKG_ROOT_DIR/usr/share/info" --info-file="$i"
	done
}
