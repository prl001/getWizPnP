package Beyonwiz::WizPnP;

=head1 NAME

    use Beyonwiz::WizPnP;

=head1 SYNOPSIS

Provides access data for the Beyonwiz devices on the local
network using WizPnP.

=head1 CONSTANTS

=over

=item C<DESC>

The URL path part for the WizPnP device descriptor
document on the Beyonwiz PVR (C<tvdevicedesc.xml>;

=item C<SSDPADDR>

The IP multicast address used for Simple Service Discovery Protocol
(SSDP) used to search for PnP devices (C<239.255.255.250>).

=item C<SSDPPORT>

The IP multicast port number used for Simple Service Discovery Protocol
(SSDP) used to search for PnP devices (C<1900>);

=item C<SSDPPEER>

I<SSDPADDR>:<SSDPPORT>; C<239.255.255.250:1900>

=back

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::WizPnP->new >>

Create a new Beyonwiz WizPnP search object.

=item C<< $wpnp->devices([$val]); >>

Returns (sets) the reference to the hash of discovered devices
(L<C<Beyonwiz::WizPnPDevice>|Beyonwiz::WizPnPDevice>),
indexed by the lower-case version of the device name.

=item C<< $wpnp->deviceNames; >>

Returns the list of discovered device names.
All lower-cased. No particular order.

=item C<< $wpnp->deviceNames; >>

Returns the list of discovered device names.
All lower-cased. No particular order.

=item C<< $wpnp->device($name); >>

Return the named device's
L<C<Beyonwiz::WizPnPDevice>|Beyonwiz::WizPnPDevice>
entry.
Lookup is case-insensitive.

=item C<< $wpnp->ndevices; >>

Returns the number of discovered devices.

=item C<< $wpnp->addDevice($location); >>

Request the device description XML from the URL
given in C<$location>, and install the
device L<C<Beyonwiz::WizPnPDevice>|Beyonwiz::WizPnPDevice> into C<$wpnp>.
C<$location> is typically the C<LOCATION> header in the
response to an SDDP C<M-SEARCH> request.

=item C<< $wpnp->process($data); >>

Process an SDDP C<M-SEARCH> response
(or, for now, an SSDP C<NOTIFY> message) in C<$data>,
and install the device pointed to by the C<LOCATION> header
in the message.

Returns true if the message contained an installable SSDP device.

=item C<< $wpnp->search([$maxdev]); >>

Search the local net for Beyonwiz PnP devices and install
them in C<$wpnp>.

If C<$maxdev> is supplied and non-zero, terminate
the search when C<$maxdev> devices have been installed.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::WizPnPDevice>|Beyonwiz::WizPnPDevice>,
C<IO::Socket::Multicast>,
C<IO::Select>,
C<HTTP::Response>,
C<HTTP::Request>,
C<HTTP::Status>,
C<LWP::Simple>,
C<URI>,
C<XML::DOM>.

=head1 BUGS

C<IO::Socket::Multicast> is not available in ActivePerl's
PPM for Windows. 

C<< Beyonwiz::Recording::WizPnP->new >> will die with a
message suggesting workarounds if C<IO::Socket::Multicast>
can't be loaded.

=cut

use warnings;
use strict;

use Beyonwiz::WizPnPDevice;
use IO::Select;
use HTTP::Response;
use HTTP::Request;
use HTTP::Status;
use LWP::Simple qw(get);
use URI;
use XML::DOM;

# Test at runtime whether IO::Socket::Multicast exists,
# and if it doesn't make new() die by setting $hasMulticast to fales.

my $hasMulticast;

BEGIN {
    eval 'require IO::Socket::Multicast';
    if($@) {
	$hasMulticast = 0;
    } else {
	$hasMulticast = 1;
	IO::Socket::Multicast->import;
    }
}

use constant DESC => 'tvdevicedesc.xml';

use constant SSDPADDR => '239.255.255.250';
use constant SSDPPORT => 1900;
use constant SSDPPEER => SSDPADDR . ':' . SSDPPORT;

use constant CRLF => "\015\012";

my $accessorsDone;

sub new($) {
    my ($class) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	devices	=> {},
    };

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    bless $self, $class;

    return $self;
}

