[ -f Makefile ] && make clean
WGET_CONFIGURE_OPTS_SSL=--without-ssl
[ ! -d "$ROORT_DIR/bin/$ARCH/openssl" ] && WGET_CONFIGURE_OPTS_SSL=--with-ssl=openssl
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc $WGET_CONFIGURE_OPTS_SSL && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"

