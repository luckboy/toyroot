[ -f Makefile ] && make clean
make CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS -D_FILE_OFFSET_BITS=64" PREFIX="$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr" install &&
mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share" &&
mv "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/man/" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share"
