[ -f Makefile.micro ] && make -f Makefile.micro clean
case "$ARCH" in
	x86_64)	make -f Makefile.micro CC=gcc regen_uconfig64;;
	*)	make -f Makefile.micro CC=gcc regen_uconfig;;
esac
#make -f Makefile.micro CC=gcc ugenerate_uudmap &&
make -f Makefile.micro CC=gcc generate_uudmap &&
make -f Makefile.micro CC="$MUSL_GCC" OPTIMIZE="$GCC_CFLAGS" LDFLAGS=-s all
STATUS=$?
mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin"
cp -dp microperl "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin"
ln -sf microperl "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/perl"
[ $STATUS = $? ]
