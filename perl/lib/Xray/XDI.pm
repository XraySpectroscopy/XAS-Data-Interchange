package Xray::XDI;

use autodie qw(open close);
use Carp;
use version;

use Moose;
use Moose::Util qw(apply_all_roles);
use MooseX::AttributeHelpers;
use Parse::RecDescent;
use Scalar::Util qw(looks_like_number);

use vars qw($object $VERSION);
$VERSION  = version->new("1.0");
$object = q{};

has 'is_xdi'       => (is => 'rw', isa => 'Bool', default => 0,);

has 'file'	   => (is => 'rw', isa => 'Str', default => q{},
		       trigger => sub{my ($self, $new) = @_; $self->parse;});
has 'out'	   => (is => 'rw', isa => 'Str', default => q{});
has 'xdi_version'  => (is => 'rw', isa => 'Str', default => sub{sprintf "%s", $VERSION},
		       trigger => sub{my ($self, $new) = @_; $self->get_grammar });
has 'grammar'      => (is => 'rw', isa => 'Str', default => q{});

has 'extensions'   => (metaclass => 'Collection::Array',
		       is => 'rw', isa => 'ArrayRef[Str]',
		       default => sub{[]},
		       provides  => {
                                     'push'  => 'push_extension',
                                     'pop'   => 'pop_extension',
                                     'clear' => 'clear_extensions',
				    },
		      );

has 'comments'     => (
                       metaclass => 'Collection::Array',
                       is        => 'rw',
                       isa       => 'ArrayRef',
                       default   => sub { [] },
                       provides  => {
                                     'push'  => 'push_comment',
                                     'pop'   => 'pop_comment',
                                     'clear' => 'clear_comments',
                                    }
                      );
has 'labels'     => (
                       metaclass => 'Collection::Array',
                       is        => 'rw',
                       isa       => 'ArrayRef',
                       default   => sub { [] },
                       provides  => {
                                     'push'  => 'push_label',
                                     'pop'   => 'pop_label',
                                     'clear' => 'clear_labels',
                                    }
                      );
has 'data'     => (
		   metaclass => 'Collection::Array',
		   is        => 'rw',
		   isa       => 'ArrayRef[ArrayRef]',
		   default   => sub { [] },
		   provides  => {
				 'push'  => 'push_data',
				 'pop'   => 'pop_data',
				 'clear' => 'clear_data',
				}
		  );

sub BUILD {
  my ($self) = @_;
  $self->get_grammar
};

sub get_grammar {
  my ($self) = @_;
  my $version = $self->xdi_version;
  #print $version, $/;
  if (looks_like_number($version)) {
    $version =~ s{\.}{_}g;
    eval {apply_all_roles($self, 'Xray::XDI::Version'.$version)};
    $@ and croak("Grammar version Xray::XDI::Version$version does not exist");
  } elsif ($version eq 'xdac') {
    eval {apply_all_roles($self, 'Xray::XDI::XDAC')};
    $@ and croak("Grammar version Xray::XDI::XDAC does not exist");
  };
  $self->grammar($self->define_grammar);
  return $self;
};

