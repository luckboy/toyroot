[ -f Makefile ] && make clean
CURL_CONFIGURE_OPTS_SSL=--without-ssl
CURL_LIBS_SSL_CRYPTO=""
if [ ! -d "$ROORT_DIR/bin/$ARCH/openssl" ]; then
	CURL_CONFIGURE_OPTS_SSL="--with-ssl=$ROORT_DIR/bin/$ARCH/openssl/usr --with-ca-path=/etc/ssl/certs"
	CURL_LIBS_SSL_CRYPTO="-lssl -lcrypto"
fi
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS $CURL_LIBS_SSL_CRYPTO -lidn -lrtmp -lz" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var $CURL_CONFIGURE_OPTS_SSL && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
