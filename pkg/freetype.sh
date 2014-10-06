[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/pkgconfig"
	sed -e 's@%prefix%@/usr@g' \
		-e 's@%exec_prefix%@/usr@g' \
		-e 's@%libdir%@/usr/lib@g' \
		-e 's@%includedir%@/usr/include@g' \
		-e "s@%ft_version%@17.2.11@g" \
		-e 's@%REQUIRES_PRIVATE%@@g' \
		-e 's@%LIBS_PRIVATE%@-lz@g' "builds/unix/freetype2.in" > "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/pkgconfig/freetype2.pc"
	[ "`ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin"`" = "" ] && rmdir "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin"
	[ "`ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/aclocal"`" = "" ] && rmdir "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/aclocal"
	[ "`ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man1"`" = "" ] && rmdir "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man1"
	[ "`ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man"`" = "" ] && rmdir "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man"
	[ "`ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share"`" = "" ] && rmdir "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share"
fi
[ $STATUS = 0 ]
