[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	if [ -e "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/$PKG_NAME-$PKG_VERSION/include" ]; then
		mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/include"
		mv "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/$PKG_NAME-$PKG_VERSION/include"/* "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/include"
		rm -fr "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/$PKG_NAME-$PKG_VERSION"
	fi
fi
[ $STATUS = 0 ]
