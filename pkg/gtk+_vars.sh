PKG_GTKX_CFLAGS="$PKG_DEP_GLIB_CFLAGS $PKG_DEP_ATK_CFLAGS $PKG_DEP_PANGO_CFLAGS $PKG_DEP_CAIRO_GOBJECT_CFLAGS $PKG_DEP_GDK_PIXBUF_CFLAGS"
PKG_GTKX_LDFLAGS=""
PKG_GTKX_LIBS="$PKG_GLIB_LIBS $PKG_ATK_LIBS $PKG_PANGO_LIBS $PKG_CAIRO_GOBJECT_LIBS $PKG_GDK_PIXBUF_LIBS $PKG_WAYLAND_LIBS $PKG_LIBXKBCOMMON_LIBS $PKG_DEP_GLIB_LIBS $PKG_DEP_ATK_LIBS $PKG_DEP_PANGO_LIBS $PKG_DEP_CAIRO_GOBJECT_LIBS $PKG_DEP_GDK_PIXBUF_LIBS $PKG_DEP_WAYLAND_CLIENT_LIBS $PKG_DEP_WAYLAND_CURSOR_LIBS $PKG_DEP_LIBXKBCOMMON_LIBS"
PKG_DEP_GTKX_CFLAGS="-I$ROOT_DIR/bin/$ARCH/gtk+_dev/usr/include/gtk-3.0"
PKG_DEP_GTKX_LIBS="-lgdk-3 -lgtk-3"