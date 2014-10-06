[ -f Makefile ] && make clean
CC="$MUSL_GCC" CXX="$GXX_UC" CFLAGS="$PKG_CFLAGS" CXXFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" \
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
