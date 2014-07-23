#!/usr/bin/perl  -I../blib/lib -I../blib/arch

## test the Inline C code in the Xray::XDIFile module

use Test::More tests => 46;

use strict;
use warnings;
use File::Basename;
use File::Spec;

my $epsi = 0.001;

BEGIN { use_ok('Xray::XDIFile') };

my $errcode = 0;
my $here    = dirname($0);
my $file    = File::Spec->catfile($here, '..', '..', 'data', 'co_metal_rt.xdi');
my $xdifile = Xray::XDIFile->new($file, $errcode);
ok($errcode == 0,                              'error code = 0');
ok($xdifile =~ m{Xray::XDIFile},               'created Xray::XDIFile object');

ok( $xdifile->_token('comment') eq '#',                 'token: comment');
ok( $xdifile->_token('delimiter') eq ':',               'token: delimiter');
ok( $xdifile->_token('dot') eq '.',                     'token: dot');
ok( $xdifile->_token('startcomment') eq '///',          'token: startcomment');
ok( $xdifile->_token('endcomment') eq '---',            'token: endcomment');
ok( $xdifile->_token('energycolumn') eq 'energy',       'token: energycolumn');
ok( $xdifile->_token('anglecolumn') eq 'angle',         'token: anglecolumn');
ok( $xdifile->_token('version') eq 'XDI/',              'token: version');
ok( $xdifile->_token('edge') eq 'element.edge',         'token: edge');
ok( $xdifile->_token('element') eq 'element.symbol',    'token: element');
ok( $xdifile->_token('column') eq 'column.',            'token: column');
ok( $xdifile->_token('dspacing') eq 'mono.d_spacing',   'token: dspacing');
ok( $xdifile->_token('timestamp') eq 'scan.start_time', 'token: starttime');
ok( $xdifile->_token('glorb') eq '',                    'token: "glorb" is not a token');

my @edges = $xdifile->_valid_edges;
ok($#edges == 26, 'edge symbols');
my @elements = $xdifile->_valid_elements;
ok($#elements == 117, 'element symbols');

ok($xdifile->_filename =~ m{co_metal_rt.xdi},  'filename');
ok($xdifile->_xdi_libversion eq '1.1.0',       'xdi_libversion');
ok($xdifile->_xdi_version >= 1.0,              'xdi_version');
ok($xdifile->_extra_version =~ m{GSE},         'extra_version');

ok(ucfirst($xdifile->_element) eq 'Co',        'element');
ok(ucfirst($xdifile->_edge) eq 'K',            'edge');
ok(abs($xdifile->_dspacing - 3.13555) < $epsi, 'dspacing');
ok($xdifile->_comments =~ m{room temperature}, 'comments');
ok($xdifile->_nmetadata == 19,                 'nmetadata');

my @families = $xdifile->_meta_families;
my @keywords = $xdifile->_meta_keywords;
my @values   = $xdifile->_meta_values;

ok($#families == $xdifile->_nmetadata -1, 'number of families');
ok($#families == $xdifile->_nmetadata -1, 'number of keywords');
ok($#values   == $xdifile->_nmetadata -1, 'number of values');

ok($families[6] eq 'Mono',   'specific family');
ok($keywords[6] eq 'name',   'specific keyword');
ok($values[6]   eq 'Si 111', 'specific value');

ok($xdifile->_npts    == 418, 'npts');
ok($xdifile->_narrays ==   3, 'narrays');
ok($xdifile->_narrays ==  $xdifile->_narray_labels, 'narray_labels');

my @array_labels   = $xdifile->_array_labels;
ok($#array_labels == $xdifile->_narrays -1, 'number of arrays');
ok((($array_labels[0] eq 'energy') and ($array_labels[1] eq 'mutrans') and ($array_labels[2] eq 'i0')), 'array labels');

my @array_units = $xdifile->_array_units;
ok(lc($array_units[0]) eq 'ev', 'array units');

my @x = $xdifile->_data_array(0);
my @y = $xdifile->_data_array(1);
my @z = $xdifile->_data_array(2);

ok($#x == $xdifile->_npts -1, 'number of pts, array 0');
ok($#y == $xdifile->_npts -1, 'number of pts, array 1');
ok($#z == $xdifile->_npts -1, 'number of pts, array 2');

ok((abs($x[7] - 7579)       < $epsi), '7th data point, array 0');
ok((abs($y[7] + 0.82160876) < $epsi), '7th data point, array 1');
ok((abs($z[7] - 116268.7)   < $epsi), '7th data point, array 2');
