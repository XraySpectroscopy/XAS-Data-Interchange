package Xray::XDI::Alien::XDAC;

use Moose::Role;
use MooseX::Aliases;
with 'Xray::XDI::Version1_0';	# use all the attributes, provide own get_grammar

use vars qw($debug);
$debug = 0;

sub x3a {
  my ($self) = @_;
  $self->set_beamline('collimation', 'none');
  $self->set_beamline('focusing', 'sagittally bent second crystal');
  $self->set_beamline('harmonic_rejection', 'flat cylindrically bent mirror');
  $self->set_mono('name', 'Si 111');
  return $self;
};

sub x3b {
  my ($self) = @_;
  $self->set_beamline('collimation', 'none');
  $self->set_beamline('focusing', 'sagittally bent second crystal');
  $self->set_beamline('harmonic_rejection', 'Nickel coated cylindrically bent mirror ');
  $self->set_mono('name', 'Si 111');
  return $self;
};

sub x11a {
  my ($self) = @_;
  $self->set_beamline('collimation', 'none');
  $self->set_beamline('focusing', 'none');
  $self->set_beamline('harmonic_rejection', 'detuned mono');
  return $self;
};

sub x11b {
  my ($self) = @_;
  $self->set_beamline('collimation', 'none');
  $self->set_beamline('focusing', 'none');
  $self->set_beamline('harmonic_rejection', 'bent second surface of channel-cut mono');
  $self->set_mono('name', 'Si 111');
  return $self;
};

sub x18a {
  my ($self) = @_;
  $self->set_beamline('collimation', 'none');
  $self->set_beamline('focusing', 'Cylindrical, rhodium-coated aluminum 1:1 focusing mirror');
  $self->set_beamline('harmonic_rejection', 'detuned mono');
  $self->set_mono('name', 'Si 111');
  return $self;
};

sub x18b {
  my ($self) = @_;
  $self->set_beamline('collimation', 'none');
  $self->set_beamline('focusing', 'none');
  $self->set_beamline('harmonic_rejection', 'detuned mono');
  $self->set_mono('name', 'Si 111');
  return $self;
};

sub x19a {
  my ($self) = @_;
  $self->set_beamline('collimation', 'Rh-coated spherical mirror, 3 mrad incident angle');
  $self->set_beamline('focusing', 'Rh-coated toroidal mirror');
  $self->set_beamline('harmonic_rejection', 'detuned mono');
  $self->set_mono('name', 'Si 111');
  return $self;
};

sub x23a2 {
  my ($self) = @_;
  $self->set_beamline('collimation', 'one');
  $self->set_beamline('focusing', 'none');
  $self->set_beamline('harmonic_rejection', 'flat Rh coated mirror');
  $self->set_mono('name', 'Si 311');
  return $self;
};

sub x23b {
  my ($self) = @_;
  $self->set_beamline('collimation', 'Pt-coated flat silicon mirror with 4-point bender');
  $self->set_beamline('focusing', 'Nii-coated quartz toroidal mirror');
  $self->set_beamline('harmonic_rejection', 'upstream mirrors');
  $self->set_mono('name', 'Si 111');
  return $self;
};

sub x24a {
  my ($self) = @_;
  $self->set_beamline('collimation', 'Ni-coated graphite spherical mirror');
  $self->set_beamline('focusing', 'Pt-coated quartz toroidal mirror');
  $self->set_beamline('harmonic_rejection', 'upstream mirrors');
  return $self;
};

sub u7a {
  my ($self) = @_;
  $self->set_beamline('collimation', 'none');
  $self->set_beamline('focusing', 'Au-coated ULE toroidal mirror with Au-coated ULE toroidal refocusuing mirror');
  $self->set_beamline('harmonic_rejection', 'none');
  $self->set_mono('name', 'Toroidal Spherical Grating Monochromator', '600 or 1200 lines/mm');
  return $self;
};


