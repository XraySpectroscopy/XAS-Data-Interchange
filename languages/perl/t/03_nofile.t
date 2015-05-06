#!/usr/bin/perl  -I../blib/lib -I../blib/arch

## test that unfindable and non-XDI files are handled sensibly

use Test::More tests => 3;

use strict;
use warnings;
use File::Basename;
use File::Spec;

BEGIN { use_ok('Xray::XDI') };

my $here = dirname($0);
my $file = File::Spec->catfile($here, '..', '..', 'data', 'co_metal_rt.xdiX');
my $xdi  = Xray::XDI->new(file=>$file);
ok($xdi->errormessage =~ m{does not exist},                        'file not exist');

$file = File::Spec->catfile($here, '..', '..', 'data');
$xdi  = Xray::XDI->new(file=>$file);
ok($xdi->errormessage =~ m{is a folder},                           'is a folder');

