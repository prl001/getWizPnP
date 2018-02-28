package Beyonwiz::WizPnPDevice;

my $Copyright = 'Copyright 2008-2018 Peter Lamb.
See accompanying LICENSE file for redistribution conditions.';

=head1 NAME

    use Beyonwiz::WizPnPDevice;

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

=item C<< $wpnpd->netmask([$val]); >>

Returns (sets) the netmask of the network the device is attached to,
as a packed IP address.

=item C<< $wpnpd->longNames([$val]); >>

Returns (sets) the flag to use the long or short form of
device names in searches and name functions.
Defaults to I<false>.

=item C<< $wpnpd->baseUrl; >>

Returns the base URL for the device.

=item C<< $wpnpd->indexUrl; >>

Returns the URL of the the device recording index document.

=item C<< $wpnpd->deviceDom; >>

Returns the C<< <device> >> DOM subtree of the description.

=item C<< $wpnpd->hostIP; >>

Returns the WizPnP device's IP address as a string in in dotted quad format
(e.g. C<10.1.1.4>).

=item C<< $wpnpd->hostNum; >>

Returns the WizPnP device's host num as a string in in dotted format.
This is the hostIP (C<< $wpnpd->hostIP; >>)
anded with the netmask (C<< $wpnpd->netmask; >>),
and with any leading C<0.> parts stripped off.
(e.g. with an IP address of C<10.1.1.4>, and netmask C<255.255.255.0>,
returns C<4>, with a netmask C<255.255.0.0>, returns C<1.4>).

=item C<< $wpnpd->portNum; >>

Returns the WizPnP device's port number as an integer (e.g. C<49152>).

=item C<< $wpnpd->shortName; >>

Returns the device's WizPnP name (as set in C<< Setup>Network>WizPnP>Name >>).

=item C<< $wpnpd->longName; >>

Returns the device's WizPnP name (C<< $wpnpd->shortName; >>),
host number (C<< $wpnpd->hostNum; >>), and
port number (C<< $wpnpd->portNum; >>) as a string separated by C<->.
E.g. for device MyBeyonwiz, IP address of C<10.1.1.4>,
netmask C<255.255.255.0> and port C<49152>, returns
C<MyBeyonwiz-4-49152>.

=item C<< $wpnpd->name; >>

Returns C<< $wpnpd->longName; >> if C<< $wpnpd->longNames([$val]); >>
is I<true>, otherwise C<< $wpnpd->shortName; >>.

=item C<< $wpnpd->presentationURL; >>

Returns the device's WizPnP presentationURL.

=back

=head1 PREREQUISITES

Uses packages:
C<URI>,
C<XML::DOM>,
C<Socket>.


=cut

use strict;
use warnings;

use URI;
use XML::DOM;
use Socket;

my $accessorsDone;

sub new($$$$) {
    my ($class, $location, $dom, $netmask) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	location	=> URI->new($location),
	dom		=> $dom,
	netmask		=> $netmask,
	useLongName	=> 0,
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

sub hostIP($) {
    my ($self) = @_;
    if($self->location->authority) {
	return $self->location->host;
    }
    return '';
}

sub hostNum($) {
    my ($self) = @_;
    my $host = $self->hostIP;
    if(length($host) > 0) {
	my $ip = gethostbyname($host);
	if(defined $ip) {
	    $host = inet_ntoa($ip & ~$self->netmask);
	    $host =~ s/^(0+\.)+//;
	}
    }
    return $host;
}

sub portNum($) {
    my ($self) = @_;
    if($self->location->authority) {
	return $self->location->port;
    }
    return '';
}

sub shortName($) {
    my ($self) = @_;
    my $dom = $self->dom;
    return undef if(!defined $dom);
    my @dev = $dom->getElementsByTagName('friendlyName');
    return defined($dev[0]) && defined($dev[0]->getFirstChild)
	   ? $dev[0]->getFirstChild->getData
	   : '';
}

sub longName($) {
    my ($self) = @_;
    my $name = $self->shortName;
    $name = '' if(!defined $name);
    $name .= '-' . $self->hostNum . '-' . $self->portNum;
    return $name
}

sub name($) {
    my ($self) = @_;
    return $self->useLongName ? $self->longName : $self->shortName;
}

sub presentationURL($) {
    my ($self) = @_;
    my $dom = $self->dom;
    return undef if(!defined $self->dom);
    my @purl = $dom->getElementsByTagName('presentationURL');
    return $purl[0] ? $purl[0]->getFirstChild->getData : undef;
}

1;
