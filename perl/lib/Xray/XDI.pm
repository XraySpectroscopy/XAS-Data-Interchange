package Xray::XDI;

use Moose;
use MooseX::NonMoose;
extends 'Xray::XDIFile';

use List::MoreUtils qw(uniq);

our $VERSION = '0.01';

has 'file' => (is => 'rw', isa => 'Str', default => q{},
	      trigger => sub{$_[0]->_build_object; });

has 'xdifile' => (
		  is        => 'ro',
		  isa       => 'Xray::XDIFile',
		  init_arg  => undef,
		  lazy      => 1,
		  builder   => '_build_object',
		 );
has 'ok'            => (is => 'rw', isa => 'Bool', default => 1);
has 'error'         => (is => 'rw', isa => 'Str', default => q{});

has 'filename'      => (is => 'rw', isa => 'Str', default => q{});
has 'xdi_version'   => (is => 'rw', isa => 'Str', default => q{});
has 'extra_version' => (is => 'rw', isa => 'Str', default => q{});
has 'element'       => (is => 'rw', isa => 'Str', default => q{});
has 'edge'          => (is => 'rw', isa => 'Str', default => q{});
has 'comments'      => (is => 'rw', isa => 'Str', default => q{});
has 'nmetadata'     => (is => 'rw', isa => 'Int', default => 0);
has 'npts'          => (is => 'rw', isa => 'Int', default => 0);
has 'narrays'       => (is => 'rw', isa => 'Int', default => 0);

has 'array_labels'  => (is => 'rw', isa => 'ArrayRef', default => sub{[]});

has 'metadata'      => (
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
  if (not -e $self->file) {
    $self->error('The file '.$self->file.' does not exist');
    $self->ok(0);
    return undef;
  };
  if (not -r $self->file) {
    $self->error('The file '.$self->file.' cannot be read');
    $self->ok(0);
    return undef;
  };
  if (-d $self->file) {
    $self->error($self->file.' is a folder');
    $self->ok(0);
    return undef;
  };
  my $obj = Xray::XDIFile->new($self->file);
  if (not defined $obj->_filename) {
    $self->error('foo');
    return $obj;
  };
  $self->filename($obj->_filename);
  $self->xdi_version($obj->_xdi_version);
  $self->extra_version($obj->_extra_version);
  $self->element($obj->_element);
  $self->edge($obj->_edge);
  $self->comments($obj->_comments);
  $self->nmetadata($obj->_nmetadata);
  $self->npts($obj->_npts);
  $self->narrays($obj->_narrays);

  ## import the metadata as a hash of hashes
  my @families = $obj->_meta_families;
  my @keywords = $obj->_meta_keywords;
  my @values   = $obj->_meta_values;
  my %hash = ();
  foreach my $i (0 .. $self->nmetadata-1) {
    $hash{$families[$i]}{$keywords[$i]} = $values[$i];
  };
  $self->metadata(\%hash);

  ## import the data as a hash of lists
  my @array_labels = $obj->_array_labels;
  $self->array_labels(\@array_labels);

  my %data = ();
  foreach my $i (0 .. $#array_labels) {
    my @x = $obj->_data_array($i);
    $data{$array_labels[$i]} = \@x;
  };
  $self->data(\%data);


  return $obj;
};


## Methods for data and metadata

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


no Moose;
# no need to fiddle with inline_constructor here
__PACKAGE__->meta->make_immutable;
1;


=head1 NAME

Xray::XDI - Import/export of XAS Data Interchange files

=head1 VERSION

=head1 SYNOPSIS

Import an XDI file:

use Xray::XDI;
my $xdi = Xray::XDI->new(xdi_version=>"1.0");
$xdi -> file('data.dat');
$xdi -> parse;

If the input data file is an XDI file, the grammar version will be
taken from the first line.

Export an XDI file:

$xdi -> export("outfile.dat");

=head1 ATTRIBUTES

=over 4

=item C<file>

The fully resolved path to the XDI file.  Setting this triggers the
importing of the file and the setting of all other attributes from the
contents of the file.

=item C<xdifile>

The underlying L<Xray::XDIFile> object.

=item C<xdi_version>

The XDI specification version under which the file was written.

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

=item *

Blah blah

=back

Please report problems to Bruce Ravel (bravel AT bnl DOT gov)

Patches are welcome.

=head1 AUTHOR

Bruce Ravel (bravel AT bnl DOT gov)

L<http://cars9.uchicago.edu/~ravel/software/>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012 Bruce Ravel (bravel AT bnl DOT gov). All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlgpl>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut
