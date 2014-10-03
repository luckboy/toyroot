[ -f Makefile ] && make clean
CC="$MUSL_GCC" CXX="$MUSL_GXX" CFLAGS="$PKG_CFLAGS $PKG_FONTCONFIG_CFLAGS" CXXFLAGS="$PKG_CFLAGS $PKG_FONTCONFIG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS $PKG_FREETYPE_LIBS $PKG_FONTCONFIG_LIBS $PKG_LIBPNG_LIBS $PKG_PIXMAN_LIBS $PKGCFG_FONTCONFIG_LIBS $PKGCFG_PIXMAN_LIBS -ljpeg" STRIP="$STRIP" \
FREETYPE_CFLAGS="$PKGCFG_FREETYPE_CFLAGS" \
FREETYPE_LIBS="$PKGCFG_FREETYPE_LIBS" \
FONTCONFIG_CFLAGS="$PKGCFG_FONTCONFIG_CFLAGS" \
FONTCONFIG_LIBS="$PKGCFG_FONTCONFIG_LIBS" \
png_CFLAGS="$PKGCFG_LIBPNG_CFLAGS" \
png_LIBS="$PKGCFG_LIBPNG_LIBS" \
pixman_CFLAGS="$PKGCFG_PIXMAN_CFLAGS" \
pixman_LIBS="$PKGCFG_PIXMAN_LIBS" \
GOBJECT_CFLAGS="-I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/glib-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib/glib-2.0/include" \
GOBJECT_LIBS="-L$ROOT_DIR/bin/$ARCH/glib/usr/lib -L$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib -lgobject-2.0 -lglib-2.0" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-xlib --disable-xcb --without-x --disable-xlib-xrender && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	[ -d "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/cairo" ] && rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/cairo"/*.la
fi
[ $STATUS = 0 ]
