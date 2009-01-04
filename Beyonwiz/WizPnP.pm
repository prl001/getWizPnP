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

=item C<< $wpnp->maxDevs([$val]); >>

Returns (sets) the maximum number of devices to search
for.
If set to 0, the search is unlimited, and runs until it times out.
Defaults to 0.

=item C<< $wpnp->devices([$val]); >>

Returns (sets) the reference to the hash of discovered devices
(L<C<Beyonwiz::WizPnPDevice>|Beyonwiz::WizPnPDevice>),
indexed by the lower-case version of the device name.

=item C<< $wpnp->httpTimeout([$val]); >>

Returns (sets) the timeout used when fetching the Beyonwiz device descriptor
using HTTP. Defaults to C<undef>. When set to C<undef> uses the C<LWP>
default timeout (180 sec).

=item C<< $wpnp->cacheEnable([$val]); >>

Returns (sets) the enable flag for the device location
lookup cache.
Only has an effect if executed on a derived class that
implements caching.

=item C<< $wpnp->cacheLifetime([$val]); >>

Returns (sets) the lifetime of a Beyonwiz location cache
entry in seconds.
Only has an effect if executed on a derived class that
implements caching.

=item C<< $wpnp->_quietLocation([$val]); >>

Returns (sets) a flag to suppress some warning messages during device
location specifier processing. Intended for use by derived clases when
they are testing for the presence of a Beyonwiz device and will take recovery action.

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

Returns the index name of the device (as in C<< $wpnp->deviceNames; >>)
if successful, C<undef> otherwise.

=item C<< $wpnp->process($data); >>

Process an SDDP C<M-SEARCH> response
(or, for now, an SSDP C<NOTIFY> message) in C<$data>,
and install the device pointed to by the C<LOCATION> header
in the message.

Returns the index name of the device (as in C<< $wpnp->deviceNames; >>)
if the message contained an installable SSDP device, C<undef> otherwise.

=item C<< $wpnp->search(); >>

Search the local net for Beyonwiz PnP devices and install
them in C<$wpnp>.

If C<< $wpnp->maxDevs >> non-zero, terminate
the search when C<< $self->maxDevs >> devices have been installed,
otherwise search until the search times out.

Returns the number of devices found.

=item C<< $wpnp->cacheFlush; >>

Clear the Beyonwiz location cache.
Only has an effect if executed on a derived class that
implements caching.

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

=cut

use warnings;
use strict;

use Beyonwiz::Utils;
use Beyonwiz::WizPnPDevice;
use IO::Select;
use HTTP::Response;
use HTTP::Request;
use HTTP::Status;
use LWP::Simple qw(get $ua);
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

# Address informtion for SSDP multicast device search

use constant SSDPADDR => '239.255.255.250';
use constant SSDPPORT => 1900;
use constant SSDPPEER => SSDPADDR . ':' . SSDPPORT;

# Maximum number of SSDP search requests. Maximum time
# for a search to complete ~= SSDPNPOLL * TIMEOUT = 12sec
use constant SSDPNPOLL    => 3;

# Maximum random delay a responding SSDP client may insert
# before replying.
use constant SSDPMAXDELAY => 3;

# Time to wait for an SSDP response (must be > SSDPMAXDELAY)
use constant TIMEOUT      => SSDPMAXDELAY + 1;

# Response polling timeout
use constant POLLTIME     => 0.2;

# Number of iterations in the response polling loop.
use constant NPOLLS       => int(TIMEOUT / POLLTIME + 0.5);

my $accessorsDone;
my $debug = 0;

sub new($) {
    my ($class) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	maxDevs		=> 0,
	devices		=> {},
	httpTimeout	=> undef,
	cacheEnable	=> undef,
	cacheLifetime	=> undef,
	_quietLocation	=> 0,
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

    my $oldTimeout = $ua->timeout;
    $ua->timeout($self->httpTimeout) if(defined $self->httpTimeout);

    my $devdesc = get($location);

    $ua->timeout($oldTimeout) if(defined $self->httpTimeout);

    if(!$devdesc) {
	warn "Bad WizPnP response: No device description returned",
		" from $location\n"
	    unless($self->_quietLocation);
	return undef;
    }
    my $dom = XML::DOM::Parser->new->parse($devdesc);
    if(!$dom) {
	warn "Bad WizPnP response: Couldn't parse device description",
	    " returned from $location\n";
	return undef;
    }
    my $dev = Beyonwiz::WizPnPDevice->new($location, $dom);
    my $name = $dev->name;
    if(defined $name && $name ne '') {
	$name = lc $name;
	$self->devices->{$name} = $dev;
    } else {
	warn "Bad WizPnP response: No name found for device description",
	    " from $location\n";
	return undef;
    }
    return $name;
}

