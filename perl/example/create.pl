#!/usr/bin/perl

use strict;
use warnings;
use Xray::XDI;


my $xdi = Xray::XDI->new();

$xdi->edge('K');
$xdi->element('Foo');

print $xdi->element, $/;
print $xdi->edge, $/;

