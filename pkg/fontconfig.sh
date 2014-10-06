[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	cp "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/pkgconfig/fontconfig.pc" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/pkgconfig/fontconfig.pc.orig"
	sed "s@$ROOT_DIR/bin/$ARCH/freetype_dev@@g" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/pkgconfig/fontconfig.pc.orig" > "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/pkgconfig/fontconfig.pc"
	rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/pkgconfig/fontconfig.pc.orig"
fi
[ $STATUS = 0 ]
