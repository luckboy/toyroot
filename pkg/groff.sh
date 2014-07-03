[ -f Makefile ] && make clean
PAGE=letter CC="$MUSL_GCC" CXX="$GXX_UC" CFLAGS="$PKG_CFLAGS" CXXFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --without-x && 
cd src/libs/gnulib && CC="$MUSL_GCC" CXX="$GXX_UC" CFLAGS="$PKG_CFLAGS" CXXFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" ./configure --host="$TARGET" && cd ../../.. &&
make all TROFFBIN=troff GROFFBIN=groff GROFF_BIN_PATH= &&
make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
