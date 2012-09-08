#!/usr/bin/perl  -I../../blib/lib -I../../blib/arch

## test the non numeric values in columns bad data examples

use Test::More tests => 7;

use strict;
use warnings;
use File::Basename;
use File::Spec;

my $epsi = 0.001;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_15.xdi');
my $xdi  = Xray::XDI->new(file=>$file);

ok((not $xdi->ok), 'bad_15.xdi flagged as failing to import');
ok(($xdi->error =~ m{non-numeric value}), 'correctly identified NaN as a problem');

$file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_16.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok((not $xdi->ok), 'bad_16.xdi flagged as failing to import');
ok(($xdi->error =~ m{non-numeric value}), 'correctly identified string as a problem');

$file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_17.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok((not $xdi->ok), 'bad_17.xdi flagged as failing to import');
ok(($xdi->error =~ m{non-numeric value}), 'correctly identified 1.2.3 as a problem');


open(my $COV, '>>', 'coverage.txt');
print $COV 15, $/;
print $COV 16, $/;
print $COV 17, $/;
close $COV;
