package Xray::XDI::XDAC;

use Moose::Role;
use MooseX::Aliases;

use vars qw($debug);
$debug = 0;

has 'version'	         => (is => 'rw', isa => 'Str', default => q{1.0});

has 'applications'	 => (is => 'rw', isa => 'Str', default => q{});

has 'abscissa'   	 => (is => 'rw', isa => 'Str', default => q{});
has 'beamline'		 => (is => 'rw', isa => 'Str', default => q{});
has 'collimation'	 => (is => 'rw', isa => 'Str', default => q{});
has 'crystal'		 => (is => 'rw', isa => 'Str', default => q{});
has 'd_spacing'		 => (is => 'rw', isa => 'Str', default => q{});
has 'edge_energy'	 => (is => 'rw', isa => 'Str', default => q{});
has 'end_time'		 => (is => 'rw', isa => 'Str', default => q{});
has 'focusing'		 => (is => 'rw', isa => 'Str', default => q{});
has 'harmonic_rejection' => (is => 'rw', isa => 'Str', default => q{});
has 'mu_fluorescence'	 => (is => 'rw', isa => 'Str', default => q{});
has 'mu_reference'	 => (is => 'rw', isa => 'Str', default => q{});
has 'mu_transmission'	 => (is => 'rw', isa => 'Str', default => q{});
has 'ring_current'	 => (is => 'rw', isa => 'Str', default => q{});
has 'ring_energy'	 => (is => 'rw', isa => 'Str', default => q{});
has 'start_time'	 => (is => 'rw', isa => 'Str', default => q{});
has 'source'		 => (is => 'rw', isa => 'Str', default => q{});
#has 'step_offset'	 => (is => 'rw', isa => 'Str', default => q{});
#has 'step_scale'	 => (is => 'rw', isa => 'Str', default => q{});
has 'undulator_harmonic' => (is => 'rw', isa => 'Str', default => q{});

## note that the MooseX::Aliases 0.08 pod is incorrect in how to get
## an alias applied in a role.  the following works, but was a bit
## hard to figure out.  version 0.09 does *not* fix the problem
## (although it might with Moose 1.24)
has 'comment_character'  => (is => 'rw', isa => 'Str', default => q{#},
			     traits => ['MooseX::Aliases::Meta::Trait::Attribute'],
			     alias=>'cc');
has 'field_end'          => (is => 'rw', isa => 'Str', default => q{#}.'/' x 3,
			     traits => ['MooseX::Aliases::Meta::Trait::Attribute'],
			     alias=>'fe');
has 'header_end'         => (is => 'rw', isa => 'Str', default => q{#}.'-' x 60,
			     traits => ['MooseX::Aliases::Meta::Trait::Attribute'],
			     alias=>'he');
has 'record_separator'   => (is => 'rw', isa => 'Str', default => "\t",
			     traits => ['MooseX::Aliases::Meta::Trait::Attribute'],
			     alias=>'rs');


has 'order' 	   => (is => 'rw', isa => 'ArrayRef',
		       default => sub{ ['applications',
					'beamline',
					'source',
					'undulator_harmonic',
					'ring_energy',
					'ring_current',
					'collimation',
					'crystal',
					'd_spacing',
					'focusing',
					'harmonic_rejection',
					'edge_energy',
					'start_time',
					'end_time',
					'abscissa',
					'mu_transmission',
					'mu_fluorescence',
					'mu_reference',
				       ] });


sub x3a {
  my ($self) = @_;
  $self->collimation(q{});
  $self->focusing(q{sagittally bent second crystal});
  $self->harmonic_rejection(q{});
  return $self;
};

sub x3b {
  my ($self) = @_;
  $self->collimation(q{});
  $self->focusing(q{sagittally bent second crystal});
  $self->harmonic_rejection(q{});
  return $self;
};

sub x11a {
  my ($self) = @_;
  $self->collimation(q{none});
  $self->focusing(q{none});
  $self->harmonic_rejection(q{detuned first crystal});
  return $self;
};

sub x11b {
  my ($self) = @_;
  $self->collimation(q{none});
  $self->focusing(q{none});
  $self->harmonic_rejection(q{bent second surface of channel-cut mono});
  return $self;
};

sub x18a {
  my ($self) = @_;
  $self->collimation(q{});
  $self->focusing(q{});
  $self->harmonic_rejection(q{});
  return $self;
};

sub x18b {
  my ($self) = @_;
  $self->collimation(q{});
  $self->focusing(q{});
  $self->harmonic_rejection(q{});
  return $self;
};

sub x19a {
  my ($self) = @_;
  $self->collimation(q{});
  $self->focusing(q{});
  $self->harmonic_rejection(q{});
  return $self;
};

sub x23a2 {
  my ($self) = @_;
  $self->collimation('none');
  $self->focusing('none');
  $self->harmonic_rejection('flat Rh coated mirror');
  return $self;
};

sub x23b {
  my ($self) = @_;
  $self->collimation(q{});
  $self->focusing(q{});
  $self->harmonic_rejection(q{});
  return $self;
};

sub u7a {
  my ($self) = @_;
  $self->collimation(q{blah});
  $self->focusing(q{blah});
  $self->harmonic_rejection(q{blah});
  return $self;
};


sub define_grammar {
  return <<'_EOGRAMMAR_';
XDI: <skip: qr/[ \t]*/> COMMENTS LABELS(1) DATA


UPALPHA:    /[A-Z]+/
LOALPHA:    /[a-z]+/
ALPHA:      /[a-zA-Z]+/
DIGIT:      /[0-9]/
WORD:       /[-a-zA-Z0-9_]+/
PROPERWORD: /[a-zA-Z][-a-zA-Z0-9_]+/
NOTDASH:    /^[#;][ \t]*(?!-+)/
ANY:        /\A.(?!-{3,})[^ \t\n\r]+/ # use the zero-width negative look-ahead
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
             print(join("~", @item), $/) if $Xray::XDI::XDAC::debug;
	     $Xray::XDI::object->applications("XDAC/".$item[2]);
            }

FILE:       QUOTE /[^\"]*/ QUOTE "created on" INTEGER "/" INTEGER "/" INTEGER "at" INTEGER ":" INTEGER ":" INTEGER /[AP]M/ "on" ANY {
               print(join("~", @item), $/) if $Xray::XDI::XDAC::debug;
               my $day   = $item[7];
               my $month = $item[5];
               my $year  = ($item[9] > 79) ? 1900+$item[9] : 2000+$item[9];
               my $hour  = (lc($item[16]) eq 'am') ? $item[11] : $item[11]+12;
               my $min   = $item[13];
               my $sec   = $item[15];
	       $Xray::XDI::object->start_time(sprintf("%d-%d-%d%s%d:%d:%d", $year, $month, $day, 'T', $hour, $min, $sec));
	       $Xray::XDI::object->beamline($item[18]);
               (my $method = lc($item[18])) =~ s{-}{};
               $Xray::XDI::object->$method;
	       $Xray::XDI::object->source('bend magnet');
            }

REFLECTION:     /\(\d{3}\)/
MATERIAL:       ("Si" | "Ge" | "Diamond" | "YB66" | "InSb" | "Beryl" | "Multilayer")
CRYSTAL:    "Diffraction element=" (MATERIAL|INTEGER) (REFLECTION | "l/mm") "." "Ring energy=" FLOAT "GeV" {
               print(join("~", @item), $/) if $Xray::XDI::XDAC::debug;
               if ($item[2] =~ m{\A\d+\z}) {
                 $Xray::XDI::object->crystal(join(" ", "Grating", $item[2], $item[3]));
               } else {
                 $Xray::XDI::object->crystal(join(" ", $item[2], substr($item[3], 1, -1)));
               };
               my $energy = ($item[6] > 100) ? $item[6]/1000 : $item[6];
               $Xray::XDI::object->ring_energy($energy);
            }

ENOT:       "E0=" FLOAT {
               print(join("~", @item), $/) if $Xray::XDI::XDAC::debug;
               $Xray::XDI::object->edge_energy($item[2]);
            }

REGIONS:    "NUM_REGIONS=" INTEGER {
             print(join("~", @item), $/) if $Xray::XDI::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC-NUM_REGIONS" . ': '. $item[2]);
            }

SRB:        "SRB=" EORK(s) {
             print(join("~", @item), $/) if $Xray::XDI::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC-SRB" . ': '. join(" ", @{$item[2]}));
            }

SRSS:       "SRSS=" EORK(s) {
             print(join("~", @item), $/) if $Xray::XDI::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC-SRSS" . ': '. join(" ", @{$item[2]}));
            }

SPP:        "SPP=" EORK(s) {
             print(join("~", @item), $/) if $Xray::XDI::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC-SPP" . ': '. join(" ", @{$item[2]}));
            }

SETTLE:     "Settling time=" FLOAT {
             print(join("~", @item), $/) if $Xray::XDI::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC-Settling_time" . ': '. join(" ", $item[2]));
            }

OFFSETS:    "Offsets=" FLOAT(s) {
             print(join("~", @item), $/) if $Xray::XDI::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC-Offsets" . ': '. join(" ", @{$item[2]}));
            }

GAINS:      "Gains=" FLOAT(s) {
             print(join("~", @item), $/) if $Xray::XDI::XDAC::debug;
             $Xray::XDI::object->push_extension("XDAC-Gains" . ': '. join(" ", @{$item[2]}));
            }

COMMLINE:   ANY(s) {
             print("comment: ", join("~", @item), $/) if $Xray::XDI::XDAC::debug;
             $Xray::XDI::object->push_comment(join(" ", @{$item[1]}));
            }

HEADER: ( VERSION | FILE | CRYSTAL | ENOT | 
          REGIONS | SRB | SRSS | SPP | SETTLE | OFFSETS | GAINS |
          COMMLINE ) EOL
COMMENTS:  HEADER(s) HEADER_END


LABEL:    ANY
LABELS:   LABEL(s) EOL {
             print(join("~", @item), $/) if $Xray::XDI::XDAC::debug;
             $Xray::XDI::object->push_label(@{$item[1]});
            }

DATA_LINE: FLOAT(s) EOL {
             print(join("~", @item), $/) if $Xray::XDI::XDAC::debug;
             $Xray::XDI::object->add_data_point(@{$item[1]})  if $#{$item[1]}>-1;
             #print join("~", "DATA_LINE", @{$item[2]}), $/;
            }
DATA:      DATA_LINE(s?)

_EOGRAMMAR_
}


1;
