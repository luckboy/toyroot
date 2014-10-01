[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS $PKG_GTKX_CFLAGS" LDFLAGS="$PKG_LDFLAGS $PKG_GTKX_LDFLAGS" LIBS="$PKG_LIBS $PKG_GTKX_LIBS" STRIP="$STRIP" \
GTK_CFLAGS="$PKG_DEP_GTKX_CFLAGS" \
GTK_LIBS="$PKG_DEP_GTKX_LIBS" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
