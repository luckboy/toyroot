mkdir -p "$PKG_ROOT_DIR/etc/rc.d"
chmod 755 "$PKG_ROOT_DIR/etc/init.d/firewall"
ln -s ../init.d/firewall "$PKG_ROOT_DIR/etc/rc.d/S10firewall"
ln -s ../init.d/firewall "$PKG_ROOT_DIR/etc/rc.d/K10firewall"
