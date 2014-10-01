[ -f Makefile ] && make clean
CC="$MUSL_GCC" CXX="$MUSL_GXX" CFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/freetype_dev/usr/include/freetype2" CXXFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/freetype_dev/usr/include/freetype2" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS -lfontconfig -lfreetype -lpixman-1 -lexpat -lpng -ljpeg -lz -lbz2" STRIP="$STRIP" \
FREETYPE_CFLAGS="-I$ROOT_DIR/bin/$ARCH/freetype_dev/usr/include/freetype2" \
FREETYPE_LIBS="-L$ROOT_DIR/bin/$ARCH/freetype/usr/lib -L$ROOT_DIR/bin/$ARCH/freetype_dev/usr/lib -lfreetype" \
FONTCONFIG_CFLAGS="-I$ROOT_DIR/bin/$ARCH/fontconfig_dev/usr/include" \
FONTCONFIG_LIBS="-L$ROOT_DIR/bin/$ARCH/fontconfig/usr/lib -L$ROOT_DIR/bin/$ARCH/fontconfig_dev/usr/lib -lfontconfig" \
png_CFLAGS="-I$ROOT_DIR/bin/$ARCH/libpng_dev/usr/include" \
png_LIBS="-L$ROOT_DIR/bin/$ARCH/libpng/usr/lib -L$ROOT_DIR/bin/$ARCH/libpng_dev/usr/lib -lpng" \
pixman_CFLAGS="-I$ROOT_DIR/bin/$ARCH/pixman_dev/usr/include/pixman-1" \
pixman_LIBS="-L$ROOT_DIR/bin/$ARCH/pixman/usr/lib -L$ROOT_DIR/bin/$ARCH/pixman_dev/usr/lib -lpixman-1" \
GOBJECT_CFLAGS="-I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/glib-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib/glib-2.0/include" \
GOBJECT_LIBS="-L$ROOT_DIR/bin/$ARCH/glib/usr/lib -L$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib -lgobject-2.0 -lglib-2.0" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-xlib --disable-xcb --without-x --disable-xlib-xrender && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	[ -d "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/cairo" ] && rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/cairo"/*.la
fi
[ $STATUS = 0 ]
