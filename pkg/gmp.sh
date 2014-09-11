[ -f Makefile ] && make clean
case "$ARCH" in
	arm)	GMP_CFLAGS_ASM="-Wa,-mimplicit-it=thumb";;
	*)	GMP_CFLAGS_ASM="";;
esac
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS $GMP_CFLAGS_ASM" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
