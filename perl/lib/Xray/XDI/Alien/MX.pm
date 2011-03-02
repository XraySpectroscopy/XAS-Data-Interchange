package Xray::XDI::Alien::MX;

use Moose::Role;
use MooseX::Aliases;
with 'Xray::XDI::Version1_0';	# use all the attributes, provide own get_grammar

use vars qw($debug);
$debug = 0;

sub id {
  my ($self) = @_;
  $self->source('APS undulator A');
  $self->focusing('none (possibly KB mirrors)');
  $self->harmonic_rejection('flat, cylindrically bent mirror with Pt or Rh coating');
  return $self;
};

sub bm {
  my ($self) = @_;
  $self->source('bending magnet');
  $self->focusing('none');
  $self->harmonic_rejection('none');
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

VERSION:    "MRCAT_XAFS V"  FLOAT WORD  {
             print(join("~", @item), $/) if $Xray::XDI::Alien::MX::debug;
	     $Xray::XDI::object->applications("MX/".$item[2]);
            }

FILE:       QUOTE /[^\"]*/ QUOTE "created at APS" ("Sector 10-ID" | WORD) "on" WORD WORD INTEGER INTEGER ":" INTEGER ":" INTEGER INTEGER {
               print(join("~", @item), $/) if $Xray::XDI::Alien::MX::debug;
               my %months = (Jan=>1, Feb=>2, Mar=>3, Apr=>4, May=>5, Jun=>6, Jul=>7, Aug=>8, Sep=>9, Oct=>10, Nov=>11, Dec=>12);
               my $day   = $item[9];
               my $month = $months{$item[8]};
               my $year  = $item[15];
               my $hour  = $item[10];
               my $min   = $item[12];
               my $sec   = $item[14];
	       $Xray::XDI::object->start_time(sprintf("%d-%2.2d-%2.2d%s%2.2d:%2.2d:%2.2d", $year, $month, $day, 'T', $hour, $min, $sec));
               my $beamline = (lc($item[5]) =~ m{bm}) ? 'bm' : 'id';
	       $Xray::XDI::object->beamline("APS 10".uc($beamline));
	       $Xray::XDI::object->collimation('none');
               $Xray::XDI::object->$beamline;
            }

RINGENERGY: "Ring energy=" FLOAT "GeV" {
               my $energy = ($item[2] > 100) ? $item[2]/1000 : $item[2];
               $Xray::XDI::object->ring_energy($energy);
            }

ENOT:       "E0=" FLOAT {
               print(join("~", @item), $/) if $Xray::XDI::Alien::MX::debug;
               $Xray::XDI::object->edge_energy($item[2]);
	       ($item[2] < 10000) ? $Xray::XDI::object->undulator_harmonic('1') : $Xray::XDI::object->undulator_harmonic('3');
            }

REGIONS:    "NUM_REGIONS=" INTEGER {
             print(join("~", @item), $/) if $Xray::XDI::Alien::MX::debug;
             $Xray::XDI::object->push_extension("MX-NUM_REGIONS" . ': '. $item[2]);
            }

SRB:        "SRB=" EORK(s) {
             print(join("~", @item), $/) if $Xray::XDI::Alien::MX::debug;
             $Xray::XDI::object->push_extension("MX-SRB" . ': '. join(" ", @{$item[2]}));
            }

SRSS:       "SRSS=" EORK(s) {
             print(join("~", @item), $/) if $Xray::XDI::Alien::MX::debug;
             $Xray::XDI::object->push_extension("MX-SRSS" . ': '. join(" ", @{$item[2]}));
            }

SPP:        "SPP=" EORK(s) {
             print(join("~", @item), $/) if $Xray::XDI::Alien::MX::debug;
             $Xray::XDI::object->push_extension("MX-SPP" . ': '. join(" ", @{$item[2]}));
            }

SETTLE:     "Settling time=" FLOAT {
             print(join("~", @item), $/) if $Xray::XDI::Alien::MX::debug;
             $Xray::XDI::object->push_extension("MX-Settling_time" . ': '. join(" ", $item[2]));
            }

OFFSETS:    "Offsets=" FLOAT(s) {
             print(join("~", @item), $/) if $Xray::XDI::Alien::MX::debug;
             $Xray::XDI::object->push_extension("MX-Offsets" . ': '. join(" ", @{$item[2]}));
            }

GAINS:      "Gains=" FLOAT(s) {
             print(join("~", @item), $/) if $Xray::XDI::Alien::MX::debug;
             $Xray::XDI::object->push_extension("MX-Gains" . ': '. join(" ", @{$item[2]}));
            }

COMMLINE:   ANY(s) {
             print("comment: ", join("~", @item), $/) if $Xray::XDI::Alien::MX::debug;
             $Xray::XDI::object->push_comment(join(" ", @{$item[1]}));
            }

HEADER: ( VERSION | FILE | RINGENERGY | ENOT |
          REGIONS | SRB | SRSS | SPP | SETTLE | OFFSETS | GAINS |
          COMMLINE ) EOL
COMMENTS:  HEADER(s) HEADER_END


LABEL:    ANY
LABELS:   LABEL(s) EOL {
             print(join("~", @item), $/) if $Xray::XDI::Alien::MX::debug;
             $Xray::XDI::object->push_label(@{$item[1]});
            }

DATA_LINE: FLOAT(s) EOL {
             print(join("~", @item), $/) if $Xray::XDI::Alien::MX::debug;
             $Xray::XDI::object->add_data_point(@{$item[1]})  if $#{$item[1]}>-1;
             #print join("~", "DATA_LINE", @{$item[2]}), $/;
            }
DATA:      DATA_LINE(s?)

_EOGRAMMAR_
}


1;


=head1 NAME

Xray::XDI::Alien::MX - Import an NSLS MX file in an XDI object

=head1 VERSION

This role defines APS MX import for version 1.0 of the XAS Data
Interchange grammar.

=head1 ATTRIBUTES

All attributes are inherited from L<Xray::XDI::Version1_0>.

=head1 METHODS

This provides its own C<get_grammer> method for parsing MX files and
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
