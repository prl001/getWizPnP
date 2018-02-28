package Beyonwiz::WizPnP;

my $Copyright = 'Copyright 2008-2018 Peter Lamb.
See accompanying LICENSE file for redistribution conditions.';

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

 Beyonwiz WizPnP servers appear to only wait about 40ms 
 
=item C<SSDPNPOLL>

Default maximum number of SSDP search requests (3). Maximum time
for a search to complete ~= SSDPNPOLL * SSDPTIMEOUT = 0.9 sec

=item C<SSDPMAXDELAY>

Default maximum random delay (3 seconds, integer) that a responding
SSDP server may insert before replying.
The Beyonwiz WizPnP server seems to ignore
this, and replys in about 35-40ms.

=item C<SSDPTIMEOUT>

Default time to wait (0.3 sec) for an SSDP response.
Should be > C<SSDPMAXDELAY>, but testing shows 0.3 sec to be adequate
with C<SSDPNPOLL> set to 3.
See comment about response delay in C<L</SSDPMAXDELAY>>.

=item C<SSDPPOLLTIME>

Response polling timeout granularity (0.1 sec).

=back

=head1 METHODS

=over

=item C<< Beyonwiz::WizPnP->new >>

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

=item C<< $wpnp->wizpnpPoll([$val]); >>

Returns (sets) the maximum number of search requests sent by 
C<< $wpnp->search(); >>
before terminating the search.
Defaults to C<SSDPNPOLL>.

=item C<< $wpnp->useLongNames([$val]); >>

Returns (sets) the flag to use the long or short form of
device names in searches and name functions.
Defaults to I<false>.

=item C<< $wpnp->wizpnpTimeout([$val]); >>

Returns (sets) the maximum timeout used when waiting for a respnse
to a WizPnP SSDP device search request.
Defaults to SSDPTIMEOUT sec.

=item C<< $wpnp->httpTimeout([$val]); >>

Returns (sets) the timeout used when fetching the Beyonwiz device descriptor
using HTTP. Defaults to C<undef>. When set to C<undef> uses the C<LWP>
default timeout (180 sec).

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

=item C<< $wpnp->sort; >>

Sort the devices by name, then host number, then port.

=item C<< $wpnp->search; >>

Search the local net for Beyonwiz PnP devices and install
them in C<$wpnp>.

If C<< $wpnp->maxDevs >> non-zero, terminate
the search when C<< $self->maxDevs >> devices have been installed,
otherwise search until the search times out.

Sorts the device entries using C<< $wpnp->sort; >>.

Returns the number of devices found.

=back

=head1 INTERNAL METHODS

=over

=item C<< $wpnp->_quietLocation([$val]); >>

Returns (sets) a flag to suppress some warning messages during device
location specifier processing. Intended for use by derived clases when
they are testing for the presence of a Beyonwiz device
and will take recovery action.

=item C<< $wpnp->_requestSock([$val]); >>

Returns (sets) the multicast socket on which WizPnP's SSDP search
requests are sent.
Normally set by C<< $wpnp->_openRequestSock(); >>
and C<< $wpnp->_closeRequestSock(); >>.

=item C<< $wpnp->_responseSock([$val]); >>

Returns (sets) the socket on which WizPnP's SSDP search
responses are received.
Normally set by C<< $wpnp->_openResponseSock(); >>
and C<< $wpnp->_closeResponseSock(); >>.

=item C<< $wpnp->_responsePort([$val]); >>

Returns (sets) the port on which WizPnP's SSDP search
requests were sent and on which its responses are received.
Normally set by C<< $wpnp->_openRequestSock(); >>
and C<< $wpnp->_openRequestSock(); >>.

=item C<< $wpnp->_request([$val]); >>

Returns (sets) the C<< HTTP::Request >> that will be sent
by WizPnP's SSDP search requests.
Normally set in the class constructor.

=item C<< $wpnp->_openRequestSock; >>

Opens the multicast socket on which WizPnP's SSDP search
requests are sent.
Also sets C<< $wpnp->_requestSock; >> and C<< $wpnp->_responsePort; >>

=item C<< $wpnp->_closeRequestSock; >>

Closes the socket on which WizPnP's SSDP search
requests are sent.
Sets C<< $wpnp->_requestSock; >> to C<undef>.

=item C<< $wpnp->_openResponseSock(); >>

Opens the socket on which WizPnP's SSDP search
responses are received.
Sets C<< $wpnp->_responseSock; >> to C<undef>.

=item C<< $wpnp->_closeResponseSock(); >>

Opens the socket on which WizPnP's SSDP search
responses are received.
Sets C<< $wpnp->_responseSock; >> and C<< $wpnp->_responsePort; >>
to C<undef>.

=item C<< Beyonwiz::WizPnP::_isMacOs >>

