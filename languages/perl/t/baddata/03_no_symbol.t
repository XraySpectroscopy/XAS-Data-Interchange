#!/usr/bin/perl  -I../../blib/lib -I../../blib/arch

## test the no XDI line bad data example

use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;
use File::Spec;

my $epsi = 0.001;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', '..', '..', 'baddata', 'bad_03.xdi');
my $xdi  = Xray::XDI->new(file=>$file);

$xdi->required;
ok(($xdi->errorcode>0), 'bad_03.xdi flagged with a warning');
ok(($xdi->errormessage =~ m{Element.symbol missing}), 'correctly identified missing element symbol');

$file = File::Spec->catfile($here, '..', '..', '..', '..', 'baddata', 'bad_05.xdi');
$xdi  = Xray::XDI->new(file=>$file);

$xdi->required;
ok(($xdi->errorcode>0), 'bad_05.xdi flagged with a warning');
ok(($xdi->errormessage =~ m{Element.symbol missing}), 'correctly identified invalid element symbol');


open(my $COV, '>>', 'coverage.txt');
print $COV 3, $/;
print $COV 5, $/;
close $COV;
