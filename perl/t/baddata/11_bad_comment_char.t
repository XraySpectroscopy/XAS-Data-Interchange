#!/usr/bin/perl  -I../../blib/lib -I../../blib/arch

## test the bad comment character bad data example

use Test::More tests => 3;

use strict;
use warnings;
use File::Basename;
use File::Spec;

my $epsi = 0.001;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_11.xdi');
my $xdi  = Xray::XDI->new(file=>$file);

print $xdi->error, $/;

ok((not $xdi->ok), 'bad_11.xdi flagged as failing to import');
ok(($xdi->error =~ m{contains unrecognized header lines}), 'correctly identified bad comment character');


open(my $COV, '>>', 'coverage.txt');
print $COV 11, $/;
close $COV;
