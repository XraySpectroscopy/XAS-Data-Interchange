
BEGIN {
  eval {
    require Inline::MakeMaker;
  };
  if ($@) {
    print "You need to install the 'Inline' perl module before building the XDI perl wrapper.
See https://metacpan.org/release/Inline
or install from a package for your system:
   debian/ubuntu:     libinline-perl
   redhat/mandriva:   perl-Inline
   suse:              perl-Inline
   gentoo:            dev-perl/Inline
";
    exit;
  }
}

import Inline::MakeMaker;

WriteMakefile(
	      NAME              => 'Xray::XDI',
	      VERSION_FROM      => 'lib/Xray/XDI.pm', # finds $VERSION
	      PREREQ_PM         => {
				    Inline             => 0.5,
				    Inline::C          => 0.62,
				    Moose              => 2.06,
				    'MooseX::NonMoose' => 0.22,
				    'MooseX::Aliases'  => 0.10,
				   },
	      ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
	       (ABSTRACT_FROM  => 'lib/Xray/XDI.pm', # retrieve abstract from module
		AUTHOR         => 'Bruce Ravel <bravel@bnl.gov>') : ()),
	      LICENSE          => 'unrestricted',
	      CONFIGURE_REQUIRES  =>  {
				       'Inline::MakeMaker'     => 0.45,
				       'ExtUtils::MakeMaker'   => 6.52,
				      },
	      'test' => {
			 'TESTS' => 't/*.t t/gooddata/*.t t/baddata/*.t t/writer/*.t'
			},
);

# To the extent possible, the authors have waived all rights granted by
# copyright law and related laws for the code and documentation that
# make up the Perl Interface to the XAS Data Interchange Format.
# While information about Authorship may be retained in some files for
# historical reasons, this work is hereby placed in the Public Domain.
# This work is published from: United States.
#
# Author: Bruce Ravel (bravel AT bnl DOT gov).
# Last update: 22 July, 2014