sub process($$) {
    my ($self, $data) = @_;

    my $resp = HTTP::Response->parse($data);

    warn "Processing:\n", $data if($debug >= 1);

    if(!$resp->is_success) {
	warn 'Bad WizPnP response: ', $resp->status_line, "\n"
	    unless($self->_quietLocation && !defined $resp->code);
	return undef;
    }

    my $location = $resp->header('LOCATION');
    if(!defined $location) {
	warn "Bad WizPnP response: No device LOCATION\n";
	return undef;
    }
    my $st = $resp->header('ST');
    if(defined($st) && $st eq 'wizpnp-upnp-org:device:pvrtvdevice:1') {

	return $self->addDevice($location);

    }
    return undef;
}

sub search($) {
    my ($self) = @_;

    warn 'WizPnP search. Maxdev: ', $self->maxDevs, "\n" if($debug >= 1);

    die "Your system doesn't support multicast to discover WizPnP devices.\n",
	    "Either install Perl package IO::Socket::Multicast, or\n",
	    "use the --host option to specify your Beyonwiz's IP address ",
	    "or name.\n"
	unless($hasMulticast);

    for(my $i = 0;
	   $i < SSDPNPOLL
	   && (!$self->maxDevs || $self->ndevices < $self->maxDevs);
	   $i++) {

	# Create the SSDP search output socket.

	my $sout = IO::Socket::Multicast->new(Proto => 'udp',
					      PeerAddr => SSDPPEER)
		    || die 'Can\'t make multicast socket',
			   " to configure WizPnP: $!\n";
	$sout->mcast_loopback(0);
	$sout->mcast_ttl(1);

	# The reply to the SSDP request is directed to the host
	# issuing the request on the port that originated the request.
	# Get the output port to use to construct the input socket.

	my ($port) = sockaddr_in($sout->sockname);

	# Create the SSDP request as a HTTP format request
	# M-SEARCH (not part of HTTP 1.1).
	# Host is the SSDP multicast address and port.
	# MX is the maximum random delay (sec) that the responding
	# device may insert before replying (collision mitigation).
	# ST is the URI of the kind of devices that should respond.
	# MAN is the SSDP operation URI.

	my $req = HTTP::Request->new('M-SEARCH' => '*');
	$req->protocol('HTTP/1.1');
	$req->header(
		Host => SSDPPEER,
		MX   => SSDPMAXDELAY,
		ST   => 'urn:wizpnp-upnp-org:device:pvrtvdevice:1',
		MAN  => '"ssdp:discover"',
	    );

	warn "Send request:\n", $req->as_string, "\n" if($debug >= 1);
	$sout->send($req->as_string)
	    or die "Can't send multicast WizPnP search request: $!\n";;

	# If $sout is held open, the search fails at random on Windows
	# (and Cygwin), so the socket is closed and reopened for each
	# request.

	$sout->close || die "Can't close WizPnP multicast socket: $!\n";

	# Create the SSDP search input socket on the same port as the
	# request was sent.

	my $sin = IO::Socket::INET->new(Proto => 'udp',
					LocalPort => $port)
		    || die "Can't make input socket to configure WizPnP: $!\n";

	# Set up for select, so that the loop can time out.

	my $sel = IO::Select->new;
	$sel->add($sin);

	# Poll for responses and process them.

	for(my $i = 0;
	       $i < NPOLLS
	       && (!$self->maxDevs || $self->ndevices < $self->maxDevs);
	       $i++) {
	    foreach my $sock ($sel->can_read(POLLTIME)) {
		my $data;

		if(defined $sock->recv($data, 1500)) {
		    $self->process($data);
		} else {
		    die "Can't receive multicast WizPnP search response: $!\n"
			if($1);
		}
	    }
	}
	$sin->close || die "Can't close WizPnP input socket: $!\n";
    }
    return $self->ndevices;
}

sub cacheFlush($) {
    my ($self) = @_;
}

sub main(;$) {
    my $pnp = Beyonwiz::WizPnP->new;
    debug(1);
    $pnp->maxDevs(@_ > 0 ? $_[0] : 1);
    $pnp->search(@_ > 0 ? $_[0] : 1);
    print 'Found ', $pnp->ndevices, ' device',
	  ($pnp->ndevices == 1 ? '' :'s'), "\n";
    print 'Devices: (', join(', ', $pnp->deviceNames), ")\n"
	if($pnp->ndevices > 0);
}

1;
