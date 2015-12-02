ACLOCAL_AMFLAGS = -I m4

pkgconfigdir=$(libdir)/pkgconfig
pkgconfig_DATA=libxdifile.pc

xdifileincludedir=${includedir}/xdifile
xdifileinclude_HEADERS = xdifile.h

AM_CPPFLAGS = -I${top_srcdir} -I${top_builddir}

bin_PROGRAMS = xdi_reader
xdi_reader_SOURCES = xdi_reader.c
xdi_reader_LDADD = libxdifile.la

lib_LTLIBRARIES = libxdifile.la
libxdifile_la_SOURCES = \
	strutil.h \
	strutil.c \
	xdifile.h \
	xdifile.c \
	slre.h \
	slre.c
libxdifile_la_LDFLAGS = $(EXTRA_LDFLAGS)
