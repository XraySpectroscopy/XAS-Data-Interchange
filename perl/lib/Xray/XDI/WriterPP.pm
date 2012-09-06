package Xray::XDI::WriterPP;

use Moose::Role;

sub export {
  my ($self, $filename) = @_;
  open(my $OUT, '>', $filename) or die "could not write an XDI file to $filename";
  print $OUT $self->export_text;
  close $OUT;
  return $self;
};

sub export_text {
  my ($self) = @_;
  my $text = $self->section_version;
  $text   .= $self->section_columns;
  $text   .= $self->section_metadata;
  $text   .= $self->section_comments;
  $text   .= $self->section_labels;
  $text   .= $self->section_data;
  return $text;
};

sub section_version {
  my ($self) = @_;
  return $self->token('comment') . ' ' .
         $self->token('version') . $self->xdi_libversion . ' ' .
         $self->extra_version . $/;
};

sub section_columns {
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

sub section_metadata {
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

sub section_comments {
  my ($self) = @_;
  my $text   = q{};
  $text .= $self->token('comment') . $self->token('startcomment') x 20 . $/;
  foreach my $cl (split(/\n/, $self->comments)) {
    $text .= $self->token('comment') . $cl . $/;
  };
  $text .= $self->token('comment') . $self->token('endcomment') x 20 . $/;
  return $text;
};


sub section_labels {
  my ($self) = @_;
  my $text   = q{};
  $text .= $self->token('comment');
  foreach my $lab ($self->labels) {
    $text .= ' ' . $lab;
  };
  $text .= $/;
  return $text;
};

sub section_data {
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

=head1 BUGS AND LIMITATIONS

=over 4

=item *

Need an algorithm for determining column formatting in
C<section_data>.

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
