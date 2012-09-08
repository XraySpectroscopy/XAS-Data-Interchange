package Xray::XDIFile;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
# our @EXPORT_OK = (  );
# our @EXPORT = qw(  );

our $VERSION = '0.01';

use Inline C => 'DATA',
           LIBS => '-lxdifile',
           VERSION => '0.01',
           NAME => 'Xray::XDIFile';

1;
__DATA__

=pod


=head1 NAME

Xray::XDIFile - Inline::C interface to libxdifile

=head1 VERSION

0.01

=head1 SYNOPSIS

This is a slight rewrite of the xdi_reader example that comes with the
linxdifile source code.  It uses L<Inline> to map perl scalars onto
the data structures in libxdifile.

Import an XDI file:

  use Xray::XDIFile;
  my $errcode;
  my $xdifile = Xray::XDIFile->new('data.dat', $errcode);

See xdifile.h for meaning of error codes.

Export an XDI file:

  $xdifile -> export("outfile.dat");

This closely follows the example at
L<https://metacpan.org/module/Inline::C-Cookbook#Object-Oriented-Inline>,
mapping all the functions demonstrated in F<xdi_reader.c>.

See L<Xray::XDI> for a Moose-ified wrapper around this.

All methods share a name with L<Xray::XDI>, except that methods of
this object are all preceded with an underscore.

=head1 DEPENDENCIES

=over 4

=item *

L<Inline>

=back

=head1 BUGS AND LIMITATIONS

=over 4

=item *

Error handling is primitive

=item *

Initialize array members of the struct

=back

Please report problems to Bruce Ravel (bravel AT bnl DOT gov)

Patches are welcome.

=head1 AUTHOR

Bruce Ravel (bravel AT bnl DOT gov)

L<http://cars9.uchicago.edu/~ravel/software/>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012 Bruce Ravel (bravel AT bnl DOT gov). All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlgpl>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

__C__

#include "xdifile.h"

SV* new(char* class, char* file, SV* errcode) {
    XDIFile* xdifile;
    long ret;

    SV*      obj_ref = newSViv(0);
    SV*      obj = newSVrv(obj_ref, class);

    New(42, xdifile, 1, XDIFile);
    xdifile = malloc(sizeof(XDIFile));

    ret = XDI_readfile(file, xdifile);
    sv_setiv(errcode, ret);

    sv_setiv(obj, (IV)xdifile);
    SvREADONLY_on(obj);
    return obj_ref;
}

char* _errorstring(SV* obj, int code) {
      return XDI_errorstring(code);
}

void _valid_edges(SV* obj) {
  long i;
  Inline_Stack_Vars;
  Inline_Stack_Reset;
  for (i=0; i < sizeof(ValidEdges)/sizeof(ValidEdges[0]); i++) {
    Inline_Stack_Push(sv_2mortal(newSVpv( ValidEdges[i], 0 )));
  }
  Inline_Stack_Done;
}
void _valid_elements(SV* obj) {
  long i;
  Inline_Stack_Vars;
  Inline_Stack_Reset;
  for (i=0; i < sizeof(ValidElems)/sizeof(ValidElems[0]); i++) {
    Inline_Stack_Push(sv_2mortal(newSVpv( ValidElems[i], 0 )));
  }
  Inline_Stack_Done;
}

char* _token(SV* obj, char* tok) {
  if (strncmp(tok, "comment", 3) == 0) {
    return TOK_COMM;
  } else if (strncmp(tok, "delimiter", 2) == 0) {
    return TOK_DELIM;
  } else if (strncmp(tok, "dot", 2) == 0) {
    return TOK_DOT;
  } else if (strncmp(tok, "startcomment", 1) == 0) {
    return TOK_USERCOM_0;
  } else if (strncmp(tok, "endcomment", 3) == 0) {
    return TOK_USERCOM_1;
  } else if (strncmp(tok, "energycolumn", 3) == 0) {
    return TOK_COL_ENERGY;
  } else if (strncmp(tok, "anglecolumn", 1) == 0) {
    return TOK_COL_ANGLE;
  } else if (strncmp(tok, "version", 1) == 0) {
    return TOK_VERSION;
  } else if (strncmp(tok, "edge", 3) == 0) {
    return TOK_EDGE;
  } else if (strncmp(tok, "element", 2) == 0) {
    return TOK_ELEM;
  } else if (strncmp(tok, "column", 3) == 0) {
    return TOK_COLUMN;
  } else if (strncmp(tok, "dspacing", 2) == 0) {
    return TOK_DSPACE;
  } else {
    return "";
  }
};

char* _filename(SV* obj) {
       return ((XDIFile*)SvIV(SvRV(obj)))->filename;
}

char* _xdi_libversion(SV* obj) {
       return ((XDIFile*)SvIV(SvRV(obj)))->xdi_libversion;
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

double _dspacing(SV* obj) {
       return ((XDIFile*)SvIV(SvRV(obj)))->dspacing;
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
long _narray_labels(SV* obj) {
       return ((XDIFile*)SvIV(SvRV(obj)))->narray_labels;
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

void _array_units(SV* obj) {
  long i;
  Inline_Stack_Vars;
  Inline_Stack_Reset;
  for (i=0; i < ((XDIFile*)SvIV(SvRV(obj)))->narrays; i++) {
    Inline_Stack_Push(sv_2mortal(newSVpv( ((XDIFile*)SvIV(SvRV(obj)))->array_units[i], 0 )));
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
