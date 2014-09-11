[ -f Makefile ] && make clean
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	PKG_AUTOMAKE_VERSION="`echo "$PKG_VERSION" | cut -d . -f 1,2`"
	rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/aclocal"
	rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/automake"
	ln -sf "aclocal-$PKG_AUTOMAKE_VERSION" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/aclocal"
	ln -sf "automake-$PKG_AUTOMAKE_VERSION" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/automake"
	rm -fr "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/doc"
fi
[ $STATUS = 0 ]
