cd build
[ -f Makefile ] && make clean
mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr"
mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share"
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" ./configure --prefix="$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr" --mandir="$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man" --enable-curses --without-x "$TARGET" && make strip="$STRIP" install
STATUS=$?
[ $STATUS = 0 ] && rm -fr "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/cat1"
cd ..
[ $STATUS = 0 ]