package Beyonwiz::WizPnPDevice;

=head1 NAME

    use Beyonwiz::Recording::WizPnPDevice;

=head1 SYNOPSIS

Represents an entry in the Beyonwiz trunc file.

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::WizPnPDevice->new($location, $dom) >>

Create a new WizPnP device object.
C<$location> is the URL for the device's XML description,
and C<$dom> us the C<XML::DOM> tree for the description.
Normally constructed by
L<C<Beyonwiz::WizPnP>|Beyonwiz::WizPnP> in I<search> or I<addDevice>.

=item C<< $wpnpd->location([$val]); >>

Returns (sets) the URL for the device's XML description.

=item C<< $wpnpd->dom([$val]); >>

Returns (sets) the device description DOM tree.

=item C<< $wpnpd->baseUrl; >>

Returns the base URL for the device.

=item C<< $wpnpd->indexUrl; >>

Returns the URL of the the device recording index document.

=item C<< $wpnpd->deviceDom; >>

Returns the C<< <device> >> DOM subtree of the description.

=item C<< $wpnpd->name; >>

Returns the device's WizPnP name (as set in Setup>Network>WizPnP>Name).

=item C<< $wpnpd->presentationURL; >>

Returns the device's WizPnP presentationURL.

=back

=head1 PREREQUISITES

Uses packages:
C<URI>,
C<XML::DOM>,
C<File::Basename>.


=cut

use strict;
use warnings;

use URI;
use XML::DOM;
use File::Basename;

my $accessorsDone;

sub new($$$) {
    my ($class, $location, $dom) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	location	=> URI->new($location),
	dom		=> $dom,
    };

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    bless $self, $class;

    return $self;
}

sub baseUrl($) {
    my ($self) = @_;
    my $url = $self->location->clone;
    $url->path('');
    return $url;
}

sub indexUrl($) {
    my ($self) = @_;
    my $url = $self->location->clone;
    my $index = $self->presentationURL;
    my ($file, $path, $ext) = fileparse($index, qr/\.[^.]*/);
    $file = 'index' if(!$ext);
    $url->path($path . $file . '.text');
    return $url;
}

sub deviceDom($) {
    my ($self) = @_;
    my $dom = $self->dom;
    return undef if(!defined $dom);
    my @dev = $dom->getElementsByTagName('device');
    return $dev[0];
}

sub name($) {
    my ($self) = @_;
    my $dom = $self->dom;
    return undef if(!defined $dom);
    my @dev = $dom->getElementsByTagName('friendlyName');
    return defined($dev[0]) && defined($dev[0]->getFirstChild)
	   ? $dev[0]->getFirstChild->getData
	   : undef;
}

sub presentationURL($) {
    my ($self) = @_;
    my $dom = $self->dom;
    return undef if(!defined $self->dom);
    my @purl = $dom->getElementsByTagName('presentationURL');
    return $purl[0] ? $purl[0]->getFirstChild->getData : undef;
}

1;
