[ -f Makefile ] && make clean
AR=ar 
AS=as
DLLTOOL=dlltool
LD=ld
LIPO=lipo
NM=nm
RANLIB=ranlib
WINDRES=windres
WINDMC=windmc
OBJCOPY=objcopy
OBJDUMP=objdump
READELF=readelf
if [ "$TARGET" != "$HOST" ]; then
	AR="$TARGET-ar"
	AS="$TARGET-as"
	DLLTOOL="$TARGET-dlltool"
	LD="$TARGET-ld"
	LIPO="$TARGET-lipo"
	NM="$TARGET-nm"
	RANLIB="$TARGET-ranlib"
	WINDRES="$TARGET-windres"
	WINDMC="$TARGET-windmc"
	OBJCOPY="$TARGET-objcopy"
	OBJDUMP="$TARGET-objdump"
	READELF="$TARGET-readelf"	
fi

PKG_GCC_VERSION="`echo "$PKG_NAME" | cut -d - -f 2`"
case "$GCC_SHORT_VERSION" in
	4.6|4.7)
		GCC_CONFIGURE_OPTS_LIBS=
		;;
	*)	
		GCC_CONFIGURE_OPTS_LIBS="--disable-libatomic --disable-libsanitizer"
		;;
esac
PKG_CFLAGS_WITHOUT_BINUTILS="`echo "$PKG_CFLAGS" | sed -e "s@-I$ROOT_DIR/bin/$ARCH/binutils_dev/usr/include@@g"`"
PKG_LDFLAGS_WITHOUT_BINUTILS="`echo "$PKG_LDFLAGS" | sed -e "s@-L$ROOT_DIR/bin/$ARCH/binutils/usr/lib@@g" -e "s@-L$ROOT_DIR/bin/$ARCH/binutils_dev/usr/lib@@g"`"

CC="$MUSL_GCC" \
CFLAGS="$PKG_CFLAGS_WITHOUT_BINUTILS" \
LDFLAGS="$PKG_LDFLAGS_WITHOUT_BINUTILS" \
LIBS="$PKG_LIBS" \
CPPFLAGS="" \
CXX="$GXX_UC" \
CXXFLAGS="$PKG_CFLAGS_WITHOUT_BINUTILS" \
AR="$AR" \
AS="$AS" \
DLLTOOL="$DLLTOOL" \
LD="$LD" \
LIPO="$LIPO" \
NM="$NM" \
WINDRES="$WINDRES" \
WINDMC="$WINDMC" \
RANLIB="$RANLIB" \
STRIP="$STRIP" \
OBJCOPY="$OBJCOPTY" \
OBJDUMP="$OBJDUMP" \
READELF="$READELF" \
CC_FOR_TARGET="$MUSL_GCC" \
CXX_FOR_TARGET="$GXX -specs $ROOT_DIR/bin/$ARCH/musl/lib/musl-gcc.specs" \
GCC_FOR_TARGET="$MUSL_GCC" \
AR_FOR_TARGET="$AR" \
AS_FOR_TARGET="$AS" \
DLLTOOL_FOR_TARGET="$DLLTOOL" \
LD_FOR_TARGET="$LD" \
LIPO_FOR_TARGET="$LIPO" \
NM_FOR_TARGET="$NM" \
RANLIB_FOR_TARGET="$RANLIB" \
READELF_FOR_TARGET="$READELF" \
STRIP_FOR_TARGET="$STRIP" \
WINDRES_FOR_TARGET="$WINDRES" \
WINDMC_FOR_TARGET="$WINDMC" \
./configure \
	--host="$MUSL_TARGET" \
	--prefix=/usr \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-shared \
	--disable-nls \
	--enable-languages=c,c++ \
	--enable-threads=posix \
	--disable-multilib \
	--disable-bootstrap \
	--disable-libmudflap \
	--enable-version-specific-runtime-libs \
	--disable-install-libiberty \
	--with-system-zlib \
	$GCC_CONFIGURE_OPTS_LIBS \
&& STRIPPROG="$STRIP" make all install-strip DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
if [ $STATUS = 0 ]; then
	for p in g++ gcc gcc-ar gcc-nm gcc-ranlib; do
		file="$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/$p"
		file2="$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/$MUSL_TARGET-$p"
		[ -e "$file" ] && mv "$file" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/$p-$PKG_GCC_VERSION"
		if [ -e "$file2" ]; then
			rm -f "$file2"
			ln -sf "$p-$PKG_GCC_VERSION" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/$MUSL_TARGET-$p-$PKG_GCC_VERSION"
		fi
	done
	rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/c++"
	rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/$MUSL_TARGET-c++"
	rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/$MUSL_TARGET-gcc-$PKG_VERSION"
	mv "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/cpp" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/cpp-$PKG_GCC_VERSION"
	mv "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/gcov" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/bin/gcov-$PKG_GCC_VERSION"
	if [ -d "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/gcc/$MUSL_TARGET/$PKG_VERSION" ]; then
		ln -sf "$PKG_VERSION" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib/gcc/$MUSL_TARGET/$PKG_GCC_VERSION"
	fi
	if [ -d "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/libexec/gcc/$MUSL_TARGET/$PKG_VERSION" ]; then
		ln -sf "$PKG_VERSION" "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/libexec/gcc/$MUSL_TARGET/$PKG_GCC_VERSION"
	fi
	for file in `ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man1"/*.1`; do
		d="`dirname $file`"
		m="`basename $file .1`"
		[ -e "$file" ] && mv "$d/$m.1" "$d/$m-$PKG_GCC_VERSION.1"
	done
	for file in `ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/man/man7"/*.7`; do
		d="`dirname $file`"
		m="`basename $file .7`"
		mv "$file" "$d/gcc-$PKG_GCC_VERSION-$m.7"
	done
	for file in `ls "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/info"/*.info`; do
		d="`dirname $file`"
		i="`basename $file .info`"
		mv "$file" "$d/$i-$PKG_GCC_VERSION.info"
	done
	rm -f "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/lib"/libiberty.a
fi

unset AR
unset AS
unset DLLTOOL
unset LD
unset LIPO
unset NM
unset RANLIB
unset WINDRES
unset WINDMC
unset OBJCOPY
unset OBJDUMP
unset READELF

[ $STATUS = 0 ]
