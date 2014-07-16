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

. ./kernel.txt

GCC="${GCC:=gcc}"

ROOT_DIR="`pwd`"
TARGET="`$GCC -dumpmachine`"
HOST="`gcc -dumpmachine`"
export ARCH="`$GCC -dumpmachine | cut -d - -f 1`"

case "$ARCH" in
	arm)	PLATFORM="${PLATFORM:=vexpress}";;
	*)	PLATFORM="${PLATFORM:=$ARCH}";;
esac

. ./functions.sh

CUSTOM_CONFIG=false
ONLY_CUSTOM_CONFIG=false
FORCE_MENUCONFIG=false
while [ $# -gt 0 ]; do
	case "$1" in
		--custom-config)
			CUSTOM_CONFIG=true
			;;
		--only-custom-config)
			ONLY_CUSTOM_CONFIG=true
			;;
		--force-menuconfig)
			FORCE_MENUCONFIG=true
			;;
	esac
	shift
done

download_source linux-$LINUX_VERSION.tar.xz $LINUX_DOWNLOAD_URL

extract_and_patch_package linux linux-$LINUX_VERSION.tar.xz linux-$LINUX_VERSION

mkdir -p "$ROOT_DIR/bin/$ARCH"

if [ ! -d "$ROOT_DIR/bin/$ARCH/linux" ]; then
	cd "build/$ARCH/linux/linux-$LINUX_VERSION"
	if [ "$TARGET" != "$HOST" ]; then
		export CROSS_COMPILE="$TARGET-"
	fi
	make clean
	if [ $CUSTOM_CONFIG = true -o $ONLY_CUSTOM_CONFIG = true ]; then
		if [ $FORCE_MENUCONFIG != true -a -f "$ROOT_DIR/kernel_config/$ARCH/$PLATFORM/.config" ]; then
			cp "$ROOT_DIR/kernel_config/$ARCH/$PLATFORM/.config" .config
		else
			if [ $ONLY_CUSTOM_CONFIG != true ]; then
				make "${PLATFORM}"_defconfig || exit 1
			fi
			while true; do
				make menuconfig || exit 1
				while true; do
					echo "You can select one option from following options:"
					echo "c - compile kernel"
					echo "a - again configure kernel"
					echo "q - quit with configuration saving"
					echo "x - quit without configuration saving"
					echo -n "What do you select? "
					read line
					ANSWER="`echo "$line" | tr '[:upper:]' '[:lower:]' | head -c 1`"
					case "$ANSWER" in
						c|a|q|x)	break;;
					esac
				done
				[ "$ANSWER" = x ] && exit
				[ "$ANSWER" = a ] && continue
				mkdir -p "$ROOT_DIR/kernel_config/$ARCH/$PLATFORM"
				cp .config "$ROOT_DIR/kernel_config/$ARCH/$PLATFORM/.config"
				[ "$ANSWER" = q ] && exit
				[ "$ANSWER" = c ] && break
			done
		fi
	else
		make "${PLATFORM}"_defconfig || exit 1
	fi
	make || exit 1
	mkdir -p "$ROOT_DIR/bin/$ARCH/linux"
	[ -f "arch/$ARCH/boot/Image" ] && cp "arch/$ARCH/boot/Image" "$ROOT_DIR/bin/$ARCH/linux"
	[ -f "arch/$ARCH/boot/zImage" ] && cp "arch/$ARCH/boot/zImage" "$ROOT_DIR/bin/$ARCH/linux"
	[ -f "arch/$ARCH/boot/bzImage" ] && cp "arch/$ARCH/boot/bzImage" "$ROOT_DIR/bin/$ARCH/linux"
	[ -f vmlinux ] && cp vmlinux "$ROOT_DIR/bin/$ARCH/linux"
	cd ../../../..
	echo -n > "bin/$ARCH/linux.nonextra"
fi
