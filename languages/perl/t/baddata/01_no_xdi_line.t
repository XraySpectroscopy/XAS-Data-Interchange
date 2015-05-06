#!/usr/bin/perl  -I../../blib/lib -I../../blib/arch

## test the no XDI line bad data example

use Test::More tests => 3;

use strict;
use warnings;
use File::Basename;
use File::Spec;

my $epsi = 0.001;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', '..', '..', 'baddata', 'bad_01.xdi');
my $xdi  = Xray::XDI->new(file=>$file);
#my $xdi  = Xray::XDI->new;
#$xdi->file($file);

ok(($xdi->errorcode<0), 'bad_01.xdi flagged as failing to import');
ok(($xdi->errormessage =~ m{not an XDI}), 'correctly identified problem');

open(my $COV, '>', 'coverage.txt');
print $COV 1, $/;
close $COV;
