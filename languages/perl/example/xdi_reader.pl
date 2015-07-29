#!/usr/bin/perl

## This is a replica in perl of the xdi_reader.c test program
## the only difference is the order in which the metadata is printed to the screen
##
## to run this *before* installing Xray::XDI, try using the -I flag like so:
##   perl -Iblib/lib -Iblib/arch example/xdi_reader.pl ../../baddata/bad_32.xdi

use strict;
use warnings;
use Xray::XDI;

my $xdi = Xray::XDI->new(file=>$ARGV[0]||"");
if (not defined($xdi->xdifile)) {
  print  "Syntax: xdi_reader.pl filename\n";
  exit;
};
if ($xdi->errorcode < 0) {
  printf "Error reading XDI file '%s':\n\t%s\t(error code = %d)\n",       $ARGV[0], $xdi->errormessage, $xdi->errorcode;
  exit;
};
if ($xdi->errorcode > 0) {
  printf "Warning reading XDI file '%s':\n\t%s\t(warning code = %d)\n\n", $ARGV[0], $xdi->errormessage, $xdi->errorcode;
};


print  "#------\n";
printf "# XDI FILE Read %s: |%s|%s|\n", $xdi->filename, $xdi->xdi_version, $xdi->extra_version;
printf "# Elem/Edge: %s|%s|\n",         $xdi->element,  $xdi->edge;



print  "# User comments:\n";
print  $xdi->comments, $/;



printf "# Metadata(%d entries):\n--\n", $xdi->nmetadata;
foreach my $fam (sort keys %{$xdi->metadata}) {
  foreach my $key (sort keys %{$xdi->metadata->{$fam}}) {
    my $value = $xdi->metadata->{$fam}->{$key};
    printf " %s / %s => %s\n", $fam, $key, $value;
    my $i = $xdi->validate($fam, $key, $value);
    if ($i) {
      printf "-- Warning for %s.%s: %s\t(warning code = %d)\n\t%s\n",
	$fam, $key, $value, $i, $xdi->errormessage;
    };
  };
};
print $/;



my $i = $xdi->required;
printf "# check for required metadata -- (requirement code %d):\n%s\n", $i, $xdi->errormessage;

$i = $xdi->recommended;
printf "# check for recommended metadata -- (recommendation code %d):\n%s\n", $i, $xdi->errormessage;



printf "# Arrays Index, Name, Values: (%s points total):\n", $xdi->npts;
$i = 0;
foreach my $lab (@{$xdi->array_labels}) {
  my @x = $xdi->get_array($lab);
  printf "%d  %9s: %s, %s, %s, %s, ... %s, %s\n", $i, $lab, @x[0..3], @x[-2,-1];
  ++$i;
};