Returns true if the system runnung is MacOS X or Darwin.

=item C<< Beyonwiz::WizPnP::_netmask >>

Returns the local interface netmask, if known.
Defaults to 0.0.0.0.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::WizPnPDevice>|Beyonwiz::WizPnPDevice>,
C<IO::Socket::Multicast>,
C<IO::Select>,
C<IO::Interface::Simple>,
C<HTTP::Response>,
C<HTTP::Request>,
C<HTTP::Status>,
C<LWP::Simple>,
C<URI>,
C<XML::DOM>
C<Time::HiRes>.

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
use Socket;
use HTTP::Response;
use HTTP::Request;
use HTTP::Status qw(:is);
use LWP::Simple qw(get $ua);
use URI;
use XML::DOM;
use Time::HiRes;

# Test at runtime whether IO::Socket::Multicast exists,
# and if it doesn't make new() die by setting $hasMulticast to false.

my $hasMulticast = Beyonwiz::Utils::tryUse IO::Socket::Multicast;
my $hasInterfaceSimple = Beyonwiz::Utils::tryUse IO::Interface::Simple;

use constant DESC => 'tvdevicedesc.xml';

# Address informtion for SSDP multicast device search

use constant SSDPADDR => '239.255.255.250';
use constant SSDPPORT => 1900;
use constant SSDPPEER => SSDPADDR . ':' . SSDPPORT;

# Maximum number of SSDP search requests. Maximum time
# for a search to complete ~= SSDPNPOLL * SSDPTIMEOUT = 0.9 sec
use constant SSDPNPOLL    => 3;

# Maximum random delay (in seconds) that a responding SSDP server
# may insert before replying. The Beyonwiz server seems to ignore
# this, and reply in about 35-40ms.
use constant SSDPMAXDELAY => 3;

# Time to wait for an SSDP response. Should be > SSDPMAXDELAY,
# but tests indicate that 0.3 sec is sufficient with
# SSDPNPOLL = 3..

use constant SSDPTIMEOUT      => 0.3;

# Response polling timeout
use constant SSDPPOLLTIME     => 0.1;

my $accessorsDone;
my $debug = 0;

sub new($) {
    my ($class) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	maxDevs		=> 0,
	devices		=> [],
	useLongNames	=> 0,
	wizpnpTimeout	=> SSDPTIMEOUT,
	wizpnpPoll	=> SSDPNPOLL,
	httpTimeout	=> undef,
	_quietLocation	=> 0,
	_requestSock	=> undef,
	_responseSock	=> undef,
	_responsePort	=> undef,
	_request	=> undef,
	_netmask	=> inet_aton('0.0.0.0'),
    };

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    bless $self, $class;

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

    $self->_request($req);

    return $self;
}

sub debug(;$) {
    my ($newDebug) = @_;
    my $old = $debug;
    $debug = $newDebug if(@_ > 0);
    return $old;
}

sub _isMacOSX {
    return $^O eq 'darwin';
}

sub deviceNames($) {
    my ($self) = @_;
    return map {
		    $self->useLongNames
			? $_->longName
			: $_->shortName;
		} @{$self->devices};
}

sub ndevices($) {
    my ($self) = @_;
    return scalar @{$self->devices};
}

sub shortLookup($$) {
    my ($self, $name) = @_;
    $name = lc $name;
    return grep { defined($_->shortName)
			&& index(lc $_->shortName, $name) >= 0 }
		    @{$self->devices};
}

sub longLookup($$) {
    my ($self, $name) = @_;
    $name = lc $name;
    return grep { defined($_->longName) && index(lc $_->longName, $name) >= 0 }
		    @{$self->devices};
}