sub deviceNames($) {
    my ($self) = @_;
    return keys %{$self->devices};
}

sub ndevices($) {
    my ($self) = @_;
    return scalar $self->deviceNames;
}

sub device($$) {
    my ($self, $name) = @_;
    return $self->devices->{lc $name};
}

sub addDevice($$) {
    my ($self, $location) = @_;

    my $devdesc = get($location);
    if(!$devdesc) {
	warn "Bad WizPnP response: no device description returned",
	    " from $location\n";
    }
    my $dom = XML::DOM::Parser->new->parse($devdesc);
    if(!$dom) {
	warn "Bad WizPnP response: couldn't parse device description",
	    " returned from $location\n";
	return;
    }
    my $dev = Beyonwiz::WizPnPDevice->new($location, $dom);
    my $name = $dev->name;
    if($name) {
	$self->devices->{lc $name} = $dev;
    } else {
	warn "No name found for device description in $location\n";
    }
}

sub process($$) {
    my ($self, $data) = @_;

    my $resp = HTTP::Response->parse($data);

    if(!$resp->is_success) {
	warn 'Bad WizPnP response: ', $resp->status_line, "\n";
	return;
    }

    my $location = $resp->header('LOCATION');
    if(!defined $location) {
	warn "Bad WizPnP response: no device LOCATION\n";
	return;
    }
    my $st = $resp->header('ST');
    if(defined($st) && $st eq 'wizpnp-upnp-org:device:pvrtvdevice:1') {

	$self->addDevice($location);
	return 1;

    }
}

sub search($;$) {
    my ($self, $maxdev) = @_;

    die "Your system doesn't support multicast to discover WizPnP devices.\n",
	    "Either install Perl package IO::Socket::Multicast, or\n",
	    "use the --host option to specify your Beyonwiz's IP address ",
	    "or name.\n"
	unless($hasMulticast);

    my $sout = IO::Socket::Multicast->new(Proto => 'udp',
					  PeerAddr => SSDPPEER,
					  ReuseAddr => 1)
		|| die "Can't make multicast socket to configure WizPnP: $!\n";
    $sout->mcast_loopback(0);
    $sout->mcast_ttl(1);
    my $sock = $sout->sockname;
    my ($port) = sockaddr_in($sock);

    my $sin = IO::Socket::INET->new(Proto => 'udp',
				    LocalPort => $port,
				    ReuseAddr => 1)
		|| die "Can't make input socket to configure WizPnP: $!\n";
    $sout->mcast_add(SSDPADDR)
		|| die "Can't add WizPnP multicast address: $!\n";

    my $req = HTTP::Request->new('M-SEARCH' => '*');
    $req->protocol('HTTP/1.1');
    $req->header(
	    Host => SSDPPEER,
	    MX   => 3,
	    ST   => 'urn:wizpnp-upnp-org:device:pvrtvdevice:1',
	    MAN  => '"ssdp:discover"'
        );

    my $ndev = $self->ndevices;

    for(my $i = 0;
	   $i < 3 && (!$maxdev || ($self->ndevices - $ndev) < $maxdev);
	   $i++) {

	$sout->send($req->as_string);

	my $sel = IO::Select->new;
	$sel->add($sin);

	for(my $i = 0;
	       $i < 60 && (!$maxdev || ($self->ndevices - $ndev) < $maxdev);
	       $i++) {
	    if($sel->can_read(0.1)) {
		my $data;
		$self->process($data) if(defined $sin->recv($data, 1024));
	    }
	}
    }
    $sout->close || die "Can't close WizPnP multicast socket: $!\n";
    $sin->close || die "Can't close WizPnP input socket: $!\n";
}

sub main() {
    my $pnp = Beyonwiz::WizPnP->new;
    $pnp->search(1);
}

1;
