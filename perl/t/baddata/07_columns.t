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

$xdi->recommended;
ok(($xdi->errorcode>1), 'bad_07.xdi flagged as ok');
ok(($xdi->errormessage =~ m{Column.1}), 'no column labels');

$file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_08.xdi');
$xdi  = Xray::XDI->new(file=>$file);

$xdi->recommended;
ok(($xdi->errorcode == 0), 'bad_08.xdi flagged as ok');
ok(($xdi->errormessage =~ m{\A\s*\z}), 'to few column labels');

$file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_09.xdi');
$xdi  = Xray::XDI->new(file=>$file);

$xdi->recommended;
ok(($xdi->errorcode == 0), 'bad_09.xdi flagged as ok');
ok(($xdi->errormessage =~ m{\A\s*\z}), 'to many column labels');

$file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_10.xdi');
$xdi  = Xray::XDI->new(file=>$file);

$xdi->recommended;
ok(($xdi->errorcode == 0), 'bad_10.xdi flagged as ok');
ok(($xdi->errormessage =~ m{\A\s*\z}), 'column indeces not continuous');


open(my $COV, '>>', 'coverage.txt');
print $COV 7,  $/;
print $COV 8,  $/;
print $COV 9,  $/;
print $COV 10, $/;
close $COV;
