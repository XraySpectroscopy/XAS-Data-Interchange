# Copyright (C) 2000 Matt Newville <newville@cars.uchicago.edu>
#
# This file is free software; the author gives unlimited permission 
# to copy and/or distribute it, with or without modifications, as 
# long as this notice is preserved.
#
AC_INIT([xdilib], [1.1.0], [newville@cars.uchicago.edu])
AC_PREREQ([2.60])
AC_CONFIG_SRCDIR([xdifile.h])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])
AC_CANONICAL_HOST

LIB_CURRENT=8
LIB_REVISION=0
LIB_AGE=1
AC_SUBST(LIB_CURRENT)
AC_SUBST(LIB_REVISION)
AC_SUBST(LIB_AGE)
LIB_CURRENT_MINUS_AGE=`expr $LIB_CURRENT - $LIB_AGE`
AC_SUBST(LIB_CURRENT_MINUS_AGE)
AC_CONFIG_MACRO_DIR([m4])

AC_USE_SYSTEM_EXTENSIONS

m4_ifdef([AM_PROG_AR],[AM_PROG_AR])
LT_PREREQ([2.0.0])
LT_INIT([disable-fast-install win32-dll])
AC_PROG_LIBTOOL

AC_PROG_CC

AC_CHECK_HEADERS([math.h stdio.h stdlib.h string.h ctype.h errno.h])

EXTRA_LDFLAGS=

case "$host" in
	*mingw*)
		EXTRA_LDFLAGS="-no-undefined -Wl,--add-stdcall-alias"
		;;
esac

AC_SUBST(EXTRA_LDFLAGS)



AC_CONFIG_HEADERS(config.h)
AC_CONFIG_FILES([Makefile libxdifile.pc])
AC_OUTPUT
