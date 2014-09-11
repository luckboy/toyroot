[ -f Makefile ] && make clean
AR=ar
[ "$TARGET" != "$HOST" ] && AR="$TARGET-ar"
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" AR="$AR" ./configure --host="$MUSL_TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-nls && STRIPPROG="$STRIP" make all install-strip DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	for p in ar as ld.bfd nm objcopy objdump ranlib strip; do
		file="$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/$MUSL_TARGET/bin/$p"
		if [ -e "$file" ]; then
			rm -f "$file"
			ln -sf "../../bin/$p" "$file"
		fi
	done
	if [ -e "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/ld" ]; then
		rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/ld"
		ln -sf ld.bfd "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/ld"
	fi
	if [ -e "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/$MUSL_TARGET/bin/ld" ]; then
		rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/$MUSL_TARGET/bin/ld"
		ln -sf ld.bfd "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/$MUSL_TARGET/bin/ld"
	fi
fi
[ $STATUS = 0 ]
