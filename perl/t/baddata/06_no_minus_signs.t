#!/usr/bin/perl  -I../../blib/lib -I../../blib/arch

## test the no line of minus signs bad data example

use Test::More tests => 3;

use strict;
use warnings;
use File::Basename;
use File::Spec;

my $epsi = 0.001;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_06.xdi');
my $xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->warning and $xdi->ok), 'bad_06.xdi flagged with warning');
ok(($xdi->error =~ m{no line of minus signs}), 'correctly identified lack of minus signs ');


open(my $COV, '>>', 'coverage.txt');
print $COV 6, $/;
close $COV;
