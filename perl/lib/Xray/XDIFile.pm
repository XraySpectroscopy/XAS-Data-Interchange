package Xray::XDIFile;

use 5.014002;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Xray::XDIFile ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
# our %EXPORT_TAGS = ( 'all' => [ qw(
# 	new
# ) ] );

# our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

# our @EXPORT = qw(
# 	new
# );

our $VERSION = '0.01';

use Inline C => 'DATA',
           LIBS => '-lxdifile',
           VERSION => '0.01',
           NAME => 'Xray::XDIFile';

# Preloaded methods go here.




1;
__DATA__

=pod
 
=cut

__C__

#include "strutil.h"
#include "xdifile.h"

SV* new(char* class, char* file) {
    XDIFile* xdifile;
    long ret;

    SV*      obj_ref = newSViv(0);
    SV*      obj = newSVrv(obj_ref, class);

    New(42, xdifile, 1, XDIFile);
    xdifile = malloc(sizeof(XDIFile));
    ret = XDI_readfile(file, xdifile);

    sv_setiv(obj, (IV)xdifile);
    SvREADONLY_on(obj);
    return obj_ref;
}

char* _filename(SV* obj) {
       return ((XDIFile*)SvIV(SvRV(obj)))->filename;
}

char* _xdi_version(SV* obj) {
       return ((XDIFile*)SvIV(SvRV(obj)))->xdi_version;
}

char* _extra_version(SV* obj) {
       return ((XDIFile*)SvIV(SvRV(obj)))->extra_version;
}

char* _element(SV* obj) {
       return ((XDIFile*)SvIV(SvRV(obj)))->element;
}

char* _edge(SV* obj) {
       return ((XDIFile*)SvIV(SvRV(obj)))->edge;
}

char* _comments(SV* obj) {
       return ((XDIFile*)SvIV(SvRV(obj)))->comments;
}

long _nmetadata(SV* obj) {
       return ((XDIFile*)SvIV(SvRV(obj)))->nmetadata;
}

void _meta_families(SV* obj) {
  long i;
  Inline_Stack_Vars;
  Inline_Stack_Reset;
  for (i=0; i < ((XDIFile*)SvIV(SvRV(obj)))->nmetadata; i++) {
    Inline_Stack_Push(sv_2mortal(newSVpv( ((XDIFile*)SvIV(SvRV(obj)))->meta_families[i], 0 )));
  }
  Inline_Stack_Done;
}

void _meta_keywords(SV* obj) {
  long i;
  Inline_Stack_Vars;
  Inline_Stack_Reset;
  for (i=0; i < ((XDIFile*)SvIV(SvRV(obj)))->nmetadata; i++) {
    Inline_Stack_Push(sv_2mortal(newSVpv( ((XDIFile*)SvIV(SvRV(obj)))->meta_keywords[i], 0 )));
  }
  Inline_Stack_Done;
}

void _meta_values(SV* obj) {
  long i;
  Inline_Stack_Vars;
  Inline_Stack_Reset;
  for (i=0; i < ((XDIFile*)SvIV(SvRV(obj)))->nmetadata; i++) {
    Inline_Stack_Push(sv_2mortal(newSVpv( ((XDIFile*)SvIV(SvRV(obj)))->meta_values[i], 0 )));
  }
  Inline_Stack_Done;
}

long _npts(SV* obj) {
       return ((XDIFile*)SvIV(SvRV(obj)))->npts;
}

long _narrays(SV* obj) {
       return ((XDIFile*)SvIV(SvRV(obj)))->narrays;
}


void _array_labels(SV* obj) {
  long i;
  Inline_Stack_Vars;
  Inline_Stack_Reset;
  for (i=0; i < ((XDIFile*)SvIV(SvRV(obj)))->narrays; i++) {
    Inline_Stack_Push(sv_2mortal(newSVpv( ((XDIFile*)SvIV(SvRV(obj)))->array_labels[i], 0 )));
  }
  Inline_Stack_Done;
}


void _data_array(SV* obj, long col) {
  long k;
  long ret;
  double *tdat;

  tdat = (double *)calloc(((XDIFile*)SvIV(SvRV(obj)))->npts, sizeof(double));
  ret = XDI_get_array_name(((XDIFile*)SvIV(SvRV(obj))),
		           ((XDIFile*)SvIV(SvRV(obj)))->array_labels[col], tdat);

  Inline_Stack_Vars;
  Inline_Stack_Reset;
  for (k=0; k< ((XDIFile*)SvIV(SvRV(obj)))->npts; k++) {
    Inline_Stack_Push(sv_2mortal(newSVnv( tdat[k] )));
  }
  Inline_Stack_Done;
}
