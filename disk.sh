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

NAME=root
DISK_SIZE=""
IS_DISK_SIZE=false
FS_SIZE=""
IS_FS_SIZE=false
CYLINDERS=""
ARE_CYLINDERS=false
HEADS=""
ARE_HEADS=false
SECTORS=""
ARE_SECTORS=false
GRUB_DEV="(hd0)"
NO_BOOT=false
while [ $# -gt 0 ]; do
	case "$1" in
		--name=*)
			NAME="`echo "$1" | sed 's/^[^=]*=//'`"
			;;
		--disk-size=*)
			DISK_SIZE="`echo "$1" | sed 's/^[^=]*=//'`"
			IS_DISK_SIZE=true
			;;
		--fs-size=*)
			FS_SIZE="`echo "$1" | sed 's/^[^=]*=//'`"
			IS_FS_SIZE=true
			;;
		--cylinders=*)
			CYLINDERS="`echo "$1" | sed 's/^[^=]*=//'`"
			ARE_CYLINDERS=true
			;;
		--heads=*)
			HEADS="`echo "$1" | sed 's/^[^=]*=//'`"
			ARE_HEADS=true
			;;
		--sectors=*)
			SECTORS="`echo "$1" | sed 's/^[^=]*=//'`"
			ARE_SECTORS=true
			;;
		--grub-dev=*)
			GRUB_DEV="`echo "$1" | sed 's/^[^=]*=//'`"
			;;
		--no-boot)
			NO_BOOT=true
			;;
	esac
	shift
done

DISK_IMG="dist/$ARCH/disk/$NAME.img"
FS_IMG="dist/$ARCH/fs/$NAME.img"

mkdir -p "dist/$ARCH/disk"
if [ $IS_DISK_SIZE != true ]; then
	FS_SIZE_IN_K="`stat -c '%s' "$FS_IMG"`"
	FS_SIZE="`expr "$FS_SIZE_IN_K" / 512 + \( "$FS_SIZE_IN_K" % 512 != 0 \)`"
fi
if [ $IS_DISK_SIZE != true ]; then
	if [ $ARE_CYLINDERS = true -a $ARE_HEADS = true -a $ARE_SECTORS = true ]; then
		DISK_SIZE="`expr "$CYLINDERS" \* "$HEADS" \* "$SECTORS"`"
	else
		TMP_DISK_SIZE="`expr "$FS_SIZE" + 2048`"
		CYLINDERS="`expr "$TMP_DISK_SIZE" / 16065 + \( "$TMP_DISK_SIZE" % 16065 != 0 \)`"
		HEADS=255
		SECTORS=63
		DISK_SIZE="`expr "$CYLINDERS" \* "$HEADS" \* "$SECTORS"`"
	fi
fi
dd if=/dev/zero of="$DISK_IMG" bs=512 count="$DISK_SIZE"
SFDISK_INPUT="2028,,,*"
[ $NO_BOOT = true ] && SFDISK_INPUT="2028"
(echo "2048,,,*" | sfdisk -C "$CYLINDERS" -H "$HEADS" -S "$SECTORS" -u S "$DISK_IMG") || exit 1
dd if="$FS_IMG" of="$DISK_IMG" bs=512 seek=2048 count="$FS_SIZE" conv=notrunc

if [ $NO_BOOT != true ]; then
	case "$ARCH" in
		i[3-6]86|x86_64)
			GRUB_PART_DEV="`echo "$GRUB_DEV" | sed 's/[)]$/,0\)/'`"
			("./bin/$ARCH/grub-host/sbin/grub" --batch <<EOT
device $GRUB_DEV $DISK_IMG
root $GRUB_PART_DEV
setup $GRUB_DEV
quit
EOT
) || exit 1
			;;
	esac
fi
exit 0
