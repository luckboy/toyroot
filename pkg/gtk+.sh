[ -f Makefile ] && make clean
CC="$MUSL_GCC" CXX="$GXX_UC" CFLAGS="$PKG_CFLAGS" CXXFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS -lgdk_pixbuf-2.0 -lharfbuzz -lgmodule-2.0 -lgio-2.0 -lgobject-2.0 -lglib-2.0 -lfontconfig -lfreetype -ltiff -lpixman-1 -ljpeg -lpng -lffi -lexpat -llzma -lbz2 -lz" STRIP="$STRIP" \
BASE_DEPENDENCIES_CFLAGS="-I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/glib-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/gio-unix-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib/glib-2.0/include -I$ROOT_DIR/bin/$ARCH/atk_dev/usr/include/atk-1.0 -I$ROOT_DIR/bin/$ARCH/pango_dev/usr/include/pango-1.0 -I$ROOT_DIR/bin/$ARCH/cairo_dev/usr/include/cairo -I$ROOT_DIR/bin/$ARCH/gdk-pixbuf_dev/usr/include/gdk-pixbuf-2.0" \
BASE_DEPENDENCIES_LIBS="-L$ROOT_DIR/bin/$ARCH/glib/usr/lib -L$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/atk/usr/lib -L$ROOT_DIR/bin/$ARCH/atk_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/pango/usr/lib -L$ROOT_DIR/bin/$ARCH/pango_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/gdk-pixbuf/usr/lib -L$ROOT_DIR/bin/$ARCH/gdk-pixbuf_dev/usr/lib -lgmodule-2.0 -lgio-2.0 -lgobject-2.0 -lglib-2.0 -latk-1.0 -lpango-1.0 -lpangocairo-1.0 -lpangoft2-1.0 -lcairo -lcairo-gobject -lcairo-script-interpreter -lgdk_pixbuf-2.0" \
CAIRO_BACKEND_CFLAGS="-I$ROOT_DIR/bin/$ARCH/cairo_dev/usr/include/cairo" \
CAIRO_BACKEND_LIBS="-L$ROOT_DIR/bin/$ARCH/cairo/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo_dev/usr/lib -lcairo -lcairo-gobject -lcairo-script-interpreter" \
GDK_DEP_CFLAGS="-I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/glib-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/gio-unix-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib/glib-2.0/include  -I$ROOT_DIR/bin/$ARCH/pango_dev/usr/include/pango-1.0 -I$ROOT_DIR/bin/$ARCH/cairo_dev/usr/include/cairo -I$ROOT_DIR/bin/$ARCH/gdk-pixbuf_dev/usr/include/gdk-pixbuf-2.0 -I$ROOT_DIR/bin/$ARCH/wayland_dev/usr/include -I$ROOT_DIR/bin/$ARCH/libxkbcommon_dev/usr/include/xkbcommon" \
GDK_DEP_LIBS="-L$ROOT_DIR/bin/$ARCH/glib/usr/lib -L$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/pango/usr/lib -L$ROOT_DIR/bin/$ARCH/pango_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/gdk-pixbuf/usr/lib -L$ROOT_DIR/bin/$ARCH/gdk-pixbuf_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/wayland_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/wayland/usr/lib -L$ROOT_DIR/bin/$ARCH/libxkbcommon/usr/lib -L$ROOT_DIR/bin/$ARCH/libxkbcommon_dev/usr/lib -lgmodule-2.0 -lgio-2.0 -lgobject-2.0 -lglib-2.0 -lpango-1.0 -lpangocairo-1.0 -lpangoft2-1.0 -lcairo -lcairo-gobject -lcairo-script-interpreter -lgdk_pixbuf-2.0 -lwayland-client -lwayland-cursor -lxkbcommon" \
ATK_CFLAGS="-I$ROOT_DIR/bin/$ARCH/atk_dev/usr/include/atk-1.0" \
ATK_LIBS="-L$ROOT_DIR/bin/$ARCH/atk/usr/lib -L$ROOT_DIR/bin/$ARCH/atk_dev/usr/lib -latk-1.0" \
GTK_DEP_CFLAGS="-I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/glib-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/gio-unix-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib/glib-2.0/include -I$ROOT_DIR/bin/$ARCH/atk_dev/usr/include/atk-1.0 -I$ROOT_DIR/bin/$ARCH/pango_dev/usr/include/pango-1.0 -I$ROOT_DIR/bin/$ARCH/cairo_dev/usr/include/cairo -I$ROOT_DIR/bin/$ARCH/gdk-pixbuf_dev/usr/include/gdk-pixbuf-2.0" \
GTK_DEP_LIBS="-L$ROOT_DIR/bin/$ARCH/glib/usr/lib -L$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/atk/usr/lib -L$ROOT_DIR/bin/$ARCH/atk_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/pango/usr/lib -L$ROOT_DIR/bin/$ARCH/pango_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/gdk-pixbuf/usr/lib -L$ROOT_DIR/bin/$ARCH/gdk-pixbuf_dev/usr/lib -lgmodule-2.0 -lgio-2.0 -lgobject-2.0 -lglib-2.0 -latk-1.0 -lpango-1.0 -lpangocairo-1.0 -lpangoft2-1.0 -lcairo -lcairo-gobject -lcairo-script-interpreter -lgdk_pixbuf-2.0" \
GMODULE_CFLAGS="-I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/glib-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib/glib-2.0/include" \
GMODULE_LIBS="-L$ROOT_DIR/bin/$ARCH/glib/usr/lib -L$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib -lgmodule-2.0 -lgio-2.0 -lgobject-2.0 -lglib-2.0" \
WAYLAND_SCANNER="$ROOT_DIR/build/$ARCH/wayland/wayland-host/wayland-scanner" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-wayland-backend --without-x && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME" GLIB_MKENUMS=glib-mkenums GLIB_GENMARSHAL=glib-genmarshal GLIB_COMPILE_RESOURCES=glib-compile-resources
STATUS=$?
if [ $STATUS = 0 ]; then
	[ -d "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/gtk-3.0/3.0.0/immodules" ] && rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/gtk-3.0/3.0.0/immodules"/*.la
	[ -d "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/gtk-3.0/3.0.0/printbackends" ] && rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/gtk-3.0/3.0.0/printbackends"/*.la
	if [ -d "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/glib-2.0/schemas" ]; then
		rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/glib-2.0/schemas"/*.compiled
		glib-compile-schemas "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/glib-2.0/schemas"
	fi
fi
[ $STATUS = 0 ]
