[ -f Makefile-libbz2_so ] && make -f Makefile-libbz2_so clean
[ -f Makefile ] && make clean
make -f Makefile-libbz2_so CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS -D_FILE_OFFSET_BITS=64 -fPIC" PREFIX="$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr" all &&
make CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS -D_FILE_OFFSET_BITS=64" PREFIX="$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr" bzip2recover
STATUS=$?
if [ $STATUS = 0 ]; then
	mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin"
	cp -dp bzip2-shared "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/bzip2"
	for name in bzip2recover bzdiff bzgrep bzmore; do
		cp $name "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin"
		chmod 755 "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/$name"
	done
	ln -sf bzdiff "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/bzcmp"
	ln -sf bzgrep "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/bzegrep"
	ln -sf bzgrep "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/bzfgrep"
	ln -sf bzmore "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/bzless"
	mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib"
        cp -dp "libbz2.so.$PKG_VERSION" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib"
        PKG_SHORT_VERSION="`echo "$PKG_VERSION" | cut -d . -f 1,2`"
        ln -sf "libbz2.so.$PKG_VERSION" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/libbz2.so.$PKG_SHORT_VERSION"
        ln -sf "libbz2.so.$PKG_VERSION" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/libbz2.so"
	mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/include"
	cp -dp bzlib.h "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/include"
	mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man1"
	for name in bzdiff bzgrep bzmore; do
		cp -dp $name.1 "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man1"
	done
	ln -sf bzdiff.1 "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man1/bzcmp.1"
	ln -sf bzgrep.1 "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man1/bzegrep.1"
	ln -sf bzgrep.1 "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man1/bzfgrep.1"
	ln -sf bzmore.1 "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man1/bzless.1"
fi
[ $STATUS = 0 ]
