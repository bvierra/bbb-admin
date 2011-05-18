use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WebService::BigBlueButton::API',
    AUTHOR              => q{"Billy Vierra" <"bvierra@cpan.org">},
    VERSION_FROM        => 'lib/WebService/BigBlueButton/API.pm',
    ABSTRACT_FROM       => 'lib/WebService/BigBlueButton/API.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' 		=> 0,
        'Carp'				=> 0,
        'Digest::SHA'		=> 0,
        'LWP::UserAgent'	=> 0,
        'XML::Simple'		=> 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WebService-BigBlueButton-API-*' },
);
