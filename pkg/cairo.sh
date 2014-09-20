[ -f Makefile ] && make clean
CC="$MUSL_GCC" CXX="$MUSL_GXX" CFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/freetype_dev/usr/include/freetype2" CXXFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/freetype_dev/usr/include/freetype2" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS -lfreetype -lpixman-1 -lpng -ljpeg -lz -lbz2" STRIP="$STRIP" \
png_CFLAGS="-I$ROOT_DIR/bin/$ARCH/libpng_dev/usr/include" \
png_LIBS="-L$ROOT_DIR/bin/$ARCH/libpng/usr/lib -L$ROOT_DIR/bin/$ARCH/libpng_dev/usr/lib -lpng" \
pixman_CFLAGS="-I$ROOT_DIR/bin/$ARCH/pixman_dev/usr/include/pixman-1" \
pixman_LIBS="-L$ROOT_DIR/bin/$ARCH/pixman/usr/lib -L$ROOT_DIR/bin/$ARCH/pixman_dev/usr/lib -lpixman-1" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-xlib --disable-xcb --without-x --disable-xlib-xrender --disable-gobject --disable-gtk-doc-html && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	if [ -d "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/gtk-doc" ]; then
		rm -fr "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/gtk-doc"
		[ "`ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share"`" = "" ] && rmdir "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share"
	fi
fi
[ $STATUS = 0 ]
