package Beyonwiz::Recording::Header;

=head1 SYNOPSIS

    use Beyonwiz::Recording::Header;


=head1 SYNOPSIS

Provides access to the Beyonwiz recording file header.

=head1 CONSTANTS

=over

=item C<TVHDR>

The name of the header file for a digital TV recording (C<header.tvwiz>).

=item C<RADHDR>

The name of the header file for a digital radio recording (C<header.radwiz>).

=item C<DAY>

Number of seconds in a day. Used internally for time conversion.

=item C<MAX_TS_POINT>

Maximum number of offsets in I<offsets> (8640).

=back

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Header->new($name, $base, $path) >>

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

=item C<< $h->name([$val]); >>

Returns (sets) the default recording name.

=item C<< $h->path([$val]); >>

Returns (sets) the recording URL path part.

=item C<< $h->headerName([$val]); >>

Returns (sets) the name of the header document (path part only).

=item C<< $h->unknown([$val]); >>

Returns (sets) the array reference of the 5 words in the header file
whose interpretation has not yet been made public.

=item C<< $h->lock([$val]); >>

Returns (sets) lock flag. Possibly the flag that indicates the
recording has a parental lock set on the Beyonwiz.
Unused in WizFX.

=item C<< $h->full([$val]); >>

Returns (sets) the full flag.
Purpose unknown.
Unused in WizFX.

=item C<< $h->inRec([$val]); >>

Returns (sets) the "currently recording" flag.

=item C<< $h->service([$val]); >>

Returns (sets) the recording service (LCN) name.

=item C<< $h->title([$val]); >>

Returns (sets) the recording title (event name).

=item C<< $h->mjd([$val]); >>

Returns (sets) the recording start date.
The name suggests that it is the Modified Julian Date, but it
isn't.

C<< $h->mjd == int(true_MJD + time_zone_offset_in_minutes/(24*60)) >>
where C<time_zone_offset_in_minutes> is the time zone setting in
minutes current at the start of the recording.

The Beyonwiz appears to keep local time rather than UTC as its internal time.

=item C<< $h->start([$val]); >>

Returns (sets) number of seconds into the day indicated by C<< $h->mjd >>
when the recording started.

=item C<< $h->last([$val]); $h->sec([$val]); >>

Return (set) two parameters describing the recording duration.
The recording duration in seconds is: C<<< $self->last*10 + $self->sec >>>.
C<< $h->playtime >> is a convenience method that calculates the playtime
from I<last> and I<sec>.

=item C<< $h->endOffset([$val]); >>

Return the offset of the logical end of the recording.
Returns a C<bignum>.

=item C<< $h->offsets([$val]); >>

Return (set) the table of offsets (possibly at even time intervals?)
of logical file offsets (as described in C<< $h->endOffset([$val]); >>).
Offsets are returned as C<bignum>s.

If the offsets are at even intervals, it's probably 10 seconds.

For efficiency reasons, only populated for C<< $h->load(1) >>.

=item C<< $h->noffsets; >>

Returns the number of offsets.

=item C<< $h->bookmarks([$val]); >>

Return (set) the table of bookmarks (possibly at even time intervals?)
of logical file offsets (as described in C<< $h->endOffset([$val]); >>).
Offsets are returned as C<bignum>s.

For efficiency reasons, only populated for C<< $h->load(1) >>.

=item C<< $h->nbookmarks; >>

Returns the number of bookmarks.

=item C<< $h->valid; >>

Returns true if the last C<< $h->load; >> was successful.

=item C<< $h->size; >>

Returns the size of the header file (256kB).

=item C<< $h->isTV; $h->isRadio; >>

Returns true if C<< $h->valid; >> is true and the recording
is digital TV (resp digital radio).

=item C<< $h->playtime >>

A convenience method that returns the duration of
the recording in seconds.

=item C<< $h->starttime >>

Returns a Unix-like timestamp for the start time of the recording
in local time (rather than in UTC, like a true Unix timestamp).
More precisely, returns the number of seconds since midnight at the
start of 1 Jan 1970, I<plus> the number of seconds in the timezone offset
at the time the recording was started.

