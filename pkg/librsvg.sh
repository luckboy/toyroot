[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-introspection && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME" gdk_pixbuf_binarydir=/usr/lib/gdk-pixbuf-2.0/2.10.0/ gdk_pixbuf_cache_file=/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache gdk_pixbuf_moduledir=/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders
STATUS=$?
[ $STATUS = 0 ] && rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders"/*.la
[ $STATUS = 0 ]
