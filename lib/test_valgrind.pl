#!/usr/bin/perl

BEGIN {
  eval "use File::Which;";
  if ($@) {
    print "
This test script requires the perl module File::Which.
See https://metacpan.org/pod/File::Which or
install from the command line with 'cpanp i File::Which'

";
    exit;
  };
};

use strict;
use warnings;
use File::Which qw(which);
use Term::ANSIColor;
use Test::More tests => 205;

my $found = which('valgrind');
if (not defined($found)) {
  die "\nValgrind is required for these tests, but seems not to be installed on your computer.\n\n";
};
ok($found,                                    "valgrind is in the execution path");

my ($valgrind, $command, $x, $n);
my %valgrind = (leaks  => "valgrind --track-origins=yes --leak-check=full --show-leak-kinds=all",
		bounds => "valgrind --tool=exp-sgcheck", );
my @good_data = (qw(co_metal_rt.xdi  cu_metal_10K.xdi cu_metal_rt.xdi
		    fe2o3_rt.xdi     fe3c_rt.xdi      fe_metal_rt.xdi
		    fen_rt.xdi       feo_rt1.xdi      ni_metal_rt.xdi
		    nonxafs_1d.xdi   nonxafs_2d.xdi   pt_metal_rt.xdi
		    se_na2so4_rt.xdi se_znse_rt.xdi   zn_znse_rt.xdi ));

## good data
message('leaks', 'good');
foreach my $file (@good_data) {
  $command = $valgrind{leaks} . " ./xdi_reader ../data/$file 2>&1";
  $x = `$command`;
  ok(($x =~ m{All heap blocks were freed}),   "all blocks freed: $file");
  ok(($x =~ m{0 errors}),                     "no errors: $file");
  ok((not $?),                                "$file return value is 0");
};

message('bounds', 'good');
foreach my $file (@good_data) {
  $command = $valgrind{bounds} . " ./xdi_reader ../data/$file 2>&1";
  $x = `$command`;
  ok(($x =~ m{0 errors}),                     "no errors: $file");
};

## see baddata/BadFile.txt for explanations of return values
my %return = ('00' => 0, '01' => 1, '02' => 0, '03' => 0, '04' => 0, '05' => 0,
	      '06' => 0, '07' => 0, '08' => 0, '09' => 0, '10' => 0, '11' => 0,
	      '12' => 0, '13' => 1, '14' => 1, '15' => 1, '16' => 1, '17' => 1,
	      '18' => 1, '19' => 1, '20' => 1, '21' => 1, '22' => 1, '23' => 0,
	      '24' => 1, '25' => 0, '26' => 0, '27' => 0, '28' => 0, '29' => 0,
	      '30' => 0, '31' => 0, '32' => 0, '33' => 0, '34' => 0, '35' => 0);

## bad data
message('leaks', 'bad');
foreach my $i (0 .. 35) {
  $n = sprintf("%2.2d", $i);
  $command = $valgrind{leaks} . " ./xdi_reader ../baddata/bad_$n.xdi 2>&1";
  $x = `$command`;
  ok(($x =~ m{All heap blocks were freed}),   "all blocks freed: bad_$n.xdi");
  ok(($x =~ m{0 errors}),                     "no errors: bad_$n.xdi");
  ok((not ($? xor $return{$n})),              "bad_$n.xdi return value is $?");
};

message('bounds', 'bad');
foreach my $i (0 .. 35) {
  $n = sprintf("%2.2d", $i);
  $command = $valgrind{bounds} . " ./xdi_reader ../baddata/bad_$n.xdi 2>&1";
  $x = `$command`;
  ok(($x =~ m{0 errors}),                     "no errors: bad_$n.xdi");
};


## write a helpful message about what set of tests is being performed
sub message {
  my ($test, $data) = @_;
  my %tests = (leaks  => 'Testing for memory leaks',
	       bounds => 'Bounds checking',);
  print colored(['green'], "$tests{$test}, $data data.", "\n");
  print colored(['yellow'], 'Command is: "', $valgrind{$test}, " ./xdi_reader <file>\"\n");
};