This can be converted into the calender/clock fields for the
local time at the start of the recording using C<< gmtime >>
(I<not> C<< localtime >>).

The local time fields can then be converted into a genuine Unix timestamp
using C<< Time::Local::timelocal >>.

=item C<<  $h->offset_time($offset) >>

Convert an offset into a time. C<< $h->load(1) >> must have been called,
otherwise -1 is returned. Interpolates between values in the offset table.
Returns 0 if C<< $offset <= $self->offsets->[0] >> and
C<< $self->playtime >> if C<< $offset >= $self->endOffset >>.


=item C<< $h->load([$full]) >>

Load the header object from the header on the Beyonwiz.
The I<offsets> data is only loaded if C<$full> is present and true.
If C<$full> is not set, only 2kB is downloaded,
otherwise 256kB is downloaded.

=back

=head1 PREREQUISITES

Uses packages:
C<File::Basename>,
C<LWP::Simple>,
C<URI::Escape>,
C<URI>.

=head1 BUGS

Uses C<bignum> for 64-bit integers, even when the underlying
Perl integers are 64 bits.

The bugs to do with time are in the Beyonwiz.

=cut


use warnings;
use strict;
use bignum;

use File::Basename;
use LWP::Simple qw(get $ua);
use URI;
use URI::Escape;

use constant DAY => 24*60*60; # Seconds in a day
use constant TVHDR => 'header.tvwiz';
use constant RADHDR => 'header.radwiz';

use constant MAX_TS_POINT => 8640;

sub new() {
    my ($class, $name, $base, $path) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	base       => $base,
	path       => $path,
	url        => undef,
	name       => $name,
	headerName => undef,
	unknown    => [],
	lock       => undef,
	full       => undef,
	inRec      => undef,
	service    => undef,
	title      => undef,
	mjd        => undef,
	start      => undef,
	last       => undef,
	sec        => undef,
	endOffset  => undef,
	offsets    => [],
	bookmarks  => [],
    };

    return bless $self, $class;
}

sub base($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{base};
    $self->{base} = $val if(@_ == 2);
    return $ret;
}

sub path($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{path};
    $self->{path} = $val if(@_ == 2);
    return $ret;
}

sub url($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{url};
    $self->{url} = $val if(@_ == 2);
    return $ret;
}

sub name($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{name};
    $self->{name} = $val if(@_ == 2);
    return $ret;
}

sub headerName($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{headerName};
    $self->{headerName} = $val if(@_ == 2);
    return $ret;
}

sub unknown($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{unknown};
    $self->{unknown} = $val if(@_ == 2);
    return $ret;
}

sub lock($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{lock};
    $self->{lock} = $val if(@_ == 2);
    return $ret;
}

sub full($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{full};
    $self->{full} = $val if(@_ == 2);
    return $ret;
}

sub inRec($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{inRec};
    $self->{inRec} = $val if(@_ == 2);
    return $ret;
}

sub service($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{service};
    $self->{service} = $val if(@_ == 2);
    return $ret;
}

sub title($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{title};
    $self->{title} = $val if(@_ == 2);
    return $ret;
}

sub mjd($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{mjd};
    $self->{mjd} = $val if(@_ == 2);
    return $ret;
}

sub start($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{start};
    $self->{start} = $val if(@_ == 2);
    return $ret;
}

sub last($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{last};
    $self->{last} = $val if(@_ == 2);
    return $ret;
}

sub sec($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{sec};
    $self->{sec} = $val if(@_ == 2);
    return $ret;
}

sub endOffset($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{endOffset};
    $self->{endOffset} = $val if(@_ == 2);
    return $ret;
}

sub startOffset($;$) {
    my ($self, $val) = @_;
    my $ret = $self->offsets->[0];
    $self->offsets->[0] = $val if(@_ == 2);
    return $ret;
}

sub offsets($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{offsets};
    $self->{offsets} = $val if(@_ == 2);
    return $ret;
}

sub noffsets($) {
    my ($self) = @_;
    return scalar @{$self->offsets};
}

sub bookmarks($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{bookmarks};
    $self->{bookmarks} = $val if(@_ == 2);
    return $ret;
}

