#!/usr/bin/perl

use strict;
use warnings;
use Module::Build;

my $build = Module::Build
 -> new(
	module_name        => 'Xray::XDI',
	license            => 'perl',
	dist_author        => 'Bruce Ravel <bravel AT bnl DOT gov>',
	dist_abstract      => "perl implementation of the XDI specification",
	requires           => {
			       'Moose'             => 1.21,
			       'Parse::RecDescent' => 1.965001,
			      },
	recommends         => {},
	sign               => 0,
);
$build->create_build_script;
