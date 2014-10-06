[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" \
wayland_scanner="$ROOT_DIR/build/$ARCH/wayland/wayland-host/wayland-scanner" \
WAYLAND_SCANNER_CFLAGS="-I$ROOT_DIR/bin/$ARCH/wayland_dev/usr/include" \
WAYLAND_SCANNER_LIBS="`"$PKG_CONFIG" --libs wayland-server`" \
./configure \
	--host="$TARGET" \
	--prefix=/usr \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--disable-egl \
	--disable-libunwind \
	--disable-xwayland \
	--disable-x11-compositor \
	--disable-drm-compositor \
	--disable-wayland-compositor \
	--disable-headless-compositor \
	--disable-libinput-backend \
	--enable-demo-clients-install \
&& make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	[ "`ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man7"`" = "" ] && rmdir "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man7"
	rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/weston"/*.la
fi
[ $STATUS = 0 ]
