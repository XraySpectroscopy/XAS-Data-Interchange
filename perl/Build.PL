#!/usr/bin/perl

use strict;
use warnings;
use Module::Build;

my $build = Module::Build
 -> new(
	create_readme      => 0,
	##create_makefile_pl => 'traditional',
	license            => 'perl',
	module_name        => 'Xray::XDI',
	dist_author        => 'Bruce Ravel',
	requires           => {
			       'Moose'             => 1.21,
			       'Parse::RecDescent' => 1.965001,
			      },
	recommends         => {},
	sign               => 0,
);
$build->create_build_script;
