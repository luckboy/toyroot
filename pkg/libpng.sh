[ -f Makefile ] && make clean
PKG_CFLAGS_WITHOUT_ZLIB="`echo $PKG_CFLAGS | sed "s@-I$ROOT_DIR/bin/$ARCH/zlib_dev/usr/include@@"`"
CC="$MUSL_GCC" CXX="$MUSL_GXX" CFLAGS="$PKG_CFLAGS_WITHOUT_ZLIB" CPPFLAGS="-I$ROOT_DIR/bin/$ARCH/zlib_dev/usr/include" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
