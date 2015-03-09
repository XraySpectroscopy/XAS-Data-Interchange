#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 45;

## good data
foreach my $file (qw(co_metal_rt.xdi
		     cu_metal_10K.xdi
		     cu_metal_rt.xdi
		     fe2o3_rt.xdi
		     fe3c_rt.xdi
		     fe_metal_rt.xdi
		     fen_rt.xdi
		     feo_rt1.xdi
		     ni_metal_rt.xdi
		     nonxafs_1d.xdi
		     nonxafs_2d.xdi
		     pt_metal_rt.xdi
		     se_na2so4_rt.xdi
		     se_znse_rt.xdi
		     zn_znse_rt.xdi
		   )) {
  my $command = "valgrind --track-origins=yes --leak-check=full --show-leak-kinds=all ./xdi_reader ../baddata/$file 2>&1";
  my $x = `$command`;
  ok(($x =~ m{All heap blocks were freed}), $file);
};

## bad data
foreach my $i (0 .. 29) {
  my $n = sprintf("%2.2d", $i);
  my $command = "valgrind --track-origins=yes --leak-check=full --show-leak-kinds=all ./xdi_reader ../baddata/bad_$n.xdi 2>&1";
  my $x = `$command`;
  ok(($x =~ m{All heap blocks were freed}), "bad_$n.xdi");
};



