package Beyonwiz::WizPnPDevice;

=head1 SYNOPSIS

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
L<C<Beyonwiz::WizPnP>|Beyonwiz::WizPnP> in I<search> or I<add_device>.

=item C<< $wpnpd->location([$val]); >>

Returns (sets) the URL for the device's XML description.

=item C<< $wpnpd->dom([$val]); >>

Returns (sets) the device description DOM tree.

=item C<< $wpnpd->base_url; >>

Returns the base URL for the device.

=item C<< $wpnpd->index_url; >>

Returns the URL of the the device recording index document.

=item C<< $wpnpd->device_dom; >>

Returns the C<< <device> >> DOM subtree of the description.

=item C<< $wpnpd->name; >>

Returns the device's WizPnP name (as set in Setup>Network>WizPnP>Name).

=item C<< $wpnpd->presentationURL; >>

Returns the device's WizPnP presentationURL.

=back

=cut

use strict;
use warnings;

use URI;
use XML::DOM;
use File::Basename;

sub new($$$) {
    my ($class, $location, $dom) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	location	=> URI->new($location),
	dom		=> $dom,
    };
    bless $self, $class;

    return $self;
}

sub location($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{location};
    $self->{location} = URI->new($val) if(@_ == 2);
    return $ret;
}

sub dom($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{dom};
    $self->{dom} = $val if(@_ == 2);
    return $ret;
}

sub base_url($) {
    my ($self) = @_;
    my $url = $self->location->clone;
    $url->path('');
    return $url;
}

sub index_url($) {
    my ($self) = @_;
    my $url = $self->location->clone;
    my $index = $self->presentationURL;
    my ($file, $path, $ext) = fileparse($index, qr/\.[^.]*/);
    $file = 'index' if(!$ext);
    $url->path($path . $file . '.text');
    return $url;
}

sub device_dom($) {
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
    return $dev[0] ? $dev[0]->getFirstChild->getData : undef;
}

sub presentationURL($) {
    my ($self) = @_;
    my $dom = $self->dom;
    return undef if(!defined $self->dom);
    my @purl = $dom->getElementsByTagName('presentationURL');
    return $purl[0] ? $purl[0]->getFirstChild->getData : undef;
}

1;
