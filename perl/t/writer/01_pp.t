#!/usr/bin/perl  -I../../blib/lib -I../../blib/arch

## test the pure perl writer

use Test::More tests => 13;

use strict;
use warnings;
use File::Basename;
use File::Spec;
use List::Util qw{sum};
use List::MoreUtils qw{pairwise};
use vars qw($a $b);

my $epsi = 0.0001;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', '..', 'data', 'cu_metal_10K.xdi');
my $xdi  = Xray::XDI->new(file=>$file);

$xdi->export('foo.xdi');

my $new  = Xray::XDI->new(file=>'foo.xdi');

ok($xdi->xdi_libversion eq $new->xdi_version,	      'xdi_version');
ok($xdi->extra_version  eq $new->extra_version,	      'extra_version');

ok(ucfirst($xdi->element) eq ucfirst($new->element),  'element');
ok(ucfirst($xdi->edge)    eq ucfirst($new->edge),     'edge');
ok(abs($xdi->dspacing - $new->dspacing) < $epsi,      'dspacing');
ok($xdi->comments         eq $new->comments,	      'comments');
ok($xdi->npts             == $new->npts,	      'npts');
ok($xdi->narrays          == $new->narrays,	      'narrays');
ok($xdi->narray_labels    == $new->narray_labels,     'narray_labels');

my @x = $xdi->get_array('mutrans');
my @y = $new->get_array('mutrans');
ok(sum(pairwise {abs($a - $b)} @x, @y) < $epsi,       'mutrans array');

$xdi->write('write.xdi');
$xdi->freeze('freeze.xdi');
ok(-s 'foo.xdi' == -s 'write.xdi',  'write alias' );
ok(-s 'foo.xdi' == -s 'freeze.xdi', 'freeze alias');

unlink 'foo.xdi';
unlink 'write.xdi';
unlink 'freeze.xdi';