sub nbookmarks($) {
    my ($self) = @_;
    return scalar @{$self->bookmarks};
}

sub valid() {
    my ($self) = @_;
    return defined $self->url;
}

sub size() {
    my ($self) = @_;
    return 256 * 1024;
}

sub isTV() {
    my ($self) = @_;
    return defined($self->headerName) && $self->headerName eq TVHDR;
}

sub isRadio() {
    my ($self) = @_;
    return defined($self->headerName) && $self->headerName eq RADHDR;
}

sub playtime() {
    my ($self) = @_;
    # Magic formula from WizFX code
    return $self->last*10 + $self->sec;
}

sub starttime() {
    my ($self) = @_;
    # Unix epoch, 00:00 1 Jan 1970 UTC, is 40587 days after MJD epoch,
    # 00:00 17 Nov 1858.
    return ($self->mjd - 40587) * DAY + $self->start;
}

sub offset_time($$) {
    my ($self, $offset) = @_;

    return 0 if($offset <= $self->offsets->[0]);
    return $self->playtime if($offset >= $self->endOffset);
    
    my($low, $high, $dt, $index);

    if($offset >= $self->offsets->[$self->last]) {
	$low = $self->offsets->[$self->last];
	$high = $self->endOffset;
	$dt = $self->sec;
	$index = $self->last;
    } else {
	my ($f, $l) = (0, $#{$self->offsets});
	my $m;
	do {
	    $m = int(($f + $l) / 2);
	    if($offset < $self->offsets->[$m]) {
		$l = $m - 1;
	    } else {
		$f = $m + 1;
	    }
	} until($self->offsets->[$m] == $offset || $f > $l);

	return $m * 10 if($self->offsets->[$m] == $offset);

	$low  = $self->offsets->[$l-1];
	$high = $self->offsets->[$l];
	$dt = 10;
	$index = $l;
    }

    return $dt * ($index + ($offset - $low) / ($high - $low));
}

sub load(;$) {
    my ($self, $full) = @_;
    my $hdr_data;
    foreach my $h (TVHDR, RADHDR) {
	my $url = $self->base->clone;
	$url->path($self->path . '/' . uri_escape($h));

	my $old_max;
	if(!$full) {
	    $old_max = $ua->max_size;
	    $ua->max_size(2048);
	}

	$hdr_data = get($url);

	$ua->max_size($old_max) if(!$full);

	if(defined $hdr_data) {
	    $self->url($url);
	    $self->headerName($h);
	    my ($so0, $so1, $eo0, $eo1);
	    (
		$self->{unknown}[0],
		$self->{unknown}[1],
		$self->{unknown}[2],
		$self->{unknown}[3],
		$self->{unknown}[4],
		$self->{lock},
		$self->{full},
		$self->{inRec},
		$self->{service},
		$self->{title},
		$self->{mjd},
		$self->{start},
		$self->{last},
		$self->{sec},
		$eo0, $eo1,
		$so0, $so1,
	    ) = unpack 'v5 C3 @1024 Z256 Z256 v x2 V v v @1548 (V2)2',
		    $hdr_data;
	    $self->endOffset(($eo1 << 32) | $eo0);
	    $self->offsets->[0] = (($so1 << 32) | $so0);
	    if($full) {
		my @offsets = unpack '@1564 (V2)' . ($self->last),
				    $hdr_data;
		while((my @o = splice(@offsets,0,2))) {
		    last if($o[0] == 0 && $o[1] == 0);
		    push @{$self->offsets}, (($o[1] << 32) | $o[0]);
		}
		my $nbkmk = unpack '@79316 v', $hdr_data;
		@offsets = unpack '@79336 (V2)' . $nbkmk, $hdr_data;
		for(my $i = 0; $i < $nbkmk; $i++ ) {
		    push @{$self->bookmarks},
			(($offsets[$i*2+1] << 32) | $offsets[$i*2]);
		}
	    }
	    return;
	}
    }

    $self->url(undef);
    @{$self->unknown} = ();

    foreach my $f (qw(url lock full inRec service
			title mjd start last sec)) {
	$_->{$f} = undef;
    }

    warn "Can't get header for ", $self->name, "\n";
}

1;
