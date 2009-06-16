use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Net::Pixiv',
    license             => 'perl',
    dist_author         => 'Kuzuha SHINODA <kuzuha01@hotmail.com>',
    dist_version_from   => 'lib/Net/Pixiv.pm',
    requires => {
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
    add_to_cleanup      => [ 'Net-Pixiv-*' ],
);

$builder->create_build_script();
