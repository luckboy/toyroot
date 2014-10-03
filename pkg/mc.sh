[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure \
	--host="$TARGET" \
	--prefix=/usr \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--with-screen=ncurses \
	--without-libintl-prefix \
	--disable-nls \
&& make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"