sub parse {
  my ($self) = @_;
  $self->file        or croak("File has not been specified");
  (-e $self->file)   or croak(sprintf("File %s does not exist", $self->file));
  (-r $self->file)   or croak(sprintf("File %s cannot be read", $self->file));
  $self->clear;
  ## need to peek at the first line to determine version number
  my $data;
  {
    local $/;
    open(my $D, '<', $self->file);
    $data = <$D>;
    close $D;
  };
  if ($data =~ m{\A[\#;][ \t]*XDI/(\d+\.\d+)}) {
    $self->xdi_version($1);
    $self->is_xdi(1);
  } elsif ($data =~ m{\AXDAC}) { # handle known alien grammers
    $self->xdi_version('xdac');
    $self->is_xdi(1);
  } else {
    $self->is_xdi(0);
    return $self;
  };
  $self->xdi_version or croak("Grammar version has not been specified");
  $object = $self;
  my $parser = Parse::RecDescent->new($self->grammar) or croak ("Bad grammar!");
  defined $parser->XDI($data) or croak ("Not XDI data!");

  ## restore the proper number if the version is an alien
  $self->xdi_version("$Xray::XDI::VERSION") if $self->xdi_version eq 'xdac';
  return $self;
};

sub clear {
  my ($self) = @_;
  foreach my $p (@{$self->order}) {
    $self->$p(q{});
  };
  $self->grammar(q{});
  $self->clear_extensions;
  $self->clear_comments;
  $self->clear_labels;
  $self->clear_data;
  return $self;
};

sub add_data_point {
  my ($self, @data) = @_;
  $self->push_data([@data]);
  return $self;
};

sub add_data_arrays {
  my ($self, @arrays) = @_;
  ## check that the arrays are of the same length
  ## transpose the list of lists to be pointwise rather that arraywise
  return $self;
};

sub export {
  my ($self, $fname) = @_;
  $self->out($fname) if ($fname);
  #(-w $self->out) or croak(sprintf("Cannot write to %s", $self->out));

  open(my $OUT, '>', $self->out);
  # print xdi_version and applications
  print $OUT $self->cc, ' XDI/', $self->xdi_version, ' ', $self->applications, $/;

  # print list of defined fields in the order specified from the role
  foreach my $f (@{$self->order}) {
    next if ($self->$f =~ m{\A\s*\z});
    print $OUT $self->cc, ' ', ucfirst($f), ': ', $self->$f, $/;
  };

  # print extension fields
  foreach my $e (@{$self->extensions}) {
    print $OUT $self->cc, ' ', $e, $/;
  }

  # print field end
  print $OUT $self->fe, $/;

  # print comments
  foreach my $c (@{$self->comments}) {
    print $OUT $self->cc, ' ', $c, $/;
  }

  # print dividing line
  print $OUT $self->he, $/;

  # print labels
  print $OUT $self->cc, '   ';
  foreach my $l (@{$self->labels}) {
    print $OUT $l, $self->rs;
  }
  print $OUT $/;

  # print data
  foreach my $d (@{$self->data}) {
    print $OUT "  ", join($self->rs, @$d), $/;
  };

  close $OUT;
  return $self;
};

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

=head1 GRAMMARS

Grammars are provided a roles.  For example, version 1.0 of the XDI
grammar is provided by L<Xray::XDI::Version1_0>.  The role provides
attributes, one for each defined field in that version of the XDI
grammar.  The role also provides a method called C<define_grammar>
which returns the grammar in the form expected by
L<Parse::RecDescent>.  Attributes called C<order>,
C<comment_character>, and C<dividiing_line> are used to format the
exported file.

=head1 ATTRIBUTES

All attributes for defined fields are provided by the role which
provides the grammar.  This base class provides the following
attributes:

=over 4

=item C<file>

The name of the imported data file.  Parsing the file is triggered
when this attribite is set.

=item C<is_xdi>

This boolean attribute is set to true if C<file> can be parsed as an
XDI file.  To check if a file has been interpreted as an XDI file do
this:

   $xdi->file("my.data");
   if ($xdi->is_xdi) {
     # process accordingly
   } else {
     # do something else
   };

=item C<out>

The name of the exported data file.

=item C<xdi_version>

The version of the grammar to be used to parse the imported file.
Setting this attribute triggers loading the appropariate grammar
version and setting the C<grammar> attribute.

=item C<grammar>

The text of the L<Parse::RecDescent> grammar used to parse the
imported file.

=item C<extensions>

A hash reference containing the collection of extension fields
imported from the input data file.

=item C<comments>

An array reference containing the user-supplied comment lines
imported from the input data file.

=item C<labels>

An array reference containing the column labels imported from the
input data file.

=item C<data>

An array reference containing references of arrays to the data.  The
data are stored pointwise.  That is, each array reference contains a
data point.  The attribute is an array reference of references to data
points.

=back

=head1 METHODS

=over 4

=item C<get_grammar>

(Re)Load the C<grammar> attribute with the grammar version specified
by C<xdi_version>.

=item C<parse>

Import and intepret the data file specified by C<file>.

=item C<add_data_point>

Add a point to the C<data> attribute.  A point is an array reference
containing the abscissa value of the data point followed by values of
all the scalars (i.e. data columns) in the data file.

=item C<add_data_arrays>

Add entire arrays, indexed by the abscissa array, to the C<data>
attribute.  This currently does not work.

=back

=head1 DIAGNOSTICS

=over 4

=item *

Grammar version does not exist (fatal error)

=item *

Input file not specified, does not exist, or cannot be read (fatal
error)

=item *

"Bad grammar", i.e. the grammar is specified incorrectly (fatal error)

=item *

"Not XDI data!", i.e. the input file cannot be interpreted as
XDI-compliant (fatal error)

=back

=head1 DEPENDENCIES

=over 4

=item *

L<Parse::RecDescent>

=item *

L<Moose>, L<MooseX::AttributeHelpers>, L<MooseX::Aliases>

=back

=head1 BUGS AND LIMITATIONS

=over 4

=item *

Add data column by column.

=back

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
