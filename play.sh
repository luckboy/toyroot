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

FS_NAME=""
IS_FS_NAME=false
ISO=false
ARCH=""
IS_ARCH=false
MACHINE=""
IS_MACHINE=false
while [ $# -gt 0 ]; do
	case "$1" in
		--fs-name=*)
			FS_NAME="`echo "$1" | sed 's/^[^=]*=//'`"
			IS_FS_NAME=true
			;;
		--iso)
			ISO=true
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
if [ $IS_FS_NAME != true ]; then
	if [ $ISO != true ]; then
		FS_NAME=root
	else
		FS_NAME=iso
	fi
fi
[ $IS_ARCH != true ] && ARCH="`arch`"

case "$ARCH" in
	arm)
		[ $IS_MACHINE != true ] && MACHINE=vexpress-a9
		qemu-system-arm -M "$MACHINE" -drive file=dist/arm/fs/$FS_NAME.img,if=sd -kernel bin/arm/linux/zImage -append "root=/dev/mmcblk0 logo.nologo devtmpfs.mount=1"
		;;
	x86_64)
		[ $IS_MACHINE != true ] && MACHINE=pc-1.0
		if [ $ISO != true ]; then
			qemu-system-x86_64 -M "$MACHINE" -hda dist/x86_64/fs/$FS_NAME.img -kernel bin/x86_64/linux/bzImage -append "root=/dev/sda rootfstype=ext2 devtmpfs.mount=1" -netdev user,id=mynet -device e1000,netdev=mynet
		else
			qemu-system-x86_64 -M "$MACHINE" -boot c -cdrom dist/x86_64/fs/$FS_NAME.img -netdev user,id=mynet -device e1000,netdev=mynet			
		fi
		;;
	*)
		echo "Unsupported architecture" >&2
		exit 1
		;;
esac

