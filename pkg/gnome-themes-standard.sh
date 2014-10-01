[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/glib-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib/glib-2.0/include -I$ROOT_DIR/bin/$ARCH/atk_dev/usr/include/atk-1.0 -I$ROOT_DIR/bin/$ARCH/pango_dev/usr/include/pango-1.0 -I$ROOT_DIR/bin/$ARCH/cairo_dev/usr/include/cairo -I$ROOT_DIR/bin/$ARCH/gdk-pixbuf_dev/usr/include/gdk-pixbuf-2.0" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS -lcroco-0.6 -lxml2 -lgmodule-2.0 -lgio-2.0 -lgobject-2.0 -lglib-2.0 -latk-1.0 -lpango-1.0 -lpangocairo-1.0 -lpangoft2-1.0 -lcairo -lcairo-gobject -lcairo-script-interpreter -lgdk_pixbuf-2.0 -lharfbuzz -lfontconfig -lfreetype -ltiff -lpixman-1 -ljpeg -lpng -lffi -lexpat -llzma -lbz2 -lz -lwayland-client -lwayland-cursor -lxkbcommon" STRIP="$STRIP" \
GTK3_ENGINE_CFLAGS="-I$ROOT_DIR/bin/$ARCH/gtk+_dev/usr/include/gtk-3.0 -I$ROOT_DIR/bin/$ARCH/librsvg_dev/usr/include/librsvg-2.0" \
GTK3_ENGINE_LIBS="-L$ROOT_DIR/bin$ARCH/gtk+/usr/lib -L$ROOT_DIR/bin$ARCH/librsvg/usr/lib -L$ROOT_DIR/bin$ARCH/librsvg_dev/usr/lib -lgdk-3 -lgtk-3 -lrsvg-2" \
HIGHCONTRAST_CFLAGS="-I$ROOT_DIR/bin/$ARCH/gtk+_dev/usr/include/gtk-3.0 -I$ROOT_DIR/bin/$ARCH/cairo_dev/usr/include/cairo" \
HIGHCONTRAST_LIBS="-L$ROOT_DIR/bin$ARCH/gtk+/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo_dev/usr/lib -lgdk-3 -lgtk-3 -lcairo -lcairo-gobject -lcairo-script-interpreter"  \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-gtk2-engine && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"