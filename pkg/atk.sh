[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS $PKG_GLIB_CFLAGS" LDFLAGS="$PKG_LDFLAGS $PKG_GLIB_LDFLAGS" LIBS="$PKG_LIBS $PKG_GLIB_GOBJECT_LIBS" STRIP="$STRIP" \
DEP_CFLAGS="$PKG_DEP_GLIB_CFLAGS" \
DEP_LIBS="$PKG_DEP_GLIB_GOBJECT_LIBS" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
