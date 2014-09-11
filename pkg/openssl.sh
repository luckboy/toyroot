[ -f Makefile ] && make clean
OPENSSL_PLATFORM=linux-elf
case "$ARCH" in
	arm)	OPENSSL_PLATFORM=linux-armv4;;
	x86_64)	OPENSSL_PLATFORM=linux-x86_64;;
esac
CC="$MUSL_GCC" ./Configure --prefix=/usr --openssldir=/etc/ssl shared "$OPENSSL_PLATFORM" && make install INSTALL_PREFIX="$ROOT_DIR/bin/$ARCH/$PKG_NAME" MANDIR=/usr/share/man
STATUS=$?
if [ $STATUS = 0 ]; then
	"$STRIP" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/openssl"
	chmod 755 "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib"/libssl.so.*
	chmod 755 "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib"/libcrypto.so.*
	"$STRIP" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib"/libssl.so.*
	"$STRIP" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib"/libcrypto.so.*
	chmod 555 "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib"/libssl.so.*
	chmod 555 "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib"/libcrypto.so.*
fi
[ $STATUS = 0 ]
