#!/usr/bin/perl -I ../lib/

use Xray::XDI;
use Data::Dump qw(dump);

#$::RD_HINT = 1; # Parse::RecDescent hints
#$::RD_TRACE = 1; # Parse::RecDescent trace
my $xdi = Xray::XDI->new();
$xdi -> file('../../data/cu_metal_rt.xdi');
#$xdi -> file('../t//mo_foil.003');

#print dump($xdi->column);


# print "\nextension fields:\n";
# foreach my $e (@{$xdi->extensions}) {
#   print "\t", $e, $/;
# }
# print "\ncomments:\n\t";
# print join("\n\t", @{$xdi->comments}), $/;
# print "\nlabels:\n\t";
# print join(" ", @{$xdi->labels}), $/;

# print "\ndata:\n";
# foreach my $p (@{$xdi->data}) {
#   print "\t", join(" ", @{$p}), $/
# }

$xdi->export('xdi.out');
