#!/usr/bin/perl  -I../../blib/lib -I../../blib/arch

## test exmples with various things missing

use Test::More tests => 7;

use strict;
use warnings;
use File::Basename;
use File::Spec;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_25.xdi');
my $xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->ok), 'bad_25.xdi flagged as ok');
ok((not $xdi->error), 'missing extra version');

$file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_26.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->ok), 'bad_26.xdi flagged as ok');
ok((not $xdi->error), 'missing user comments');

$file = File::Spec->catfile($here, '..', '..', '..', 'baddata', 'bad_27.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->ok), 'bad_27.xdi flagged as ok');
ok((not $xdi->error), 'line of slashes, no user comments');

open(my $COV, '>>', 'coverage.txt');
print $COV 25, $/;
print $COV 26, $/;
print $COV 27, $/;
close $COV;