sub lookup($$) {
    my ($self, $name) = @_;
    return $self->useLongNames
		? $self->longLookup($name)
		: $self->shortLookup($name);
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
    my $dev = Beyonwiz::WizPnPDevice->new($location, $dom, $self->_netmask);
    my $longName = $dev->longName;
    if(defined $longName) {
	if(!$self->longLookup($longName)) {
	    $dev->useLongName($self->useLongNames);
	    push @{$self->devices}, $dev;
	}
    } else {
	warn "Bad WizPnP response: No name found for device description",
	    " from $location\n";
	return undef;
    }
    return $longName;
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

sub _openRequestSock($) {
    my ($self) = @_;

    # Create the SSDP search output socket.

    my $sout = IO::Socket::Multicast->new(Proto => 'udp',
					  PeerAddr => SSDPPEER)
		|| die 'Can\'t make WizPnP multicast request socket',
		       " to configure WizPnP: $!\n";

    $self->_requestSock($sout);

    # The reply to the SSDP request is directed to the host
    # issuing the request on the port that originated the request.
    # Get the output port to use to construct the input socket.

    my ($port, $addr) = sockaddr_in($sout->sockname);

    if($hasInterfaceSimple) {
	my $if   = IO::Interface::Simple->new_from_address(inet_ntoa($addr));

	$self->_netmask(inet_aton($if->netmask)) if(defined $if);
    }

    $self->_responsePort($port);
}

sub _closeRequestSock($) {
    my ($self) = @_;
    !defined($self->_requestSock)
	|| $self->_requestSock->close
	|| die "Can't close WizPnP multicast request socket: $!\n";
    $self->_requestSock(undef);
}

sub _openResponseSock($) {
    my ($self) = @_;
    # Create the SSDP search input socket on the same port as the
    # request was sent.

    my $sin = IO::Socket::INET->new(Proto => 'udp',
				    LocalPort => $self->_responsePort,
				    ReuseAddr => _isMacOSX)
		|| die "Can't make response socket to configure WizPnP: $!\n";
    $self->_responseSock($sin);
}

sub _closeResponseSock($) {
    my ($self) = @_;
    !defined($self->_responseSock)
	|| $self->_responseSock->close
	|| die "Can't close WizPnP response socket: $!\n";
    $self->_responseSock(undef);
    $self->_responsePort(undef);
}

sub _sortCmp($$) {
	my $cmp = $_[0]->shortName cmp $_[1]->shortName;
	return $cmp if($cmp != 0);
	my ($ip1, $ip2);
	my $h1 = $_[0]->hostIP;
	$ip1 = gethostbyname($h1) if(length($h1) > 0);
	my $h2 = $_[1]->hostIP;
	$ip2 = gethostbyname($h2) if(length($h2) > 0);
	if(defined $ip1 and defined $ip2) {
	    $cmp = $ip1 cmp $ip2;
	    return $cmp if($cmp != 0);
	}
	return $_[0]->portNum <=> $_[1]->portNum;
}

sub sort($) {
    my ($self) = @_;
    @{$self->devices} = sort _sortCmp @{$self->devices};
}

sub search($) {
    my ($self) = @_;

    warn 'WizPnP search. Maxdev: ', $self->maxDevs, "\n" if($debug >= 1);

    die "Your system doesn't support multicast to discover WizPnP devices.\n",
	    "Either install Perl package IO::Socket::Multicast, or\n",
	    "use the --host option to specify your Beyonwiz's IP address ",
	    "or name.\n"
	unless($hasMulticast);

    if(_isMacOSX) {
	$self->_openRequestSock;
	$self->_openResponseSock;
    }

    for(my $i = 0;
	   $i < $self->wizpnpPoll
	   && (!$self->maxDevs || $self->ndevices < $self->maxDevs);
	   $i++) {

	$self->_openRequestSock unless(_isMacOSX);

	warn "Send request:\n", $self->_request->as_string, "\n"
	    if($debug >= 1);
	$self->_requestSock->send($self->_request->as_string)
	    or die "Can't send multicast WizPnP search request: $!\n";;

	$self->_closeRequestSock unless(_isMacOSX);

	# Set up for select, so that the loop can time out.

	$self->_openResponseSock unless(_isMacOSX);

	my $sel = IO::Select->new;
	$sel->add($self->_responseSock);

	# Poll for responses and process them.

	my $startTime = Time::HiRes::time;
	while(Time::HiRes::time - $startTime < $self->wizpnpTimeout
	       && (!$self->maxDevs || $self->ndevices < $self->maxDevs)) {
	    foreach my $sock ($sel->can_read(SSDPPOLLTIME)) {
		my $data;
		if(defined $sock->recv($data, 1500)) {
		    $self->process($data);
		} else {
		    die "Can't receive multicast WizPnP search response: $!\n"
			if($1);
		}
	    }
	}
	$self->_closeResponseSock unless(_isMacOSX);
    }
	# If $sout is held open, the search fails at random on Windows
	# (and Cygwin), so the socket is closed and reopened for each
	# request.

    if(_isMacOSX) {
	$self->_closeRequestSock;
	$self->_closeResponseSock;
    }
    $self->sort;
    return $self->ndevices;
}

sub main(;$$$) {
    my $pnp = Beyonwiz::WizPnP->new;
    debug(1);
    $pnp->maxDevs(@_ >= 1 ? $_[0] : 1);
    $pnp->wizpnpTimeout(@_ >= 2 ? $_[1] : 1);
    $pnp->wizpnpPoll(@_ >= 3 ? $_[2] : 1);
    $pnp->search;
    print 'Found ', $pnp->ndevices, ' device',
	  ($pnp->ndevices == 1 ? '' :'s'), "\n";
    print 'Devices: (', join(', ', $pnp->deviceNames), ")\n"
	if($pnp->ndevices > 0);
}

1;