sub define_grammar  {
  return <<'_EOGRAMMAR_';
XDI: <skip: qr/[ \t]*/> COMMENTS LABELS(1) DATA


UPALPHA:    /[A-Z]+/
LOALPHA:    /[a-z]+/
ALPHA:      /[a-zA-Z]+/
DIGIT:      /[0-9]/
WORD:       /[-a-zA-Z0-9_]+/
PROPERWORD: /[a-zA-Z][-a-zA-Z0-9_]+/
NOTDASH:    /^[#;][ \t]*(?!-+)/
ANY:        /\A(?!-{3,})[^ \t\n\r]+/ # use the zero-width negative look-ahead
                                     # assertion to try to distinguish between
                                     # the line of dashes and a word that starts
                                     # with a dash

CR:         /\n/
LF:         /\r/
CRLF:       CR LF
#EOL:        CRLF | CR | LF
EOL:        /[\n\r]+/
SP:         / \t/
WS:         SP(s)
QUOTE:      /\"/
TEXT:       WORD
MATH:       /(?:ln)?[-+\*\$\/\(\)\d]+/
EXPRESSION: WORD | MATH | SP

INTEGER:    /\d+/
FLOAT:      /[+-]?\ *(\d+(\.\d*)?|\.\d+)([eEdD][+-]?\d+)?/  # see perlretut
EORK:       /[+-]?\ *(\d+(\.\d*)?|\.\d+)([eEdD][+-]?\d+)?(k?)/

HEADER_END: /-{2,}/ EOL

VERSION:    "XDAC V"  FLOAT "Datafile V" DIGIT  {
             print(join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
	     $Xray::XDI::object->applications("XDAC/".$item[2]);
            }

FILE:       QUOTE /[^\"]*/ QUOTE "created on" INTEGER "/" INTEGER "/" INTEGER "at" INTEGER ":" INTEGER ":" INTEGER /[AP]M/ "on" ANY {
               print(join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
               my $day   = $item[7];
               my $month = $item[5];
               my $year  = ($item[9] > 79) ? 1900+$item[9] : 2000+$item[9];
               my $hour  = (lc($item[16]) eq 'am') ? $item[11] : $item[11]+12;
               my $min   = $item[13];
               my $sec   = $item[15];
	       $Xray::XDI::object->set_scan('start_time', sprintf("%d-%2.2d-%2.2d%s%2.2d:%2.2d:%2.2d", $year, $month, $day, 'T', $hour, $min, $sec));
               (my $beamline = lc($item[18])) =~ s{-}{};
	       $Xray::XDI::object->set_beamline('name', "NSLS ".uc($beamline));
               $Xray::XDI::object->$beamline;
	       $Xray::XDI::object->set_facility('xray_source', 'bend magnet');
            }

REFLECTION: /\(\d{3}\)/
MATERIAL:   ("Si" | "Ge" | "Diamond" | "YB66" | "InSb" | "Beryl" | "Multilayer")
CRYSTAL:    "Diffraction element=" (MATERIAL | INTEGER) (REFLECTION | "l/mm") "." "Ring energy=" FLOAT "GeV" {
               print(join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
               if ($item[2] =~ m{\A\d+\z}) {
                 $Xray::XDI::object->set_mono('name', join(" ", "Grating", $item[2], $item[3]));
               } else {
                 $Xray::XDI::object->set_mono('name', join(" ", $item[2], substr($item[3], 1, -1)));
               };
               my $energy = ($item[6] > 100) ? $item[6]/1000 : $item[6];
               $Xray::XDI::object->set_facility('energy', $energy);
            }

## XDAC V1.2 files do not report the diffracting element on the ring energy line
RINGENERGY: "Ring energy=" FLOAT "GeV" {
               my $energy = ($item[2] > 100) ? $item[2]/1000 : $item[2];
               $Xray::XDI::object->set_facility('energy', $energy);
            }

ENOT:       "E0=" FLOAT {
               print(join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
               $Xray::XDI::object->set_scan('edge_energy', $item[2]);
            }

REGIONS:    "NUM_REGIONS=" INTEGER {
             print(join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC.NUM_REGIONS" . ': '. $item[2]);
            }

SRB:        "SRB=" EORK(s) {
             print(join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC.SRB" . ': '. join(" ", @{$item[2]}));
            }

SRSS:       "SRSS=" EORK(s) {
             print(join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC.SRSS" . ': '. join(" ", @{$item[2]}));
            }

SPP:        "SPP=" EORK(s) {
             print(join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC.SPP" . ': '. join(" ", @{$item[2]}));
            }

SETTLE:     "Settling time=" FLOAT {
             print(join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC.Settling_time" . ': '. join(" ", $item[2]));
            }

OFFSETS:    "Offsets=" FLOAT(s) {
             print(join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC.Offsets" . ': '. join(" ", @{$item[2]}));
            }

GAINS:      "Gains=" FLOAT(s) {
             print(join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC.Gains" . ': '. join(" ", @{$item[2]}));
            }

COMMLINE:   ANY(s) {
             print("comment: ", join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
             $Xray::XDI::object->push_comment(join(" ", @{$item[1]}));
            }

HEADER: ( VERSION | FILE | CRYSTAL | RINGENERGY | ENOT |
          REGIONS | SRB | SRSS | SPP | SETTLE | OFFSETS | GAINS |
          COMMLINE ) EOL
COMMENTS:  HEADER(s) HEADER_END


LABEL:    ANY
LABELS:   LABEL(s) EOL {
             print(join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
             $Xray::XDI::object->push_label(@{$item[1]});
            }

DATA_LINE: FLOAT(s) EOL {
             print(join("~", @item), $/) if $Xray::XDI::Alien::XDAC::debug;
             $Xray::XDI::object->add_data_point(@{$item[1]})  if $#{$item[1]}>-1;
             #print join("~", "DATA_LINE", @{$item[2]}), $/;
            }
DATA:      DATA_LINE(s?)

_EOGRAMMAR_
}


1;


=head1 NAME

Xray::XDI::Alien::XDAC - Import an NSLS XDAC file in an XDI object

=head1 VERSION

This role defines NSLS XDAC import for version 1.0 of the XAS Data
Interchange grammar.

=head1 ATTRIBUTES

All attributes are inherited from L<Xray::XDI::Version1_0>.

=head1 METHODS

This provides its own C<get_grammer> method for parsing XDAC files and
collecting XDI metadata from the headers.

This also provides a series of beamline-specific methods that, in
effect, provide a lookup table of values for XDI defined fields having
to do with beamline optics.

=head1 BUGS AND LIMITATIONS

This inherits the bugs and limitations of L<Xray::XDI::Version1_0>.

Please report problems to Bruce Ravel (bravel AT bnl DOT gov)

Patches are welcome.

=head1 AUTHOR

Bruce Ravel (bravel AT bnl DOT gov)

L<http://cars9.uchicago.edu/~ravel/software/>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2011 Bruce Ravel (bravel AT bnl DOT gov). All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlgpl>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut
