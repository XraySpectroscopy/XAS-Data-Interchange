#!/usr/bin/perl -I ../lib/

use Xray::XDI;
#$::RD_HINT = 1; # Parse::RecDescent hints
#$::RD_TRACE = 1; # Parse::RecDescent trace
my $xdi = Xray::XDI->new();
#$xdi -> file('../t/xdac_x.dat');
$xdi -> file('../t/xdac_uv.dat');
#$xdi -> file('../t/test.t');

if (not $xdi->is_xdi) {
  print "that wasn't an xdi file\n";
  exit;
};

print "xdi_version = ",  $xdi->xdi_version,        $/;
print "applications = ", $xdi->applications,       $/;

print "beamline = ",	 $xdi->beamline,           $/;
print "collimation = ",	 $xdi->collimation,        $/;
print "crystal = ",	 $xdi->crystal,            $/;
print "edgeenergy = ",	 $xdi->edge_energy,        $/;
print "focusing = ",	 $xdi->focusing,           $/;
print "mutrans = ",	 $xdi->mu_transmission,    $/;
print "mufluor = ",	 $xdi->mu_fluorescence,    $/;
print "muref = ",	 $xdi->mu_reference,       $/;
print "rejection = ",	 $xdi->harmonic_rejection, $/;
print "ringenergy = ",	 $xdi->ring_energy,        $/;
print "starttime = ",	 $xdi->start_time,         $/;
print "source = ",	 $xdi->source,             $/;

print "\nextension fields:\n";
foreach my $e (@{$xdi->extensions}) {
  print "\t", $e, $/;
}
print "\ncomments:\n\t";
print join("\n\t", @{$xdi->comments}), $/;
print "\nlabels:\n\t";
print join(" ", @{$xdi->labels}), $/;

print "\ndata:\n";
foreach my $p (@{$xdi->data}) {
  print "\t", join(" ", @{$p}), $/
}

$xdi->export('xdi.out');
