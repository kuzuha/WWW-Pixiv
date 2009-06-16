package Net::Pixiv::Result;
use strict;
use Any::Moose;

has 'mech' => (
	is			=> 'ro',
	isa			=> 'WWW::Mechanize',
	required	=> 1,
);

has 'delay' => (
	is		=> 'ro',
	isa		=> 'Int',
	default	=> 3,
);

has 'tags' => (
	is			=> 'ro',
	isa			=> 'ArrayRef[Str]',
	required	=> 1,
);

has 'size' => (
	is	=> 'ro',
	isa	=> 'Int',
	lazy_build	=> 1,
);

has 'token' => (
	is	=> 'ro',
	isa	=> 'Str',
	lazy_build	=> 1,
);

has 'xpath' =>(
	is			=> 'ro',
	isa			=> 'Web::Scraper',
	lazy_build	=> 1,
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

use version;
our $VERSION = qv('0.0.3');

use Net::Pixiv::Illust;
use URI;
use Web::Scraper;
use URI::Escape;

my $SEARCH_URI = 'http://www.pixiv.net/search.php';
my @res = ();

sub _build_xpath {
	my $xpath_size	= qq|id('content3')/table//tr[2]/td[1]|;
	my $xpath_token	= qq|id('pager')/a[2]|;
	my $xpath_image = qq|id('illust_c5')/ul/li/a[1]/img|;
	
	my $scraper = scraper {
		process $xpath_size,	size		=> 'TEXT',
		process $xpath_token,	token		=> ['@href', sub { $_->as_string }],
		process $xpath_image,	'image[]'	=> ['@src',  sub { $_->as_string }],
	};
	
	$scraper;
}

sub _build_token {
	my $self = shift;
	
	my $res = $self->_get_res(0);
	my $token = $res->{token};
	$token = '' if !$token;
	
	$token =~ s/^.*&otorder=([^&]+).*$/$1/;
	$token;
}

sub _build_size {
	my $self = shift;
	
	my $res = $self->_get_res(0);
	
	my $size = $res->{size};
	my @matches = $size =~ /(\d+)/;
	
	$matches[0];
}

sub _get_content {
	my $self = shift;
	my ($i) = @_;
	
	my $uri = $SEARCH_URI;
	$uri .= '?word=' . uri_escape(join ' ', @{$self->tags});
	$uri .= '&s_mode=s_tag';
	
	if ($i > 0) {
		$uri .= '&p=' . ($i + 1);
		$uri .= '&otorder=' . $self->token;
	}
	
	my $res = $self->mech->get($uri);
	if (!$res->is_success) {
		die "Can't get content: " . $res->req->uri;
	}
	sleep $self->delay;
	
	$self->mech->decoded_content;
}

sub _get_res {
	my $self = shift;
	my ($i) = @_;
	
	return $res[$i] if defined $res[$i];
	
	$res[$i] = $self->xpath->scrape(
			$self->_get_content($i), $self->mech->uri
	);
}

sub get {
	my $self = shift;
	my ($i) = @_;
	
	return if ($i < 0 || $i >= $self->size);
	
	my $page_num = int($i / 20);
	my $illust_num = $i % 20;
	
	my $res = $self->_get_res($page_num);
	
	my $id = $res->{image}->[$illust_num];
	$id =~ s|^.*/(\d+)[^.]*\.[^.]+$|$1|;
	
	Net::Pixiv::Illust->new(
			mech	=> $self->mech,
			id		=> $id,
	);
}

1; # Magic true value required at end of module
__END__

=head1 NAME

Net::Pixiv::Result - [One line description of module's purpose here]


=head1 VERSION

This document describes Net::Pixiv::Result version 0.0.1


=head1 SYNOPSIS

    use Net::Pixiv::Result;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.

=head2 get
$illust1 = $res->get(0);
$illust2 = $res->get(23);

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
Net::Pixiv::Result requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-net-pixiv-result@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Kuzuha SHINODA  C<< <kuzuha01@hotmail.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Kuzuha SHINODA C<< <kuzuha01@hotmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
