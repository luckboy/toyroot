[ -f Makefile ] && make clean
CC="$MUSL_GCC" BUILD_CC=gcc ./configure -default -confdir=/etc && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME" CFLAGS="$GCC_FLAGS -DDIRENT" LDFLAGS=-s
STATUS=$?
if [ $STATUS = 0 ]; then
	mv "$ROOT_DIR/bin/$ARCH/$PKG_NAME/etc/man.conf" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/etc/man.conf.tmp"
	sed \
		-e "s:/usr/bin/geqn:/usr/bin/eqn:" \
		-e "s:/usr/bin/gtbl:/usr/bin/tbl:" \
		-e "s:/usr/bin/gpic:/usr/bin/pic:" \
		-e "s:/bin/less -is:/usr/bin/less -isr:" \
		-e "s:COMPRESS\t/bin/xz:COMPRESS\t/usr/bin/gzip:" \
		-e "s:COMPRESS_EXT\t\.xz:COMPRESS_EXT\t\.gz:" \
		-e "s:/bin/gunzip:/usr/bin/gunzip:" \
		-e "s:/bin/bzip2:/usr/bin/bzip2:" \
		-e "s:/bin/zcat:/usr/bin/zcat:" \
		"$ROOT_DIR/bin/$ARCH/$PKG_NAME/etc/man.conf.tmp" > "$ROOT_DIR/bin/$ARCH/$PKG_NAME/etc/man.conf"
		rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/etc/man.conf.tmp"
		cp man/en/makewhatis.man "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man8/makewhatis.8"
fi
[ $STATUS = 0 ]
