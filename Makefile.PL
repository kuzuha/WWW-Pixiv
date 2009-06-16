use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WWW::Pixiv',
    AUTHOR              => 'Kuzuha SHINODA <kuzuha01@hotmail.com>',
    VERSION_FROM        => 'lib/WWW/Pixiv.pm',
    ABSTRACT_FROM       => 'lib/WWW/Pixiv.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'            => 0,
        'Test::Pod::Coverage'   => 0,
        'Test::Perl::Critic'    => 0,
        'version'               => 0,
        'Any::Moose'            => 0,
        'WWW::Mechanize'        => 0,
        'Web::Scraper'          => 0,
        'Config::Pit'           => 0,
        'HTTP::Response'        => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WWW-Pixiv-*' },
);
