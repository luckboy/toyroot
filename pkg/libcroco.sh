[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS -lxml2 -lglib-2.0 -llzma -lz" STRIP="$STRIP" \
CROCO_CFLAGS="-I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/glib-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib/glib-2.0/include -I$ROOT_DIR/bin/$ARCH/libxml2_dev/usr/include/libxml2" \
CROCO_LIBS="-L$ROOT_DIR/bin/$ARCH/glib/usr/lib -L$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/libxml2/usr/lib -L$ROOT_DIR/bin/$ARCH/libxml2_dev/usr/lib -lglib-2.0 -lxml2" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
