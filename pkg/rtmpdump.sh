[ -f Makefile ] && make clean
LD=ld
[ "$TARGET" != "$HOST" ] && LD="$TARGET-ld"
RTMPDUMP_CRYPTO=""
[ ! -d "$ROORT_DIR/bin/$ARCH/openssl" ] && RTMPDUMP_CRYPTO=OPENSSL
make CC="$MUSL_GCC" LD="$LD" XCFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" XLIBS="$PKG_LIBS" CRYPTO=$RTMPDUMP_CRYPTO DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME" prefix=/usr mandir=/usr/share/man install
