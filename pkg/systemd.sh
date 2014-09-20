[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-nls --disable-xz --disable-dbus --disable-gtk-doc && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
