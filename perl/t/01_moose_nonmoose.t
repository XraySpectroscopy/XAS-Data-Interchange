#!/usr/bin/perl  -I../blib/lib -I../blib/arch

## test the construction of the Moose attribute structure in Xray::XDI;

use Test::More tests => 46;

use strict;
use warnings;
use File::Basename;
use File::Spec;

my $epsi = 0.001;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', 'data', 'co_metal_rt.xdi');
my $xdi  = Xray::XDI->new(file=>$file);
ok($xdi =~ m{Xray::XDI},                           'created Xray::XDI object');
ok($xdi->ok,                                       'ok flag is true');
ok($xdi->error eq '',                              'error text is empty');

ok( $xdi->token('comment') eq '#',                 'token: comment');
ok( $xdi->token('delimiter') eq ':',               'token: delimiter');
ok( $xdi->token('dot') eq '.',                     'token: dot');
ok( $xdi->token('startcomment') eq '///',          'token: startcomment');
ok( $xdi->token('endcomment') eq '---',            'token: endcomment');
ok( $xdi->token('energycolumn') eq 'energy',       'token: energycolumn');
ok( $xdi->token('anglecolumn') eq 'angle',         'token: anglecolumn');
ok( $xdi->token('version') eq 'XDI/',              'token: version');
ok( $xdi->token('edge') eq 'element.edge',         'token: edge');
ok( $xdi->token('element') eq 'element.symbol',    'token: element');
ok( $xdi->token('column') eq 'column.',            'token: column');
ok( $xdi->token('dspacing') eq 'mono.d_spacing',   'token: dspacing');
ok( $xdi->token('timestamp') eq 'scan.start_time', 'token: timestamp');
ok( $xdi->token('glorb') eq '',                    'token: "glorb" is not a token');

my @edges = $xdi->valid_edges;
ok($#edges == 26,                                'edge symbols');
my @elements = $xdi->valid_elements;
ok($#elements == 117,                            'element symbols');


ok($xdi->filename =~ m{co_metal_rt.xdi},  'filename');
ok($xdi->xdi_libversion eq '1.1.0',       'xdi_libversion');
ok($xdi->xdi_version >= 1.0,              'xdi_version');
ok($xdi->extra_version =~ m{GSE},         'extra_version');

ok(ucfirst($xdi->element) eq 'Co',        'element');
ok(ucfirst($xdi->edge) eq 'K',            'edge');
ok(abs($xdi->dspacing - 3.13555) < $epsi, 'dspacing');
ok($xdi->comments =~ m{room temperature}, 'comments');
ok($xdi->nmetadata == 19,                 'nmetadata');

ok($xdi->comments =~ m{vert slits},       'comments');

my $hash = $xdi->metadata;
my @families = sort keys(%$hash);
ok($#families == 7, 'number of metadata families');

my $count = 0;
foreach my $f (@families) {
  $count += keys(%{$xdi->metadata->{$f}});
};
ok($count == $xdi->nmetadata,                                     'correct number of metadata items');

ok($xdi->metadata->{Mono}->{name} eq 'Si 111',                     'fetching Mono.name');
ok($xdi->metadata->{Facility}->{xray_source} eq 'APS undulator A', 'fetching Facility.xray_source');

ok($xdi->npts    == 417, 'npts');
ok($xdi->narrays ==   3, 'narrays');
ok($xdi->narrays == $xdi->narray_labels, 'narray_labels');

my $array_labels   = $xdi->array_labels;
ok($#{$array_labels} == $xdi->narrays -1,   'number of arrays');
ok((    ($array_labels->[0] eq 'energy' )
    and ($array_labels->[1] eq 'mutrans')
    and ($array_labels->[2] eq 'i0'     )), 'array labels');

my $array_units = $xdi->array_units;
ok(lc($array_units->[0]) eq 'ev', 'array units');


ok($#{$xdi->data->{$array_labels->[0]}} == $xdi->npts -1, 'number of pts, array 0');
ok($#{$xdi->data->{$array_labels->[1]}} == $xdi->npts -1, 'number of pts, array 1');
ok($#{$xdi->data->{$array_labels->[2]}} == $xdi->npts -1, 'number of pts, array 2');

ok((abs($xdi->data->{$array_labels->[0]}->[7] - 7579)       < $epsi), '7th data point, array 0');
ok((abs($xdi->data->{$array_labels->[1]}->[7] + 0.82160876) < $epsi), '7th data point, array 1');
ok((abs($xdi->data->{$array_labels->[2]}->[7] - 116268.7)   < $epsi), '7th data point, array 2');
