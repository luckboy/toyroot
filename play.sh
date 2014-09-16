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

NAME=""
IS_NAME=false
PLAY_KIND=rootfs
ARCH=""
IS_ARCH=false
MACHINE=""
IS_MACHINE=false
while [ $# -gt 0 ]; do
	case "$1" in
		--name=*)
			NAME="`echo "$1" | sed 's/^[^=]*=//'`"
			IS_NAME=true
			;;
		--disk)
			PLAY_KIND=disk
			;;
		--initrd)
			PLAY_KIND=initrd
			;;
		--iso)
			PLAY_KIND=iso
			;;
		*)
			if [ $IS_ARCH != true ]; then
				ARCH="$1"
				IS_ARCH=true
			elif [ $IS_MACHINE != true ]; then
				MACHINE="$1"
				IS_MACHINE=true
			fi
			;;
	esac
	shift
done
if [ $IS_NAME != true ]; then
	case $PLAY_KIND in
		initrd)	NAME=initrd;;
		iso)	NAME=iso;;
		*)	NAME=root;
	esac
fi
[ $IS_ARCH != true ] && ARCH="`arch`"

case "$ARCH" in
	arm)
		[ $IS_MACHINE != true ] && MACHINE=vexpress-a9
		case $PLAY_KIND in
			initrd)
				qemu-system-arm -M "$MACHINE" -kernel bin/arm/linux/zImage -append "logo.nologo devtmpfs.mount=1" -initrd "dist/arm/fs/$NAME.img"
				;;
			*)
				qemu-system-arm -M "$MACHINE" -drive "file=dist/arm/fs/$NAME.img,if=sd" -kernel bin/arm/linux/zImage -append "root=/dev/mmcblk0 logo.nologo devtmpfs.mount=1"
				;;
		esac
		;;
	x86_64)
		[ $IS_MACHINE != true ] && MACHINE=pc-1.0
		case $PLAY_KIND in
			disk)
				qemu-system-x86_64 -M "$MACHINE" -boot c -hda "dist/x86_64/disk/$NAME.img" -netdev user,id=mynet -device e1000,netdev=mynet
				;;
			initrd)
				qemu-system-x86_64 -M "$MACHINE" -kernel bin/x86_64/linux/bzImage -append "devtmpfs.mount=1" -initrd "dist/x86_64/fs/$NAME.img" -netdev user,id=mynet -device e1000,netdev=mynet
				;;
			iso)
				qemu-system-x86_64 -M "$MACHINE" -boot d -cdrom "dist/x86_64/fs/$NAME.img" -netdev user,id=mynet -device e1000,netdev=mynet
				;;
			*)
				qemu-system-x86_64 -M "$MACHINE" -hda "dist/x86_64/fs/$NAME.img" -kernel bin/x86_64/linux/bzImage -append "root=/dev/sda rootfstype=ext2 devtmpfs.mount=1" -netdev user,id=mynet -device e1000,netdev=mynet
				;;
			
		esac
		;;
	*)
		echo "Unsupported architecture" >&2
		exit 1
		;;
esac

