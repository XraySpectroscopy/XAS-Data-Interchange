#!/usr/bin/perl  -I../../blib/lib -I../../blib/arch

## test bad timestamp examples

use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;
use File::Spec;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_28.xdi');
my $xdi  = Xray::XDI->new(file=>$file);

ok((not $xdi->ok), 'bad_28.xdi flagged as failing to import');
ok(($xdi->error =~ m{invalid timestamp}), 'correctly identified invalid timestamp format');

$file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_29.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok((not $xdi->ok), 'bad_29.xdi flagged as failing to import');
ok(($xdi->error =~ m{invalid timestamp}), 'correctly identified invalid timestamp month range');

open(my $COV, '>>', 'coverage.txt');
print $COV 28, $/;
print $COV 29, $/;
close $COV;
