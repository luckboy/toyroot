[ -f Makefile ] && make clean
make CC="$MUSL_GCC" PREFIX="$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr" install &&
rm -fr "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/include" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib" &&
mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share" &&
mv "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/man/" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share"

