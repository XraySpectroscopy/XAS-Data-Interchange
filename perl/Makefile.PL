use 5.014002;
use Inline::MakeMaker;

WriteMakefile(
	      NAME              => 'Xray::XDI',
	      VERSION_FROM      => 'lib/Xray/XDI.pm', # finds $VERSION
	      PREREQ_PM         => {
				    Inline           => 0.5,
				    Moose            => 2.06,
				    'MooseX::NonMoose' => 0.22,
				   },
	      ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
	       (ABSTRACT_FROM  => 'lib/Xray/XDI.pm', # retrieve abstract from module
		AUTHOR         => 'Bruce Ravel <bravel@bnl.gov>') : ()),
	      CONFIGURE_REQUIRES  =>  {
				       'Inline::MakeMaker'     => 0.45,
				       'ExtUtils::MakeMaker'   => 6.52,
				      },
	      'test' => {
			 'TESTS' => 't/*.t t/gooddata/*.t t/baddata/*.t'
			},
);
