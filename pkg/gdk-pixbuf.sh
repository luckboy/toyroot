[ -f Makefile ] && make clean
CC="$MUSL_GCC" CPPFLAGS="-I$ROOT_DIR/bin/$ARCH/jpeg_dev/usr/include" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS $PKG_TIFF_LIBS $PKG_DEP_LIBPNG_LIBS -lffi" STRIP="$STRIP" \
BASE_DEPENDENCIES_CFLAGS="$PKG_DEP_GLIB_CFLAGS $PKG_DEP_TIFF_CFLAGS $PKG_DEP_LIBPNG_CFLAGS -I$ROOT_DIR/bin/$ARCH/jpeg_dev/usr/include" \
BASE_DEPENDENCIES_LIBS="$PKG_DEP_GLIB_LIBS $PKG_DEP_TIFF_LIBS $PKG_DEP_LIBPNG_LIBS -ljpeg" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-gio-sniffing && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME" GLIB_MKENUMS=glib-mkenums GLIB_GENMARSHAL=glib-genmarshal GDK_PIXBUF_DEP_CFLAGS="-pthread -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/glib-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib/glib-2.0/include" GDK_PIXBUF_DEP_LIBS="-pthread -lgmodule-2.0 -lgio-2.0 -lgobject-2.0 -lglib-2.0 -ltiff -ljpeg -lpng -lffi -llzma -lz" LIBPNG="-lpng"
STATUS=$?
[ $STATUS = 0 ] && rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders"/*.la
[ $STATUS = 0 ]
