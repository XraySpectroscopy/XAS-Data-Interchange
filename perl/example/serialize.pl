#!/usr/bin/perl

use strict;
use warnings;
use Xray::XDI;

my $xdi = Xray::XDI->new(file=>$ARGV[0]||"");
print  "Syntax: xdi_serialize.pl filename\n",                                                                          exit if not defined($xdi->xdifile);
printf "Error reading XDI file '%s':\n\t%s\t(error code = %d)\n",       $ARGV[0], $xdi->errormessage, $xdi->errorcode, exit if $xdi->errorcode < 0;
printf "Warning reading XDI file '%s':\n\t%s\t(warning code = %d)\n\n", $ARGV[0], $xdi->errormessage, $xdi->errorcode       if $xdi->errorcode > 0;

print "This is a one-line serialization:\n\n";

print $xdi->serialize;

print "\n\n\nThis is a lengthy serialization:\n\n";

print $xdi->serialization;
