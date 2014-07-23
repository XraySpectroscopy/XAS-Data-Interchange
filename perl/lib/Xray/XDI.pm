package Xray::XDI;

use Moose;
use MooseX::NonMoose;
extends 'Xray::XDIFile';
with 'Xray::XDI::WriterPP';

use List::MoreUtils qw(any uniq);

our $VERSION = 1.0;

has 'file' => (is => 'rw', isa => 'Str', default => q{},
	       trigger => sub{$_[0]->_build_object});

has 'xdifile' => (
		  is        => 'ro',
		  isa       => 'Xray::XDIFile',
		  init_arg  => undef,
		  lazy      => 1,
		  builder   => '_build_object',
		 );
# no need to fiddle with inline_constructor here
has 'ok'             => (is => 'rw', isa => 'Bool', default => 0);
has 'warning'        => (is => 'rw', isa => 'Bool', default => 0);
has 'errorcode'      => (is => 'rw', isa => 'Int',  default => 0);
has 'error'          => (is => 'rw', isa => 'Str',  default => q{});

has 'filename'       => (is => 'rw', isa => 'Str', default => q{});
has 'xdi_libversion' => (is => 'rw', isa => 'Str', default => q{});
has 'xdi_version'    => (is => 'rw', isa => 'Str', default => q{});
has 'extra_version'  => (is => 'rw', isa => 'Str', default => q{});
has 'element'        => (is => 'rw', isa => 'Str', default => q{});
has 'edge'           => (is => 'rw', isa => 'Str', default => q{});
has 'dspacing'       => (is => 'rw', isa => 'Num', default => 0);
has 'comments'       => (is => 'rw', isa => 'Str', default => q{});
has 'nmetadata'      => (is => 'rw', isa => 'Int', default => 0);
has 'npts'           => (is => 'rw', isa => 'Int', default => 0);
has 'narrays'        => (is => 'rw', isa => 'Int', default => 0);
has 'narray_labels'  => (is => 'rw', isa => 'Int', default => 0);

has 'array_labels'   => (is => 'rw', isa => 'ArrayRef', default => sub{[]});
has 'array_units'    => (is => 'rw', isa => 'ArrayRef', default => sub{[]});

has 'metadata'       => (
			 traits    => ['Hash'],
			 is        => 'rw',
			 isa       => 'HashRef',
			 default   => sub { {} },
			 handles   => {
				       'exists_in_metadata' => 'exists',
				       'ids_in_metadata'    => 'keys',
				       'get_metadata'       => 'get',
				       'set_metadata'       => 'set',
				      },
			);

has 'data'      => (
		    traits    => ['Hash'],
		    is        => 'rw',
		    isa       => 'HashRef',
		    default   => sub { {} },
		    handles   => {
				  'exists_in_data' => 'exists',
				  'ids_in_data'    => 'keys',
				  'get_data'       => 'get',
				  'set_data'       => 'set',
				 },
		   );

sub _build_object {
  my ($self) = @_;
  $self->error(q{});
  $self->ok(1);
  $self->warning(0);
  if (not -e $self->file) {
    $self->error('The file '.$self->file.' does not exist as XDI');
    $self->ok(0);
    return undef;
  };
  if (not -r $self->file) {
    $self->error('The file '.$self->file.' cannot be read as XDI');
    $self->ok(0);
    return undef;
  };
  if (-d $self->file) {
    $self->error($self->file.' is a folder (i.e. not an XDI file)');
    $self->ok(0);
    return undef;
  };
  my $errcode = 0;
  my $obj = Xray::XDIFile->new($self->file, $errcode);
  $self->errorcode($errcode);

  #print $self->file, $/;
  #$self->trace;
  #print '>>>>>', $errcode, $/;

  ##### see xdifile.h for error codes
  ##### see xdifile.c (line 23 and following) for error messages
  if ($errcode < 0) {
    my @errors = ();
    foreach my $i (0 .. 10) {
      push @errors, $obj->_errorstring(-1*2**$i) if (abs($errcode) & 2**$i);
    };
    $self->error(join(", ", @errors));
    $self->ok(0);
    return $obj;
  };
  if ($errcode > 0) {
    my @errors = ();
    foreach my $i (0 .. 4) {
      push @errors, $obj->_errorstring(2**$i) if ($errcode & 2**$i);
    };
    $self->error(join(", ", @errors));
    $self->ok(1);
    $self->warning(1);
  };

  if (not defined $obj->_filename) {
    $self->error('unknown problem reading '.$self->file.' as an XDI file');
    $self->ok(0);
    return $obj;
  };

  $self->filename($obj->_filename);
  $self->xdi_libversion($obj->_xdi_libversion||q{});
  $self->xdi_version($obj->_xdi_version||q{});
  $self->extra_version($obj->_extra_version || q{});
  $self->element($obj->_element || q{});
  $self->edge($obj->_edge || q{});
  $self->dspacing($obj->_dspacing || 0);
  $self->comments($obj->_comments || q{});
  $self->nmetadata($obj->_nmetadata);
  $self->npts($obj->_npts);
  $self->narrays($obj->_narrays);
  $self->narray_labels($obj->_narray_labels);

  ## store the metadata as a hash of hashes
  my @families = $obj->_meta_families;
  my @keywords = $obj->_meta_keywords;
  my @values   = $obj->_meta_values;
  my %hash = ();
  foreach my $i (0 .. $self->nmetadata-1) {
    $hash{$families[$i]}{$keywords[$i]} = $values[$i];
  };
  $self->metadata(\%hash);

  ## store the data as a hash of lists
  my @array_labels = $obj->_array_labels;
  $self->array_labels(\@array_labels);
  my @array_units = $obj->_array_units;
  $self->array_units(\@array_units);

  my %data = ();
  foreach my $i (0 .. $self->narray_labels-1) {
    my @x = $obj->_data_array($i);
    #print $array_labels[$i], $/;
    #print join("|", @x), $/, $/;
    $data{$array_labels[$i]} = \@x;
  };
  $self->data(\%data);

  return $obj;
};

