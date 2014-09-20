[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS -I$ROOT_DIR/bin/$ARCH/pixman_dev/usr/include/pixman-1" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS -lxkbcommon -lfreetype -lpng -ljpeg -lpixman-1 -lffi -lz -lbz2" STRIP="$STRIP" \
COMPOSITOR_CFLAGS="-I$ROOT_DIR/bin/$ARCH/wayland_dev/usr/include -I$ROOT_DIR/bin/$ARCH/pixman_dev/usr/include/pixman-1" \
COMPOSITOR_LIBS="-L$ROOT_DIR/bin/$ARCH/wayland/usr/lib -L$ROOT_DIR/bin/$ARCH/wayland_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/pixman/usr/lib -L$ROOT_DIR/bin/$ARCH/pixman_dev/usr/lib -lwayland-server -lpixman-1" \
RPI_COMPOSITOR_CFLAGS="-I$ROOT_DIR/bin/$ARCH/mtdev_dev/usr/include -I$ROOT_DIR/bin/$ARCH/eudev_dev/usr/include" \
RPI_COMPOSITOR_LIBS="-L$ROOT_DIR/bin/$ARCH/mtdev/usr/lib -L$ROOT_DIR/bin/$ARCH/mtdev_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/eudev/usr/lib -L$ROOT_DIR/bin/$ARCH/eudev_dev/usr/lib -lmtdev -ludev" \
FBDEV_COMPOSITOR_CFLAGS="-I$ROOT_DIR/bin/$ARCH/mtdev_dev/usr/include -I$ROOT_DIR/bin/$ARCH/eudev_dev/usr/include" \
FBDEV_COMPOSITOR_LIBS="-L$ROOT_DIR/bin/$ARCH/mtdev/usr/lib -L$ROOT_DIR/bin/$ARCH/mtdev_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/eudev/usr/lib -L$ROOT_DIR/bin/$ARCH/eudev_dev/usr/lib -lmtdev -ludev" \
PIXMAN_CFLAGS="-I$ROOT_DIR/bin/$ARCH/pixman_dev/usr/include/pixman-1" \
PIXMAN_LIBS="-L$ROOT_DIR/bin/$ARCH/pixman/usr/lib -L$ROOT_DIR/bin/$ARCH/pixman_dev/usr/lib -lpixman-1" \
CAIRO_CFLAGS="-I$ROOT_DIR/bin/$ARCH/cairo_dev/usr/include/cairo" \
CAIRO_LIBS="-L$ROOT_DIR/bin/$ARCH/cairo/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo_dev/usr/lib -lcairo -lcairo -lcairo-script-interpreter" \
TEST_CLIENT_CFLAGS="-I$ROOT_DIR/bin/$ARCH/wayland_dev/usr/include" \
TEST_CLIENT_LIBS="-L$ROOT_DIR/bin/$ARCH/wayland_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/wayland/usr/lib -lwayland-client" \
SIMPLE_CLIENT_CFLAGS="-I$ROOT_DIR/bin/$ARCH/wayland_dev/usr/include" \
SIMPLE_CLIENT_LIBS="-L$ROOT_DIR/bin/$ARCH/wayland/usr/lib -L$ROOT_DIR/bin/$ARCH/wayland_dev/usr/lib -lwayland-client" \
CLIENT_CFLAGS="-I$ROOT_DIR/bin/$ARCH/wayland_dev/usr/include -I$ROOT_DIR/bin/$ARCH/cairo_dev/usr/include/cairo -I$ROOT_DIR/bin/$ARCH/libxkbcommon_dev/usr/include/xkbcommon" \
CLIENT_LIBS="-L$ROOT_DIR/bin/$ARCH/wayland/usr/lib -L$ROOT_DIR/bin/$ARCH/wayland_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo_dev/usr/lib -L$ROOT_DIR/bin/$ARCH/libxkbcommon/usr/lib -L$ROOT_DIR/bin/$ARCH/libxkbcommon_dev/usr/lib -lwayland-client -lwayland-cursor -lcairo -lcairo -lcairo-script-interpreter -lxkbcommon" \
SERVER_CFLAGS="-I$ROOT_DIR/bin/$ARCH/wayland_dev/usr/include" \
SERVER_LIBS="-L$ROOT_DIR/bin/$ARCH/wayland/usr/lib -L$ROOT_DIR/bin/$ARCH/wayland_dev/usr/lib -lwayland-server" \
WESTON_INFO_CFLAGS="-I$ROOT_DIR/bin/$ARCH/wayland_dev/usr/include" \
WESTON_INFO_LIBS="-L$ROOT_DIR/bin/$ARCH/wayland/usr/lib -L$ROOT_DIR/bin/$ARCH/wayland_dev/usr/lib -lwayland-client" \
WCAP_CFLAGS="-I$ROOT_DIR/bin/$ARCH/cairo_dev/usr/include/cairo" \
WCAP_LIBS="-L$ROOT_DIR/bin/$ARCH/cairo/usr/lib -L$ROOT_DIR/bin/$ARCH/cairo_dev/usr/lib -lcairo -lcairo -lcairo-script-interpreter" \
wayland_scanner="$ROOT_DIR/build/$ARCH/wayland/wayland-host/wayland-scanner" \
WAYLAND_SCANNER_CFLAGS="-I$ROOT_DIR/bin/$ARCH/wayland_dev/usr/include" \
WAYLAND_SCANNER_LIBS="-L$ROOT_DIR/bin/$ARCH/wayland/usr/lib -L$ROOT_DIR/bin/$ARCH/wayland_dev/usr/lib -lwayland-server" \
PNG_CFLAGS="-I$ROOT_DIR/bin/$ARCH/libpng_dev/usr/include" \
PNG_LIBS="-L$ROOT_DIR/bin/$ARCH/libpng/usr/lib -L$ROOT_DIR/bin/$ARCH/libpng_dev/usr/lib -lpng" \
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
[ $STATUS = 0 ] && [ "`ls "$ROOT_DIR/bin/$ARCH/weston/usr/share/man/man7"`" = "" ] && rmdir "$ROOT_DIR/bin/$ARCH/weston/usr/share/man/man7"
[ $STATUS = 0 ]
