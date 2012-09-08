#!/usr/bin/perl  -I../../blib/lib -I../../blib/arch

## test the inconsistent column number bad data examples

use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;
use File::Spec;

my $epsi = 0.001;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_13.xdi');
my $xdi  = Xray::XDI->new(file=>$file);

ok((not $xdi->ok), 'bad_13.xdi flagged as failing to import');
ok(($xdi->error =~ m{number of columns changes}), 'correctly identified too few columns');

$file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_14.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok((not $xdi->ok), 'bad_14.xdi flagged as failing to import');
ok(($xdi->error =~ m{number of columns changes}), 'correctly identified too many columns');
