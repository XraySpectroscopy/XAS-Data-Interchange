#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 90;

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
  my $command = "valgrind --track-origins=yes --leak-check=full --show-leak-kinds=all ./xdi_reader ../data/$file 2>&1";
  my $x = `$command`;
  ok(($x =~ m{All heap blocks were freed}), $file);
  ok((not $?), "$file return value is 0");
};


## see baddata/BadFile.txt for explanations of return values
my %return = ('00' => 0, '01' => 1, '02' => 0, '03' => 0, '04' => 0, '05' => 0,
	      '06' => 0, '07' => 0, '08' => 0, '09' => 0, '10' => 0, '11' => 0,
	      '12' => 0, '13' => 1, '14' => 1, '15' => 1, '16' => 1, '17' => 1,
	      '18' => 1, '19' => 1, '20' => 1, '21' => 1, '22' => 1, '23' => 0,
	      '24' => 1, '25' => 0, '26' => 0, '27' => 0, '28' => 1, '29' => 1, );

## bad data
foreach my $i (0 .. 29) {
  my $n = sprintf("%2.2d", $i);
  my $command = "valgrind --track-origins=yes --leak-check=full --show-leak-kinds=all ./xdi_reader ../baddata/bad_$n.xdi 2>&1";
  my $x = `$command`;
  ok(($x =~ m{All heap blocks were freed}), "bad_$n.xdi");
  ok((not ($? xor $return{$n})), "bad_$n.xdi return value is $?");
};



