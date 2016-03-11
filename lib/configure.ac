# Copyright (C) 2000 Matt Newville <newville@cars.uchicago.edu>
#
# This file is free software; the author gives unlimited permission 
# to copy and/or distribute it, with or without modifications, as 
# long as this notice is preserved.
#

# initialize autoconf, set package name, version and email address for correspondence
AC_INIT([xdilib], [1.1.0], [newville@cars.uchicago.edu])
# minimal required version of autoconf
AC_PREREQ([2.60])
# ensure that the directory that is told to contain the source in fact does
AC_CONFIG_SRCDIR([xdifile.h])
# location for auxiliary build tools
AC_CONFIG_AUX_DIR([build-aux])
# initialize automake and set options
AM_INIT_AUTOMAKE([-Wall -Werror foreign])
# compute the canonical host-system type variable, host, which may be used for platform-specific behavior
AC_CANONICAL_HOST

# set the libtool version
# please respect the following rules (https://www.gnu.org/software/libtool/manual/html_node/Updating-version-info.html):

#    Update the version information only immediately before a public release of your software. More frequent updates are unnecessary, and only guarantee that the current interface number gets larger faster.
#    If the library source code has changed at all since the last update, then increment LIB_REVISION(‘c:r:a’ becomes ‘c:r+1:a’).
#    If any interfaces have been added, removed, or changed since the last update, increment LIB_CURRENT, and set LIB_REVISION to 0.
#    If any interfaces have been added since the last public release, then increment LIB_AGE.
#    If any interfaces have been removed or changed since the last public release, then set LIB_AGE to 0. 
LIB_CURRENT=0
LIB_REVISION=0
LIB_AGE=0
# AC_SUBST makes sure that the autoconf variables are passed unto the automake files (Makefile.am)
AC_SUBST(LIB_CURRENT)
AC_SUBST(LIB_REVISION)
AC_SUBST(LIB_AGE)
LIB_CURRENT_MINUS_AGE=`expr $LIB_CURRENT - $LIB_AGE`
AC_SUBST(LIB_CURRENT_MINUS_AGE)
# set the directory where auxiliary m4 scripts are expected to be found
AC_CONFIG_MACRO_DIR([m4])

# enables system dependent extensions
AC_USE_SYSTEM_EXTENSIONS

# look for the archiver, if the macro is available at least
m4_ifdef([AM_PROG_AR],[AM_PROG_AR])

# initialize libtool, set the minimum required version and options
LT_PREREQ([2.0.0])
LT_INIT([disable-fast-install win32-dll])
AC_PROG_LIBTOOL

# look for a suitable C compiler, can be overridden with configure parameter and environment variable CC
AC_PROG_CC

# ensure these headers are available
AC_CHECK_HEADERS([math.h stdio.h stdlib.h string.h ctype.h errno.h])

# when building on Windows, add these options to the linker
EXTRA_LDFLAGS=

case "$host" in
	*mingw*)
		EXTRA_LDFLAGS="-no-undefined -Wl,--add-stdcall-alias"
		;;
esac

AC_SUBST(EXTRA_LDFLAGS)

# sets the name of the configuration header file
AC_CONFIG_HEADERS(config.h)
# list of all files that contain variables that will be substituted by configure
AC_CONFIG_FILES([Makefile libxdifile.pc])
#last command in configure.ac, makes sure all files in the buildtree that need updating are updated
AC_OUTPUT
