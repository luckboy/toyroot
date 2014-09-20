[ -f Makefile ] && make clean
CC="$MUSL_GCC" CCAS="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" CCASFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS -lz" STRIP="$STRIP" \
PNG_CFLAGS="-I$ROOT_DIR/bin/$ARCH/libpng_dev/usr/include" \
PNG_LIBS="-L$ROOT_DIR/bin/$ARCH/libpng/usr/lib -L$ROOT_DIR/bin/$ARCH/libpng_dev/usr/lib -lpng" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-gtk && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
