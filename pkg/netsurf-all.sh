for name in nsgenbind; do
	make -C $name clean \
		NSSHARED="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/buildsystem" \
		NSTESTTOOLS="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/buildsystem/testtools"
	make -C $name all install \
		NSSHARED="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/buildsystem" \
		NSTESTTOOLS="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/buildsystem/testtools" \
		PREFIX="$ROOT_DIR/build/$ARCH/$PKG_NAME/$name-host" \
		CFLAGS="$PKG_CFLAGS -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/include -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/src" \
		CXXFLAGS="$PKG_CFLAGS -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/include -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/src" \
		CURDIR="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name"
	STATUS=$?
	[ $STATUS = 0 ] || break
done
if [ $STATUS = 0 ]; then
	for name in buildsystem libwapcaplet libparserutils libcss libhubbub libdom libnsbmp libnsgif librosprite libsvgtiny nsgenbind netsurf; do
		PATH="$PATH:$ROOT_DIR/build/$ARCH/$PKG_NAME/nsgenbind-host/bin" \
		make -C $name clean \
			NSSHARED="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/buildsystem" \
			NSTESTTOOLS="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/buildsystem/testtools"
		PATH="$PATH:$ROOT_DIR/build/$ARCH/$PKG_NAME/nsgenbind-host/bin" \
		NETSURF_ALL_CFLAGS_NETSURF=""
		NETSURF_ALL_LIBS_NETSURF=""
		if [ $name = netsurf ]; then
			NETSURF_ALL_CFLAGS_NETSURF="-I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/build-Linux-gtk"
			NETSURF_ALL_CFLAGS_NETSURF="$NETSURF_ALL_CFLAGS_NETSURF -D_BSD_SOURCE -D_POSIX_C_SOURCE -std=c99"
			NETSURF_ALL_CFLAGS_NETSURF="$NETSURF_ALL_CFLAGS_NETSURF -Dnsgtk=1 -DNETSURF_HOMEPAGE=\\\"about:welcome\\\" -DGTK_RESPATH=\\\"/usr/share/netsurf\\\""
			NETSURF_ALL_CFLAGS_NETSURF="$NETSURF_ALL_CFLAGS_NETSURF -DWITH_BMP -DWITH_GIF -DWITH_PNG -DWITH_NS_SVG -DWITH_JPEG -DWITH_NSSPRITE -DWITH_ICONV_FILTER"
			NETSURF_ALL_LIBS_NETSURF="-lsvgtiny -lrosprite -lnsgif -lnsbmp -ldom -lhubbub -lcss -lparserutils  -lwapcaplet"
		fi
		make -C $name all install \
			NSSHARED="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/buildsystem" \
			NSTESTTOOLS="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/buildsystem/testtools" \
			TARGET="gtk" \
			PREFIX="$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr" \
			CC="$MUSL_GCC" \
			CXX="$GXX_UC" \
			CFLAGS="$PKG_CFLAGS $PKG_GTKX_CFLAGS $PKGCFG_GTKX_CFLAGS -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/include -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/src -I$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/include $NETSURF_ALL_CFLAGS_NETSURF" \
			CXXFLAGS="$PKG_CFLAGS $PKG_GTKX_CFLAGS $PKGCFG_GTKX_CFLAGS -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/include -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/src -I$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/include $NETSURF_ALL_CFLAGS_NETSURF" \
			LDFLAGS="$PKG_LDFLAGS $PKG_GTKX_LDFLAGS $PKG_LIBS $PKG_GTKX_LIBS $PKG_CURL_LIBS $PKGCFG_GTKX_LIBS $PKGCFG_CURL_LIBS -L$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib $NETSURF_ALL_LIBS_NETSURF -lssl -lcrypto" \
			CURDIR="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name" \
			NETSURF_USE_JS=NO \
			NETSURF_USE_MOZJS=NO \
			NETSURF_USE_RSVG=NO \
			NETSURF_GTK_MAJOR=3 \
			PKG_CONFIG=true
		STATUS=$?
		[ $STATUS = 0 ] || break
	done
fi
[ $STATUS = 0 ]
