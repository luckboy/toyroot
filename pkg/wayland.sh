mkdir -p "../$PKG_NAME-host"
cd "../$PKG_NAME-host"
[ -f Makefile ] && make clean
"../$PKG_NAME-$PKG_VERSION/configure" --disable-documentation && make all
WAYLAND_SCANNER="`pwd`/wayland-scanner"
cd "../$PKG_NAME-$PKG_VERSION"
[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-documentation --disable-scanner && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME" wayland_scanner="$WAYLAND_SCANNER"
