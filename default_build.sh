if [ -x ./configure ]; then
	CC="$MUSL_GCC" ./configure --target="$TARGET" --host="$TARGET" --prefix=/usr --sysconfdir=/etc && make DESTDIR="$ROOT_DIR/bin/$PKG_NAME"	
fi

