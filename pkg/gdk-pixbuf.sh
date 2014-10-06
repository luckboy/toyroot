[ -f Makefile ] && make clean
CC="$MUSL_GCC" CPPFLAGS="-I$ROOT_DIR/bin/$ARCH/jpeg_dev/usr/include" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS -ltiff -ljpeg -llzma -lz" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-gio-sniffing && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME" GLIB_MKENUMS=glib-mkenums GLIB_GENMARSHAL=glib-genmarshal
STATUS=$?
[ $STATUS = 0 ] && rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders"/*.la
[ $STATUS = 0 ]
