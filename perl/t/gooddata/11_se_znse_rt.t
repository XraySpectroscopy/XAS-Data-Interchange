#!/usr/bin/perl  -I../../blib/lib -I../../blib/arch

## test the se_znse_rt good data example

use Test::More tests => 26;

use strict;
use warnings;
use File::Basename;
use File::Spec;

my $epsi = 0.001;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', '..', 'data', 'se_znse_rt.xdi');
my $xdi  = Xray::XDI->new(file=>$file);

ok($xdi->ok,                                                      'file imported properly');

##### test things that return arrays of strings #################

my @labels = $xdi->labels;
ok($#labels == 3,                                                 'labels: number of labels');
ok( (($labels[0] eq 'energy') and
     ($labels[1] eq 'time') and
     ($labels[2] eq 'i0')),                                  'labels: label names');

my @families = $xdi->families;
ok($#families == 7,                                               'families: number of families');
ok( (($families[0] eq 'Beamline') and
     ($families[1] eq 'Column')   and
     ($families[2] eq 'Detector')),                                'famlies: family names');

my @keywords = $xdi->keywords('Beamline');
ok($#keywords == 3,                                               'keywords: number of keywords');
ok( (($keywords[0] eq 'collimation')          and
     ($keywords[2] eq 'harmonic_rejection')   and
     ($keywords[1] eq 'focusing')),                               'keywords: keyword names');


##### test get_item #############################################
ok($xdi->get_item(qw(Mono name)) eq 'Si 111',                     'get_item: fetching Mono.name');
ok($xdi->get_item(qw(Facility xray_source)) eq 'APS bending magnet',      'get_item: fetching Facility.xray_source');

##### test get_array and get_iarray ##############################
my @values = (12543.00, 2.000000, 118952.4, 392466.4);
foreach my $lab (@{$xdi->array_labels}) {
  my @x = $xdi->get_array($lab);
  ok($#x == $xdi->npts -1,                                        "get_array: number of pts, array $lab");
  my $val = shift @values;
  ok((abs($x[7] - $val)       < $epsi),                           "get_array: 7th data point, array $lab");
};
@values = (12543.00, 2.000000, 118952.4, 392466.4) ;
foreach my $i (1 .. $#{$xdi->array_labels}+1) {
  my @x = $xdi->get_iarray($i);
  ok($#x == $xdi->npts -1,                                        "get_iarray: number of pts, array $i");
  my $val = shift @values;
  ok((abs($x[7] - $val)       < $epsi),                           "get_iarray: 7th data point, array $i");
};


undef $xdi;
