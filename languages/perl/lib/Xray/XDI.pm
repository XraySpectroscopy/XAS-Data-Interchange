package Xray::XDI;

use Moose;
use MooseX::NonMoose;
use MooseX::Aliases;
extends 'Xray::XDIFile';
with 'Xray::XDI::WriterPP';
with 'MooseX::Clone';

use List::MoreUtils qw(any uniq);

our $VERSION = '1.00'; # Inline::MakeMake uses /^\d.\d\d$/ as the
                       # pattern for the version number -- note the
                       # two digits to the right of the dot

has 'file' => (is => 'rw', isa => 'Str', traits => [qw(Clone)], default => q{},
	       trigger => sub{$_[0]->_build_object});

has 'xdifile' => (
		  is        => 'ro',
		  traits => [qw(NoClone)],
		  #isa       => 'Xray::XDIFile'|'Undef',
		  init_arg  => undef,
		  lazy      => 1,
		  builder   => '_build_object',
		 );
# no need to fiddle with inline_constructor here
has 'errorcode'      => (is => 'rw', isa => 'Int',      traits => [qw(NoClone)], default => 0);
has 'errormessage'   => (is => 'rw', isa => 'Str',      traits => [qw(NoClone)], default => q{});

has 'filename'       => (is => 'rw', isa => 'Str',      traits => [qw(NoClone)], default => q{});
has 'xdi_libversion' => (is => 'rw', isa => 'Str',      traits => [qw(Clone)],   default => q{});
has 'xdi_version'    => (is => 'rw', isa => 'Str',      traits => [qw(Clone)],   default => q{});
has 'extra_version'  => (is => 'rw', isa => 'Str',      traits => [qw(Clone)],   default => q{});
has 'element'        => (is => 'rw', isa => 'Str',      traits => [qw(Clone)],   default => q{});
has 'edge'           => (is => 'rw', isa => 'Str',      traits => [qw(Clone)],   default => q{});
has 'dspacing'       => (is => 'rw', isa => 'Num',      traits => [qw(Clone)],   default => 0);
has 'comments'       => (is => 'rw', isa => 'Str',      traits => [qw(Clone)],   default => q{});
has 'nmetadata'      => (is => 'rw', isa => 'Int',      traits => [qw(Clone)],   default => 0);
has 'npts'           => (is => 'rw', isa => 'Int',      traits => [qw(Clone)],   default => 0);
has 'narrays'        => (is => 'rw', isa => 'Int',      traits => [qw(Clone)],   default => 0);
has 'narray_labels'  => (is => 'rw', isa => 'Int',      traits => [qw(Clone)],   default => 0);

has 'array_labels'   => (is => 'rw', isa => 'ArrayRef', traits => [qw(Clone)],   default => sub{[]});
has 'array_units'    => (is => 'rw', isa => 'ArrayRef', traits => [qw(Clone)],   default => sub{[]});

has 'metadata'       => (
			 traits    => ['Hash', 'Clone'],
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

has 'data'           => (
			 traits    => ['Hash', 'NoClone'],
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

sub DEMOLISH {
  my ($self) = @_;
  return if $self->errorcode;	# is this right?  or does the errorcode need to be passed to _cleanup?
  return if not defined($self->xdifile);
  $self->xdifile->_cleanup(0);
};

sub _build_object {
  my ($self) = @_;
  $self->errormessage(q{});
  if (not $self->file) {
    $self->errorcode(1);
    $self->errormessage('No file specified');
    return undef;
  };
  if (not -e $self->file) {
    $self->errorcode(1);
    $self->errormessage('The file '.$self->file.' does not exist');
    return undef;
  };
  if (not -r $self->file) {
    $self->errorcode(1);
    $self->errormessage('The file '.$self->file.' cannot be read');
    return undef;
  };
  if (-d $self->file) {
    $self->errorcode(1);
    $self->errormessage($self->file.' is a folder (i.e. not an XDI file)');
    return undef;
  };
  my $errcode = 0;
  my $obj = Xray::XDIFile->new($self->file, $errcode);
  $self->errorcode($errcode);
  $self->errormessage($obj->_error_message);

  return $obj if ($errcode < 0);

  if (not defined $obj->_filename) {
    $self->errormessage('unknown problem reading '.$self->file.' as an XDI file');
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
alias namespaces => 'families';

sub keywords {
  my ($self, $family) = @_;
  my $f = ucfirst(lc($family));
  my $hash = $self->metadata->{$f};
  return () if not $hash;
  return sort(keys(%$hash));
};
alias tags => 'keywords';

sub get_item {
  my ($self, $family, $keyword) = @_;
  return q{} if not $self->metadata->{$family};
  return q{} if not $self->metadata->{$family}->{$keyword};
  return $self->metadata->{$family}->{$keyword};
};

sub set_item {
  my ($self, $family, $keyword, $value) = @_;
  #return q{} if not $self->metadata->{$family};
  #return q{} if not $self->metadata->{$family}->{$keyword};
  my $rhash = $self->metadata;
  $rhash->{$family}->{$keyword} = $value;
  $self->metadata($rhash);
  return $self;
};

sub delete_item {
  my ($self, $family, $keyword) = @_;
  my $rhash = $self->metadata;
  delete $rhash->{$family}->{$keyword};
  $self->metadata($rhash);
  return $self;
};

sub push_comment {
  my ($self, @comments) = @_;
  my $all = $self->comments;
  foreach my $comm (@comments) {
    $comm =~ s{[\n\r]+\z}{};
    my $leading_nl = ($all) ? "\n" : q{};
    $all .= $leading_nl . $comm;
  };
  $all =~ s{\A\n}{}s;
  $self->comments($all);
  return $self;
};
alias push_comments => 'push_comment';

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

## methods for validation

sub required {
  my ($self) = @_;
  my $i = $self->xdifile->_required_metadata;
  $self->errorcode($i);
  $self->errormessage($self->xdifile->_error_message);
  return $i;
};
sub required_list {
  my ($self) = @_;
  return Xray::XDIFile->_required_list;
};
sub recommended {
  my ($self) = @_;
  my $i = $self->xdifile->_recommended_metadata;
  $self->errorcode($i);
  $self->errormessage($self->xdifile->_error_message);
  return $i;
};
sub recommended_list {
  my ($self) = @_;
  return Xray::XDIFile->_recommended_list;
};

sub validate {
  my ($self, $family, $name, $value) = @_;
  my $i = $self->xdifile->_validate_item($family, $name, $value);
  $self->errorcode($i);
  $self->errormessage($self->xdifile->_error_message);
  return $i;
};


sub serialize {
  my ($self) = @_;
  my $copy = $self->clone;
  $copy->data({});
  local $Data::Dumper::Indent = 0;
  my $string = $copy->dump(3);
  undef $copy;
  return $string;
};


no Moose;
__PACKAGE__->meta->make_immutable;
1;


=head1 NAME

Xray::XDI - Import/export of XAS Data Interchange files

=head1 VERSION

1.00

=head1 SYNOPSIS

Import an XDI file:

  use Xray::XDI;
  my $xdi = Xray::XDI->new(file=>'data.dat');
  if ($xdi->errorcode == 0) {
    # do stuff
  } else {
    print "Uh oh! ", $xdi->errormessage, $/;
  };

Export an XDI file:

  $xdi -> export("outfile.dat");

=head1 ATTRIBUTES

=over 4

=item C<file>

The fully resolved path to the XDI file.  Setting this triggers the
importing of the file and the setting of all other attributes from the
contents of the file.

=item C<errormessage>

When an XDI file is imported properly, this is an empty string.  When
import or validation runs into a problem, the explanation will be
stroed here as a string.

=item C<errorcode>

The numeric code returned by C<libxdifile> when a problem is
encountered.  The C<errorcode> always corresponds to the
C<errormessage>.

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

=item C<dspacing>

The d-spacing (or line spacing) of the mono used in the measurement.

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

=item C<required>

Test the XDIFile object for whether it contains the metadata items
B<required> by the XDI spec, C<Mono.d_spacing>, C<Element.symbol>, and
C<Element.edge>.

  my $code = $xdi->required;
  print $xdi->error_message, $/ if ($code);

=item C<recommended>

Test the XDIFile object for whether it contains the metadata items
B<recommended> by the XDI spec.

  my $code = $xdi->recommended;
  print $xdi->error_message, $/ if ($code);

=item C<validate>

Validate a sepcific metadata item against its definition in the XDI
dictionary.

  my $code = $xdi->validate($family, $name, $value);
  print $xdi->error_message, $/ if ($code);

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

=iten *

need a validate method that reads, runs required and recommend, and
validates all metadata, returning true if no problems found.

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
