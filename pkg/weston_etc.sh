mkdir -p "$PKG_ROOT_DIR/etc/rc.d"
chmod 755 "$PKG_ROOT_DIR/etc/init.d/weston"
ln -s ../init.d/weston "$PKG_ROOT_DIR/etc/rc.d/S30weston"
ln -s ../init.d/weston "$PKG_ROOT_DIR/etc/rc.d/K30weston"
mkdir -p "$PKG_ROOT_DIR/xdg"
if rgrep -q '^[ \t]*[^ \t]\+[ \t]\+/xdg' "$PKG_ROOT_DIR/etc/fstab"; then
	echo -n
else
	cat >> "$PKG_ROOT_DIR/etc/fstab" <<EOT
tmpfs		/xdg		tmpfs		gid=101,mode=770	0	0
EOT
fi
if [ ! -e "$PKG_ROOT_DIR/etc/xdg/weston/weston.ini" ]; then
	cat "$PKG_ROOT_DIR/etc/xdg/weston/weston.ini.head" > "$PKG_ROOT_DIR/etc/xdg/weston/weston.ini"
	[ -x "$PKG_ROOT_DIR/usr/bin/l3afpad" ] && cat >> "$PKG_ROOT_DIR/etc/xdg/weston/weston.ini" <<EOT
[launcher]
icon=/usr/share/icons/hicolor/24x24/apps/l3afpad.png
path=/usr/bin/l3afpad
EOT
fi
