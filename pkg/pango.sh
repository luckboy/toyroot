[ -f Makefile ] && make clean
CC="$MUSL_GCC" CXX="$GXX_UC" CFLAGS="$PKG_CFLAGS" CXXFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-symbol-lookup --without-xft && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
[ $STATUS = 0 ] && rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/pango/1.8.0/modules"/*.la
[ $STATUS = 0 ]
