PKG_WAYLAND_CFLAGS=""
PKG_WAYLAND_LDFLAGS=""
PKG_WAYLAND_LIBS="-lffi"
PKG_DEP_WAYLAND_CFLAGS="-I$ROOT_DIR/bin/$ARCH/wayland_dev/usr/include"
PKG_DEP_WAYLAND_SERVER_LIBS="-lwayland-server"
PKG_DEP_WAYLAND_CLIENT_LIBS="-lwayland-client"
PKG_DEP_WAYLAND_CURSOR_LIBS="-lwayland-client -lwayland-cursor"