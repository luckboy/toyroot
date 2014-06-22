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

. ./kernel.txt

GCC="${GCC:=gcc}"

ROOT_DIR=`pwd`
TARGET=`$GCC -dumpmachine`
HOST=`gcc -dumpmachine`
export ARCH=`$GCC -dumpmachine | cut -d - -f 1`

case "$ARCH" in
	arm)	PLATFORM="${PLATFORM:=vexpress}";;
	*)	PLATFORM="${PLATFORM:=$ARCH}";;
esac

. ./functions.sh

download_source linux-$LINUX_VERSION.tar.xz $LINUX_DOWNLOAD_URL

extract_and_patch_package linux linux-$LINUX_VERSION.tar.xz linux-$LINUX_VERSION

mkdir -p "$ROOT_DIR/bin/$ARCH"

if [ ! -d "$ROOT_DIR/bin/$ARCH/linux" ]; then
	cd "build/$ARCH/linux/linux-$LINUX_VERSION"
	if [ "$TARGET" != "$HOST" ]; then
		export CROSS_COMPILE="$TARGET-"
	fi
	make clean
	(make "${PLATFORM}"_defconfig && make) || exit 1
	mkdir -p "$ROOT_DIR/bin/$ARCH/linux"
	[ -f "arch/$ARCH/boot/Image" ] && cp "arch/$ARCH/boot/Image" "$ROOT_DIR/bin/$ARCH/linux"
	[ -f "arch/$ARCH/boot/zImage" ] && cp "arch/$ARCH/boot/zImage" "$ROOT_DIR/bin/$ARCH/linux"
	[ -f "arch/$ARCH/boot/bzImage" ] && cp "arch/$ARCH/boot/bzImage" "$ROOT_DIR/bin/$ARCH/linux"
	[ -f vmlinux ] && cp vmlinux "$ROOT_DIR/bin/$ARCH/linux"
	cd ../../../..
fi