# use Term::ANSIColor qw(:constants);
# sub trace {
#   my ($self) = @_;
#   my $max_depth = 30;
#   my $i = 0;
#   my ($green, $red, $yellow, $end) = (BOLD.GREEN, BOLD.RED, BOLD.YELLOW, RESET);
#   local $|=1;
#   print($/.BOLD."--- Begin stack trace ---$end\n");
#   while ( (my @call_details = (caller($i++))) && ($i<$max_depth) ) {
#     my $from = $call_details[1];
#     my $line  = $call_details[2];
#     my $color = RESET.YELLOW;
#     (my $func = $call_details[3]) =~ s{(?<=::)(\w+)\z}{$color$1};
#     print("$green$from$end line $red$line$end in function $yellow$func$end\n");
#   }
#   print(BOLD."--- End stack trace ---$end\n");
#   return $self;
# };



## Methods for data and metadata

sub valid_edges {
  my ($self) = @_;
  return $self->xdifile->_valid_edges;
};
sub valid_elements {
  my ($self) = @_;
  return $self->xdifile->_valid_elements;
};

sub labels {
  my ($self) = @_;
  return @{$self->array_labels};
};
sub families {
  my ($self) = @_;
  return sort(keys(%{$self->metadata}));
};
sub keywords {
  my ($self, $family) = @_;
  my $f = ucfirst(lc($family));
  my $hash = $self->metadata->{$f};
  return () if not $hash;
  return sort(keys(%$hash));
};

sub get_item {
  my ($self, $family, $keyword) = @_;
  return q{} if not $self->metadata->{$family};
  return q{} if not $self->metadata->{$family}->{$keyword};
  return $self->metadata->{$family}->{$keyword};
};

sub set {
  my ($self, $family, $keyword, $value) = @_;
  return q{} if not $self->metadata->{$family};
  return q{} if not $self->metadata->{$family}->{$keyword};
  my $rhash = $self->metadata;
  $rhash->{$family}->{$keyword} = $value;
  $self->metadata($rhash);
  return $self;
};

sub get_array {
  my ($self, $label) = @_;
  my $i = 0;
  foreach my $lab ($self->array_labels) {
    last if (lc($label) eq lc($lab));
    ++$i;
  };
  return () if not $self->data->{$label};
  return @{$self->data->{$label}};
};
sub get_iarray {
  my ($self, $i) = @_;
  return () if ($i > $self->narrays);
  return () if ($i < 1);
  return @{$self->data->{$self->array_labels->[$i-1]}};
};

sub token {
  my ($self, $tok) = @_;
  return $self->xdifile->_token($tok);
};


no Moose;
__PACKAGE__->meta->make_immutable;
1;


=head1 NAME

Xray::XDI - Import/export of XAS Data Interchange files

=head1 VERSION

0.01

=head1 SYNOPSIS

Import an XDI file:

  use Xray::XDI;
  my $xdi = Xray::XDI->new(file=>'data.dat');
  if ($xdi->ok) {
    # do stuff
  } else {
    print "Uh oh! ", $xdi->error, $/;
  };

Export an XDI file:

  $xdi -> export("outfile.dat");

=head1 ATTRIBUTES

=over 4

=item C<file>

The fully resolved path to the XDI file.  Setting this triggers the
importing of the file and the setting of all other attributes from the
contents of the file.

=item C<ok>

This is true when C<file> is properly imported.  When false, the
problem will be recorded in the C<error> attribute.

=item C<error>

When an XDI file is imported properly, this is an empty string.  When
import runs into a problem, the explanation will be stroed here as a
string.

=item C<xdifile>

