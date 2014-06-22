cd build
[ -f Makefile ] && make clean
mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr"
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" ./configure --prefix="$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr" --enable-curses --without-x "$TARGET" && make strip="$STRIP" install
STATUS=$?
cd ..
[ $STATUS = 0 ]

