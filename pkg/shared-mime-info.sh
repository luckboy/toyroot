[ -f Makefile ] && make clean
./configure && make
STATUS=$?
if [ $STATUS = 0 ]; then
	mkdir -p "$ROOT_DIR/bin/$ARCH/shared-mime-info/usr/share/mime/packages"
	cp -dp freedesktop.org.xml "$ROOT_DIR/bin/$ARCH/shared-mime-info/usr/share/mime/packages"
	./update-mime-database "$ROOT_DIR/bin/$ARCH/shared-mime-info/usr/share/mime"
fi
[ $STATUS = 0 ]
