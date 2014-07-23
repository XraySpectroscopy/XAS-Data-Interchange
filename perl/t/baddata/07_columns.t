#!/usr/bin/perl  -I../../blib/lib -I../../blib/arch

## test the non numeric values in columns bad data examples

use Test::More tests => 9;

use strict;
use warnings;
use File::Basename;
use File::Spec;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_07.xdi');
my $xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->ok), 'bad_07.xdi flagged as ok');
ok((not $xdi->error), 'no column labels');

$file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_08.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->ok), 'bad_08.xdi flagged as ok');
ok((not $xdi->error), 'to few column labels');

$file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_09.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->ok), 'bad_09.xdi flagged as ok');
ok((not $xdi->error), 'to many column labels');

$file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_10.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->ok), 'bad_10.xdi flagged as ok');
ok((not $xdi->error), 'column indeces not continuous');


open(my $COV, '>>', 'coverage.txt');
print $COV 7,  $/;
print $COV 8,  $/;
print $COV 9,  $/;
print $COV 10, $/;
close $COV;
