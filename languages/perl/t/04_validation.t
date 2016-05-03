#!/usr/bin/perl  -I../blib/lib -I../blib/arch

## test get_item/set_item and the validation functions of XDIFile interface

use Test::More tests => 29;

use strict;
use warnings;
use File::Basename;
use File::Spec;

my $epsi = 0.001;

BEGIN { use_ok('Xray::XDI') };

my $errcode = 0;
my $here    = dirname($0);
my $file    = File::Spec->catfile($here, '..', '..', '..', 'data', 'co_metal_rt.xdi');
my $xdifile = Xray::XDI->new(file=>$file);

my @list; # = (family  item  bad_value  description  error_code); # error code from xdifile.h


@list = ('Facility', 'name', 'yowsa!', 'Facility.name can be anything', 0);
the_tests($xdifile, @list);

@list = ('Element', 'symbol', 'Qq', 'absorber element', 100);
the_tests($xdifile, @list);

@list = ('Element', 'edge', 'B', 'absorber edge', 101);
the_tests($xdifile, @list);

@list = ('Element', 'reference', 'Qq', 'reference element', 102);
the_tests($xdifile, @list);

@list = ('Element', 'ref_edge', 'B', 'reference edge', 103);
the_tests($xdifile, @list);

@list = ('Frobnozz', 'fliboosh', 'skiddo', 'unversioned item', 104);
the_tests($xdifile, @list);

@list = ('Column', '1', 'foot-pounds', 'column 1 units', 105);
the_tests($xdifile, @list);

@list = ('Scan', 'start_time', '2016-May-03T16:19:00', 'date format', 106);
the_tests($xdifile, @list);

@list = ('Scan', 'start_time', '2016-05-03T16:67:00', 'date range', 107);
the_tests($xdifile, @list);

@list = ('Mono', 'd_spacing', '3.155x', 'd-spacing', 108);
the_tests($xdifile, @list);

@list = ('Sample', 'temperature', '273x K', 'sample temperature', 109);
the_tests($xdifile, @list);

@list = ('Facility', 'energy', '6.0x GeV', 'ring energy', 110);
the_tests($xdifile, @list);

sub the_tests {
  my ($xdifile, @list) = @_;
  $xdifile->set_item(@list[0..2]);
  is($xdifile->get_item(@list[0,1]), $list[2], 'set_item '.$list[3]);
  $xdifile->validate(@list[0..2]);
  is($xdifile->errorcode, $list[4], sprintf('bad %s (code=%d)', @list[3,4]));
};

undef $xdifile;
$xdifile = Xray::XDI->new(file=>$file);

$xdifile->required;
is($xdifile->errorcode, 0, 'required');

$xdifile->recommended;
is($xdifile->errorcode, 0, 'recommended');

undef $xdifile;
$file    = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_02.xdi');
$xdifile = Xray::XDI->new(file=>$file);
$xdifile->required;
is($xdifile->errorcode, 2, 'missing required Element.edge');

undef $xdifile;
$file    = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_32.xdi');
$xdifile = Xray::XDI->new(file=>$file);
$xdifile->recommended;
is($xdifile->errorcode, 5, 'missing recommended fields');

