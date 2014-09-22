[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP -lz" \
LIBPNG_CFLAGS="-I$ROOT_DIR/bin/$ARCH/libpng_dev/usr/include" \
LIBPNG_LIBS="-L$ROOT_DIR/bin/$ARCH/libpng/usr/lib -L$ROOT_DIR/bin/$ARCH/libpng_dev/usr/lib -lpng" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	[ "`ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin"`" = "" ] && rmdir "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin"
	[ "`ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/aclocal"`" = "" ] && rmdir "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/aclocal"
	[ "`ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man1"`" = "" ] && rmdir "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man1"
	[ "`ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man"`" = "" ] && rmdir "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man"
	[ "`ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share"`" = "" ] && rmdir "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share"
fi
[ $STATUS = 0 ]
