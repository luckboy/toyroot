[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS $PKG_LIBPNG_CFLAGS" LDFLAGS="$PKG_LDFLAGS $PKG_LIBPNG_LDFLAGS" LIBS="$PKG_LIBS $PKG_LIBPNG_LIBS -lbz2" STRIP="$STRIP" \
LIBPNG_CFLAGS="$PKG_DEP_LIBPNG_CFLAGS" \
LIBPNG_LIBS="$PKG_DEP_LIBPNG_LIBS" \
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
