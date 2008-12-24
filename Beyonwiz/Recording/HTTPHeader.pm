package Beyonwiz::Recording::HTTPHeader;

=head1 NAME

    use Beyonwiz::Recording::HTTPHeader;

=head1 SYNOPSIS

Provides access to the Beyonwiz recording file header via
HTTP.

=head1 SUPERCLASS

Inherits from L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::HTTPHeader->new($name, $base, $path) >>

Create a new Beyonwiz recording header object.
C<$name> is the default name of the recording (usually
the name in the Beyonwiz recording index, see
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>).
C<$base> is the base URL for the Beyonwiz device.
C<$path> is the path part of the recording URL (usually
the path in the recording index).

=item C<< $h->base([$val]); >>

Returns (sets) the device base URL.

=item C<< $h->name([$val]); >>

Returns (sets) the default recording name.

=item C<< $h->path([$val]); >>

Returns (sets) the recording URL path part.

=item C<< $h->url([$val]); >>

Returns (sets) the recording URL.

=item C<< $h->load([$full]) >>

Load the header object from the header on the Beyonwiz.
The I<offsets> data is only loaded if C<$full> is present and true.
If C<$full> is not set, only 2kB is downloaded,
otherwise 256kB is downloaded.

=item C<< $h->readHdrChunk($offset, $size) >>

Read a chunk of the header file length C<$size> at offset C<$offset>.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
C<File::Basename>,
C<LWP::Simple>,
C<URI>,
C<URI::Escape>.

=head1 BUGS

Uses C<bignum> for 64-bit integers, even when the underlying
Perl integers are 64 bits.

The bugs to do with time are in the Beyonwiz.

=cut


use warnings;
use strict;
use bignum;

use Beyonwiz::Recording::Header qw(TVHDR RADHDR);
use Beyonwiz::Utils;
use File::Basename;
use LWP::Simple qw(get $ua);
use URI;
use URI::Escape;

our @ISA = qw( Beyonwiz::Recording::Header );

my $accessorsDone;

sub new() {
    my ($class, $name, $base, $path) = @_;
    $class = ref($class) if(ref($class));

    my %fields = (
	base       => $base,
	path       => $path,
	url        => undef,
	name       => $name,
    );

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %fields);
	$accessorsDone = 1;
    }

    my $self = Beyonwiz::Recording::Header->new;

    $self = {
	%$self,
	%fields,
    };

    return bless $self, $class;
}

sub readHdrChunk($$$) {
    my ($self, $offset, $size) = @_;

    foreach my $h ($self->headerName ? ($self->headerName) : (TVHDR, RADHDR)) {

	my $url = $self->base->clone;
	$url->path($self->path . '/' . uri_escape($h));

	my $request = HTTP::Request->new(GET => $url);
	$request->header(range => "bytes=$offset-" . ($offset+$size-1));

	my $response = $ua->request($request);

	if($response->is_success && defined $response->content) {
	    $self->headerName($h);
	    $self->url($url);
	    return $response->content;
	}

    }
    return '';
}

1;
