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
	NETSURF_ALL_GTKX_CFLAGS="`"$PKG_CONFIG" --cflags gtk+-3.0`"
	NETSURF_ALL_GTKX_LIBS="`"$PKG_CONFIG" --libs gtk+-3.0`"
	for name in buildsystem libwapcaplet libparserutils libcss libhubbub libdom libnsbmp libnsgif librosprite libsvgtiny nsgenbind netsurf; do
		PATH="$PATH:$ROOT_DIR/build/$ARCH/$PKG_NAME/nsgenbind-host/bin" \
		make -C $name clean \
			NSSHARED="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/buildsystem" \
			NSTESTTOOLS="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/buildsystem/testtools"
		PATH="$PATH:$ROOT_DIR/build/$ARCH/$PKG_NAME/nsgenbind-host/bin" \
		NETSURF_ALL_CFLAGS_NETSURF=""
		NETSURF_ALL_LIBS_NETSURF=""
		NETSURF_ALL_MAKECFLAGS_NETSURF=""
		if [ $name = netsurf ]; then
			NETSURF_ALL_CFLAGS_NETSURF="-I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/build-Linux-gtk"
			NETSURF_ALL_CFLAGS_NETSURF="$NETSURF_ALL_CFLAGS_NETSURF -D_BSD_SOURCE -D_POSIX_C_SOURCE -std=c99"
			NETSURF_ALL_CFLAGS_NETSURF="$NETSURF_ALL_CFLAGS_NETSURF -Dnsgtk=1 -DNETSURF_HOMEPAGE=\\\"about:welcome\\\" -DGTK_RESPATH=\\\"/usr/share/netsurf\\\""
			NETSURF_ALL_CFLAGS_NETSURF="$NETSURF_ALL_CFLAGS_NETSURF -DWITH_NS_SVG -DWITH_HUBBUB -DWITH_BMP -DWITH_GIF -DWITH_PNG -DWITH_JPEG -DWITH_NSSPRITE -DWITH_ICONV_FILTER"
			NETSURF_ALL_LIBS_NETSURF="-lsvgtiny -lrosprite -lnsgif -lnsbmp -ldom -lhubbub -lcss -lparserutils  -lwapcaplet"
			NETSURF_ALL_MAKECFLAGS_NETSURF="
NETSURF_USE_JPEG=YES
NETSURF_USE_LIBICONV_PLUG=YES
NETSURF_USE_PNG=YES
NETSURF_USE_BMP=YES
NETSURF_USE_GIF=YES
NETSURF_USE_RSVG=NO
NETSURF_USE_NSSVG=YES
NETSURF_USE_ROSPRITE=YES
NETSURF_USE_WEBP=NO
NETSURF_USE_MOZJS=NO
NETSURF_USE_JS=NO
NETSURF_USE_VIDEO=NO
NETSURF_GTK_MAJOR=3"
		fi
		make -C $name all install \
			NSSHARED="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/buildsystem" \
			NSTESTTOOLS="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/buildsystem/testtools" \
			TARGET="gtk" \
			PREFIX="$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr" \
			CC="$MUSL_GCC" \
			CXX="$GXX_UC" \
			CFLAGS="$PKG_CFLAGS $NETSURF_ALL_GTKX_CFLAGS -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/include -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/src -I$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/include $NETSURF_ALL_CFLAGS_NETSURF" \
			CXXFLAGS="$PKG_CFLAGS $NETSURF_ALL_GTKX_CFLAGS -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/include -I$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name/src -I$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/include $NETSURF_ALL_CFLAGS_NETSURF" \
			LDFLAGS="$PKG_LDFLAGS $NETSURF_ALL_GTKX_LIBS -L$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib $NETSURF_ALL_LIBS_NETSURF -lcurl -lidn -lrtmp -lssl -lcrypto -lz" \
			CURDIR="$ROOT_DIR/build/$ARCH/$PKG_NAME/$PKG_NAME-$PKG_VERSION/$name" \
			$NETSURF_ALL_MAKECFLAGS_NETSURF \
			PKG_CONFIG=true
		STATUS=$?
		[ $STATUS = 0 ] || break
	done
fi
if [ $STATUS = 0 ]; then
	for file in "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/pkgconfig"/*.pc; do
		cp "$file" "$file.orig"
		sed "s@$ROOT_DIR/bin/$ARCH/$PKG_NAME@@g" "$file.orig" > "$file"
		rm -f "$file.orig"
	done
	for size in 24x24; do
		mkdir -p "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/icons/hicolor/$size/apps"
		convert -resize $size -gravity center -crop $size "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/netsurf/netsurf.xpm" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/icons/hicolor/$size/apps/netsurf.png"
	done
fi
[ $STATUS = 0 ]
