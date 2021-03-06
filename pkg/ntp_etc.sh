mkdir -p "$PKG_ROOT_DIR/etc/rc.d"
chmod 755 "$PKG_ROOT_DIR/etc/init.d/ntpd"
chmod 755 "$PKG_ROOT_DIR/etc/init.d/ntpdate"
[ -e "$PKG_ROOT_DIR/etc/init.d/ntp" ] || ln -s ntpdate "$PKG_ROOT_DIR/etc/init.d/ntp"
ln -s ../init.d/ntp "$PKG_ROOT_DIR/etc/rc.d/S25ntp"
ln -s ../init.d/ntp "$PKG_ROOT_DIR/etc/rc.d/K25ntp"
