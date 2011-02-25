#!/usr/bin/perl

use Test::More tests => 10;

use File::Basename;
use File::Spec;
use List::MoreUtils qw(any);

use Xray::XDI;
#$::RD_HINT = 1; # Parse::RecDescent hints
#$::RD_TRACE = 1; # Parse::RecDescent trace

my $here  = dirname($0);

## test a properly formatted XDI file

my $xdi = Xray::XDI->new();
$xdi -> file(File::Spec->catfile($here, 'xdi.aps10id'));
$xdi -> parse;
ok( $xdi->xdi_version eq $Xray::XDI::VERSION,       "version recognized");
ok( $xdi->beamline eq "APS 10ID",                   "defined header (beamline) recognized");
ok( any {$_ eq "MX-SRB: 6900"} @{$xdi->extensions}, "extension header (beamline) recognized");
ok( $#{$xdi->comments} == 2,                        "comments imported");
ok( $#{$xdi->data} == 4,                            "data imported");
ok( join(" ", @{$xdi->labels}) eq "energy mcs3 mcs4 mcs6 mcs5",     "labels imported");

undef $xdi;

## test a minimal XDi file (all headers interpreted as comments, lables and data parsed)

$xdi = Xray::XDI->new();
$xdi -> file(File::Spec->catfile($here, 'mo_foil.003'));
$xdi -> parse;
ok( $#{$xdi->extensions} == -1,                      "extenstions do not exist in this file");
ok( $#{$xdi->comments} == 44,                        "comments imported");
ok( $#{$xdi->data} == 179,                           "data imported");
ok( join(" ", @{$xdi->labels}) eq "P1 P2 D1 D2",     "labels imported");
