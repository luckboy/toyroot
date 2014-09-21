[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/awk"
	rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin"/gawk-*
	rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/gawk"/*.la
fi
[ $STATUS = 0 ]
