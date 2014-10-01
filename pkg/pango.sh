[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/freetype_dev/usr/include/freetype2" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS -lfreetype -lpixman-1 -ljpeg -lpng -lffi -lexpat -llzma -lbz2 -lz" STRIP="$STRIP" \
CAIRO_CFLAGS="-I$ROOT_DIR/bin/$ARCH/cairo_dev/usr/include/cairo" \
CAIRO_LIBS="-L$ROOT_DIR/bin/$ARCH/cairo/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo_dev/usr/lib -lcairo -lcairo-gobject -lcairo-script-interpreter" \
FREETYPE_CFLAGS="-I$ROOT_DIR/bin/$ARCH/freetype_dev/usr/include/freetype2" \
FREETYPE_LIBS="-L$ROOT_DIR/bin/$ARCH/freetype/usr/lib -L$ROOT_DIR/bin/$ARCH/freetype_dev/usr/lib -lfreetype" \
FONTCONFIG_CFLAGS="-I$ROOT_DIR/bin/$ARCH/fontconfig_dev/usr/include" \
FONTCONFIG_LIBS="-L$ROOT_DIR/bin/$ARCH/fontconfig/usr/lib -L$ROOT_DIR/bin/$ARCH/fontconfig_dev/usr/lib -lfontconfig" \
HARFBUZZ_CFLAGS="-I$ROOT_DIR/bin/$ARCH/harfbuzz_dev/usr/include/harfbuzz" \
HARFBUZZ_LIBS="-L$ROOT_DIR/bin/$ARCH/harfbuzz/usr/lib -L$ROOT_DIR/bin/$ARCH//harfbuzz_dev/usr/lib -lharfbuzz" \
GLIB_CFLAGS="-I$ROOT_DIR/bin/$ARCH/glib_dev/usr/include/glib-2.0 -I$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib/glib-2.0/include" \
GLIB_LIBS="-L$ROOT_DIR/bin/$ARCH/glib/usr/lib -L$ROOT_DIR/bin/$ARCH/glib_dev/usr/lib -lgmodule-2.0 -lgio-2.0 -lgobject-2.0 -lglib-2.0" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-symbol-lookup && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
[ $STATUS = 0 ] && rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/pango-1.8.0/modules"/*.la
[ $STATUS = 0 ]
