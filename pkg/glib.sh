[ -f Makefile ] && make clean
CC="$MUSL_GCC" CFLAGS="$PKG_CFLAGS" LDFLAGS="$PKG_LDFLAGS" LIBS="$PKG_LIBS" STRIP="$STRIP" \
glib_cv_stack_grows=no glib_cv_uscore=no ac_cv_func_posix_getpwuid_r=yes ac_cv_func_posix_getgrgid_r=no \
./configure --host="$TARGET" --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make install DESTDIR="$ROOT_DIR/bin/$ARCH/$PKG_NAME"
STATUS=$?
[ $STATUS = 0 ] && [ -e "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/bash-completion" ] && rm -fr "$ROOT_DIR/bin/$ARCH/$PKG_NAME/usr/share/bash-completion"
[ $STATUS = 0 ]