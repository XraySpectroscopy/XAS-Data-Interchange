package Xray::XDI::WriterPP;

use Moose::Role;
use MooseX::Aliases;

sub export {
  my ($self, $filename) = @_;
  open(my $OUT, '>', $filename) or die "could not write an XDI file to $filename";
  print $OUT $self->export_text;
  close $OUT;
  return $self;
};
alias write  => 'export';
alias freeze => 'export';

sub export_text {
  my ($self) = @_;
  my $text = $self->_section_version;
  $text   .= $self->_section_columns;
  $text   .= $self->_section_metadata;
  $text   .= $self->_section_comments;
  $text   .= $self->_section_labels;
  $text   .= $self->_section_data;
  return $text;
};

sub _section_version {
  my ($self) = @_;
  return $self->token('comment') . ' ' .
         $self->token('version') . $self->xdi_libversion . ' ' .
         $self->extra_version . $/;
};

sub _section_columns {
  my ($self) = @_;
  my $text   = q{};
  my $i      = 1;
  foreach my $col ($self->labels) {
    $text .= $self->token('comment') . ' ' .
             ucfirst($self->token('column')) . $i . $self->token('delimiter') . ' ' .
             $col . $/;
    $i++;
  };
  return $text;
};

sub _section_metadata {
  my ($self) = @_;
  my $text   = q{};
  foreach my $fam ($self->families) {
    next if (lc($fam) eq 'column');
    foreach my $key ($self->keywords($fam)) {
      $text .= $self->token('comment') . ' ' .
               ucfirst($fam) . $self->token('dot') . $key . $self->token('delimiter') . ' ' .
               $self->get_item($fam, $key) . $/;
    };
  };
  return $text;
};

sub _section_comments {
  my ($self) = @_;
  my $text   = q{};
  $text .= $self->token('comment') . $self->token('startcomment') x 20 . $/;
  foreach my $cl (split(/\n/, $self->comments)) {
    $text .= $self->token('comment') . $cl . $/;
  };
  $text .= $self->token('comment') . $self->token('endcomment') x 20 . $/;
  return $text;
};


sub _section_labels {
  my ($self) = @_;
  my $text   = q{};
  $text .= $self->token('comment');
  foreach my $lab ($self->labels) {
    $text .= ' ' . $lab;
  };
  $text .= $/;
  return $text;
};

sub _section_data {
  my ($self) = @_;
  my $text   = q{};
  foreach my $i (0 .. $self->npts-1) {
    foreach my $col ($self->labels) {
      $text .= sprintf("  %-14s", $self->data->{$col}->[$i]);
    };
    $text .= $/;
  };
  return $text;
};

1;

=head1 NAME

Xray::XDI - A pure perl XAS Data Interchange exporter

=head1 VERSION

0.01

=head1 SYNOPSIS

Export an XDI file:

  $xdi -> export("outfile.dat");

C<write> and C<freeze> are aliases for C<export> and may be used
interchangeably.

=head1 DEPENDENCIES

=over 4

=item *

L<Moose>, L<MooseX::Aliases>

=back

=head1 BUGS AND LIMITATIONS

=over 4

=item *

Need an algorithm for determining column formatting in
C<_section_data>.  Need to preserve resolution.

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
Last update: 8 September, 2012

=cut
