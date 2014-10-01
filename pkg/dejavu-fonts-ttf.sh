mkdir -p "$ROOT_DIR/bin/$ARCH/dejavu-fonts-ttf/etc/fonts/conf.d"
mkdir -p "$ROOT_DIR/bin/$ARCH/dejavu-fonts-ttf/usr/share/fontconfig/conf.avail"
mkdir -p "$ROOT_DIR/bin/$ARCH/dejavu-fonts-ttf/usr/share/fonts"
for name in `ls fontconfig`; do
	cp "fontconfig/$name" "$ROOT_DIR/bin/$ARCH/dejavu-fonts-ttf/usr/share/fontconfig/conf.avail"
	ln -sf "/usr/share/fontconfig/conf.avail/$name" "$ROOT_DIR/bin/$ARCH/dejavu-fonts-ttf/etc/fonts/conf.d"
done
cp ttf/* "$ROOT_DIR/bin/$ARCH/dejavu-fonts-ttf/usr/share/fonts"
