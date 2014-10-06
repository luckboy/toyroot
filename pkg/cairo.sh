[ -f Makefile ] && make clean
CC="$MUSL_GCC" CXX="$GXX_UC" CFLAGS="$PKG_CFLAGS" CXXFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS `"$PKG_CONFIG" --libs freetype2 fontconfig pixman-1 libpng16` -ljpeg" STRIP="$STRIP" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-xlib --disable-xcb --without-x --disable-xlib-xrender && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	[ -d "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/cairo" ] && rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/cairo"/*.la
fi
[ $STATUS = 0 ]
