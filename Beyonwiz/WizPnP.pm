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
PPM for Windows, see README.txt for a download location. 

C<< Beyonwiz::Recording::WizPnP->new >> will die with a
message suggesting workarounds if C<IO::Socket::Multicast>
can't be loaded.

C<< $wpnp->search([$maxdev]); >> has intermittent failure on Windows
with ActivePerl 10, and on Cygwin.
The search is either immediately successful or fails completely,
even on retry.

=cut

use warnings;
use strict;

use Beyonwiz::Utils;
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

use constant SSDPNPOLL    => 3;
use constant SSDPMAXDELAY => 3;
use constant TIMEOUT      => 4;
use constant POLLTIME     => 0.1;
use constant NPOLLS       => int(TIMEOUT / POLLTIME + 0.5);

use constant CRLF => "\015\012";

my $accessorsDone;
my $debug;

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

sub debug(;$) {
    my ($newDebug) = @_;
    my $old = $debug;
    $debug = $newDebug if(@_ > 0);
    return $old;
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
	warn "Bad WizPnP response: No device description returned",
	    " from $location\n";
	return;
    }
    my $dom = XML::DOM::Parser->new->parse($devdesc);
    if(!$dom) {
	warn "Bad WizPnP response: Couldn't parse device description",
	    " returned from $location\n";
	return;
    }
    my $dev = Beyonwiz::WizPnPDevice->new($location, $dom);
    my $name = $dev->name;
    if($name) {
	$self->devices->{lc $name} = $dev;
    } else {
	warn "Bad WizPnP response: No name found for device description",
	    " from $location\n";
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
	warn "Bad WizPnP response: No device LOCATION\n";
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

    warn 'WizPnP search. Maxdev: ', $maxdev, "\n" if($debug >= 1);

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

    my $req = HTTP::Request->new('M-SEARCH' => '*');
    $req->protocol('HTTP/1.1');
    $req->header(
	    Host => SSDPPEER,
	    MX   => SSDPMAXDELAY,
	    ST   => 'urn:wizpnp-upnp-org:device:pvrtvdevice:1',
	    MAN  => '"ssdp:discover"',
        );

    my $ndev = $self->ndevices;

    my $sel = IO::Select->new;
    $sel->add($sin);

    for(my $i = 0;
	   $i < SSDPNPOLL && (!$maxdev || ($self->ndevices - $ndev) < $maxdev);
	   $i++) {

	warn 'Send request:', $req->as_string, "\n" if($debug >= 1);
	$sout->send($req->as_string);

	for(my $i = 0;
	       $i < NPOLLS && (!$maxdev || ($self->ndevices - $ndev) < $maxdev);
	       $i++) {
	    foreach my $sock ($sel->can_read(POLLTIME)) {
		my $data;

		if(defined $sock->recv($data, 1500)) {
		    warn "Received:\n", $data if($debug >= 1);
		    $self->process($data);
		} else {
		    warn "Received:\n", $data if($debug >= 1);
		}
	    }
	}
    }
    $sout->close || die "Can't close WizPnP multicast socket: $!\n";
    $sin->close || die "Can't close WizPnP input socket: $!\n";
}

sub main(;$) {
    my $pnp = Beyonwiz::WizPnP->new;
    debug(1);
    $pnp->search(@_ > 0 ? $_[0] : 1);
    print 'Found ', $pnp->ndevices, ' device',
	  ($pnp->ndevices == 1 ? '' :'s'), "\n";
    print 'Devices: (', join(', ', $pnp->deviceNames), ")\n"
	if($pnp->ndevices > 0);
}

1;
