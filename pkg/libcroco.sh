[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS $PKG_GLIB_GLIB_LIBS $PKG_LIBXML2_LIBS" STRIP="$STRIP" \
CROCO_CFLAGS="$PKGCFG_GLIB_CFLAGS $PKGCFG_LIBXML2_CFLAGS" \
CROCO_LIBS="$PKGCFG_GLIB_GLIB_LIBS $PKGCFG_LIBXML2_LIBS" \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	mv "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/croco-0.6-config" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/croco-0.6-config.orig"
	sed -e "s@$ROOT_DIR/bin/$ARCH/glib_dev/@/@g" -e "s@$ROOT_DIR/bin/$ARCH/libxml2_dev/@/@g" -e 's/ @GLIB2_CFLAGS@//g' -e 's/ @LIBXML2_CFLAGS@//g' -e 's/ @GLIB2_LIBS@//' -e 's/ @LIBXML2_LIBS@//' "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/croco-0.6-config.orig" > "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/croco-0.6-config"
	chmod 755 "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/croco-0.6-config"
	rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/croco-0.6-config.orig"
fi
[ $STATUS = 0 ]