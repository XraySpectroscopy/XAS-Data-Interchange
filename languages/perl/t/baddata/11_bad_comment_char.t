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

ok(($xdi->errorcode>0), 'bad_11.xdi flagged with warning on import');
ok(($xdi->errormessage =~ m{contains unrecognized header lines}), 'correctly identified bad comment character in metadata line');


open(my $COV, '>>', 'coverage.txt');
print $COV 11, $/;
close $COV;
