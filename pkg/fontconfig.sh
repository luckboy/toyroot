[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/freetype_dev/usr/include/freetype2" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS -lexpat -lpng -lbz2 -lz" STRIP="$STRIP" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
