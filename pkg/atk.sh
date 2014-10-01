[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS -lffi -lz" STRIP="$STRIP" \
DEP_CFLAGS="-I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include" \
DEP_LIBS="-L$ROOT_DIR/bin/$ARCH/glib/usr/lib -L$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib -lglib-2.0 -lgobject-2.0" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
