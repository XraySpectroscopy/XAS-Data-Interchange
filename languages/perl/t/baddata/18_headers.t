#!/usr/bin/perl  -I../../blib/lib -I../../blib/arch

## test the bad headers examples

use Test::More tests => 13;

use strict;
use warnings;
use File::Basename;
use File::Spec;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', '..', '..', 'baddata', 'bad_18.xdi');
my $xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->errorcode<0), 'bad_18.xdi flagged as failing to import');
ok(($xdi->errormessage =~ m{not formatted as}), 'correctly identified Family.Key -- no value');

$file = File::Spec->catfile($here, '..', '..', '..', '..', 'baddata', 'bad_19.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->errorcode<0), 'bad_19.xdi flagged as failing to import');
ok(($xdi->errormessage =~ m{not formatted as}), 'correctly identified Family.Key -- no colon');

$file = File::Spec->catfile($here, '..', '..', '..', '..', 'baddata', 'bad_20.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->errorcode<0), 'bad_20.xdi flagged as failing to import');
ok(($xdi->errormessage =~ m{not formatted as}), 'correctly identified Family.Key -- two colons');

$file = File::Spec->catfile($here, '..', '..', '..', '..', 'baddata', 'bad_21.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->errorcode<0), 'bad_21.xdi flagged as failing to import');
ok(($xdi->errormessage =~ m{not formatted as}), 'correctly identified Family.Key -- no dot');

$file = File::Spec->catfile($here, '..', '..', '..', '..', 'baddata', 'bad_22.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->errorcode<0), 'bad_22.xdi flagged as failing to import');
ok(($xdi->errormessage =~ m{invalid keyword name}), 'correctly identified Family.Key -- two dots');

# $file = File::Spec->catfile($here, '..', '..', '..', '..', 'baddata', 'bad_23.xdi');
# $xdi  = Xray::XDI->new(file=>$file);

# ok(($xdi->errorcode==0), 'bad_23.xdi flagged as ok');
# ok(($xdi->errormessage), 'correctly identified Family.Key -- key starts with number');


$file = File::Spec->catfile($here, '..', '..', '..', '..', 'baddata', 'bad_24.xdi');
$xdi  = Xray::XDI->new(file=>$file);

ok(($xdi->errorcode<0), 'bad_24.xdi flagged as failing to import');
ok(($xdi->errormessage =~ m{invalid family name}), 'correctly identified Family.Key -- family starts with number');

open(my $COV, '>>', 'coverage.txt');
print $COV 18, $/;
print $COV 19, $/;
print $COV 20, $/;
print $COV 21, $/;
print $COV 22, $/;
print $COV 23, $/;
print $COV 24, $/;
close $COV;
