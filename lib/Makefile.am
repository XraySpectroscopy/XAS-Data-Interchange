# location of libtool macros
ACLOCAL_AMFLAGS = -I m4

# installation location of pkg-config file
pkgconfigdir=$(libdir)/pkgconfig
# variable containing file that will be copied into pkgconfigdir
pkgconfig_DATA=libxdifile.pc

# installation location of headers
xdifileincludedir=${includedir}/xdifile
# variable containing file that will be copied into xdifileincludedir 
xdifileinclude_HEADERS = xdifile.h

# global preprocessor flags
AM_CPPFLAGS = -I${top_srcdir} -I${top_builddir}

# programs that will be installed in $(bin)
bin_PROGRAMS = xdi_reader
# source files necessary to compile the xdi_reader program
xdi_reader_SOURCES = xdi_reader.c
# xdi_reader will be linked to our shared library libxdifile
xdi_reader_LDADD = libxdifile.la

# list of libraries (built with libtool) that will end up in $(lib)
# the .la extension will be changed depending on what is in use on the target platform (.so, .dll, .dylib)
lib_LTLIBRARIES = libxdifile.la
# the source code our library will be built from
libxdifile_la_SOURCES = \
	strutil.h \
	strutil.c \
	xdifile.h \
	xdifile.c \
	slre.h \
	slre.c
# the flags that will be passed onto the linker when generating the library
# EXTRA_LDFLAGS is defined in configure.ac and will be empty, except on Windows
# the version-info will be important when backwards compatibility needs to be broken due the removed or changed interfaces
libxdifile_la_LDFLAGS = $(EXTRA_LDFLAGS) -version-info @LIB_CURRENT@:@LIB_REVISION@:@LIB_AGE@
