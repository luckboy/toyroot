[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS $PKG_GLIB_GLIB_LIBS $PKG_LIBXML2_LIBS" STRIP="$STRIP" \
CROCO_CFLAGS="$PKG_DEP_GLIB_CFLAGS $PKG_DEP_LIBXML2_CFLAGS" \
CROCO_LIBS="$PKG_DEP_GLIB_GLIB_LIBS $PKG_DEP_LIBXML2_LIBS" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
