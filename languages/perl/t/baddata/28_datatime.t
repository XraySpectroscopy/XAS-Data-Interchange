#!/usr/bin/perl  -I../../blib/lib -I../../blib/arch

## test bad timestamp examples

use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;
use File::Spec;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', '..', '..', 'baddata', 'bad_28.xdi');
my $xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->errorcode == 0), 'bad_28.xdi imports ok');
$xdi->validate('Scan', 'start_time', $xdi->metadata->{Scan}->{start_time});
ok(($xdi->errormessage =~ m{invalid timestamp}), 'correctly identified invalid timestamp format');

$file = File::Spec->catfile($here, '..', '..', '..', '..', 'baddata', 'bad_29.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->errorcode == 0), 'bad_29.xdi imports ok');
$xdi->validate('Scan', 'start_time', $xdi->metadata->{Scan}->{start_time});
ok(($xdi->errormessage =~ m{invalid timestamp}), 'correctly identified invalid timestamp month range');

open(my $COV, '>>', 'coverage.txt');
print $COV 28, $/;
print $COV 29, $/;
close $COV;
