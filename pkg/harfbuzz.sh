[ -f Makefile ] && make clean
CC="$MUSL_GCC" CXX="$GXX_UC" CFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/freetype_dev/usr/include/freetype2" CXXFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/freetype_dev/usr/include/freetype2" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS -lfreetype -lpng  -lffi -lbz2 -lz" STRIP="$STRIP" \
GLIB_CFLAGS="-I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/glib-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib/glib-2.0/include" \
GLIB_LIBS="-L$ROOT_DIR/bin/$ARCH/glib/usr/lib -L$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib -lglib-2.0" \
GOBJECT_CFLAGS="-I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/glib-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib/glib-2.0/include" \
GOBJECT_LIBS="-L$ROOT_DIR/bin/$ARCH/glib/usr/lib -L$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib -lgobject-2.0 -lglib-2.0" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
