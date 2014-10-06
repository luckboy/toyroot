[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" PKG_CONFIG=pkg-config ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-dependency-tracking && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