The underlying L<Xray::XDIFile> object.

=item C<xdi_version>

The XDI specification version under which the file was written.

=item C<xdi_version>

The XDI specification against which L<Xray::XDIFile> was compiled.

=item C<extra_version>

All additional versioning information contained within the XDI file.

=item C<element>

The element of the absorber.

=item C<edge>

The absorption edge at which the data were measured.

=item C<comments>

The user supplied comments with all white space and carriage returns
preserved.

=item C<nmetadata>

The number of metadata items defined in the XDI file.

=item C<npts>

The number of data points in the XDI file.

=item C<narrays>

The number of arrays contained in the data table of the XDI file.

=item C<array_labels>

A reference to the list of column labels in the order of appearence in
the XDI file.

=item C<metadata>

A reference to a hash of hashes containing the metadata from the XDI
file.  The top level of the hash is the family name, the second level
is the keyword.

This module handles the mapping of this hash of hashes to and from the
underlying arrays exposed by L<Xray::XDIFile>.

=item C<data>

The data table from the XDI file as a reference to a hash of arrays.
The hash keys are the column labels.  The value associated with each
hash key is a reference to the array from that column of the data
table.

=back

=head1 METHODS

=over 4

=item C<new>

Create the Xray::XDI object.

  my $xdi = Xray::XDI->new(file=>'/path/to/file');

Alternately,

  my $xdi = Xray::XDI->new();
  ## later....
  $xdi -> file('/path/to/file');

=item C<labels>

Return a list of column labels in the order of appearance in the XDI
file.

  my @list = $xdi->labels;

=item C<families>

Return an alphabetically sorted list of metadata families found in the
XDI file.

  my @list = $xdi->families;

=item C<families>

Return an alphabetically sorted list of metadata keywords for a given
family found in the XDI file.

  my @list = $xdi->keywords('Beamline');

This returns an empty list if the famliy name is not present in the
XDI file.

=item C<get_item>

Return a single metadata item, specified by family and keyword

  my $value = $xdi->get_item('Mono', 'name');

This returns an empty string if the metadata item identified by the
family/keyword pair is not present in the XDI file.

=item C<get_array>

Return a single data array, specified by column label

  my @e = $xdi->get_array('energy');

This returns an empty list if the column label is not present in the
XDI file.

=item C<get_iarray>

Return a single data array, specified by column number in the order
found in the XDI file

  my @e = $xdi->get_array(1);

Note that the counting starts at 1.  That is, the left-most column is
column number 1.

This returns an empty list if the column number is not present in the
XDI file.

=item C<valid_edges>

Returns a list of edge symbols known to C<libxdifile>.

=item C<valid_elements>

Returns a list of element symbols known to C<libxdifile>.

=item C<token>

Return the named token as defined for F<libxdifile>.  Token names are

=over 4

=item I<comment> [C<#>]

=item I<delimiter> [C<:>]

=item I<dot> [C<.>]

=item I<startcomment> [C<///>]

=item I<endcomment> [C<--->]

=item I<energycolumn> [C<energy>]

=item I<anglecolumn> [C<angle>]

=item I<version> [C<XDI/>]

=item I<edge> [C<element.edge>]

=item I<element> [C<element.symbol>]

=item I<column> [C<column.>]

=item I<dspacing> [C<mono.dspacing>]

=back

The actual values of the tokens at the time of this writing are given
in brackets.

=back

=head1 VALIDATION

If the sole intent is to validate an XDI file, i.e. to determine
whether or not it conforms to the specification, it should be adequate
to do something like the following:

  $xdi = Xray::XDI->new('somefile.dat');
  $is_valid = $xdi->ok;
  $problem = $xdi->error if not $is_valid;
  undef $xdi;
  print "okee dokee!\n" if $is_valid;

=head1 DIAGNOSTICS

=over 4

=item *

Blah blah


=back

=head1 DEPENDENCIES

=over 4

=item *

L<Inline>

=item *

L<Moose>, L<MooseX::NonMoose>

=back

=head1 BUGS AND LIMITATIONS

=over 4

=item *

need an add data column method

=item *

need a remove data column method

=item *

need a remove metadatum method

=back

Please report problems to Bruce Ravel (bravel AT bnl DOT gov)

Patches are welcome.

=head1 AUTHOR

Bruce Ravel (bravel AT bnl DOT gov)

L<http://cars9.uchicago.edu/~ravel/software/>

=head1 LICENCE AND COPYRIGHT

To the extent possible, the authors have waived all rights granted by
copyright law and related laws for the code and documentation that
make up the Perl Interface to the XAS Data Interchange Format.
While information about Authorship may be retained in some files for
historical reasons, this work is hereby placed in the Public Domain.
This work is published from: United States.

Author: Bruce Ravel (bravel AT bnl DOT gov).
Last update: 22 July, 2014

=cut
