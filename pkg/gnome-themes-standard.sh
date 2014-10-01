[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS $PKG_GTKX_CFLAGS $PKG_LIBRSVG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS $PKG_GTKX_LIBS $PKG_LIBRSVG_LIBS" STRIP="$STRIP" \
GTK3_ENGINE_CFLAGS="$PKG_DEP_GTKX_CFLAGS $PKG_DEP_LIBRSVG_CFLAGS" \
GTK3_ENGINE_LIBS="$PKG_DEP_GTKX_LIBS $PKG_DEP_LIBRSVG_LIBS" \
HIGHCONTRAST_CFLAGS="$PKG_DEP_GTKX_CFLAGS $PKG_DEP_CAIRO_GOBJECT_CFLAGS" \
HIGHCONTRAST_LIBS="$PKG_DEP_GTKX_LIBS $PKG_PEP_CAIRO_GOBJECT_LIBS"  \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-gtk2-engine && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
