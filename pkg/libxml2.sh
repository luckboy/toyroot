[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS -llzma -lz" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --without-python && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
