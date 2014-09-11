cd ..
[ -f makefile ]&& make clean
make ytab.o CC="$MUSL_GCC" CFLAGS="-s" YACC="bison -d -y"
make maketab CC=gcc YACC="bison -d -y"
make CC="$MUSL_GCC" CFLAGS="$GCC_CFLAGS -s" YACC="bison -d -y"
STATUS=$?
if [ $STATUS = 0 ]; then
	mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin"
	cp a.out "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/nawk"
	mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man1"
	cp awk.1 "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man1/nawk.1"
fi
cd "$PKG_BUILD_DIR"
[ $STATUS = 0 ]
