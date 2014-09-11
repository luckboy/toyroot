[ -f Makefile ] && make clean
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/info/standards.info"
	rm -fr "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/emacs"
fi
[ $STATUS = 0 ]