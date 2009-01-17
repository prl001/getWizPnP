package Beyonwiz::Recording::Header;

=head1 NAME

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

=item C<HDR_SIZE>

Total size of the header (256kiB).

=item C<HDR_MAIN_OFF>

=item C<HDR_MAIN_SIZE>

=item C<HDR_OFFSETS_OFF>

=item C<HDR_OFFSETS_SIZE>

=item C<HDR_BOOKMARKS_OFF>

=item C<HDR_BOOKMARKS_SZ>

=item C<HDR_EPISODE_OFF>

=item C<HDR_EPISODE_SZ>

=item C<HDR_EXTINFO_OFF>

=item C<HDR_EXTINFO_SZ>

Offsets in the header and sizes for the sections of the header file.

=back

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Header->new() >>

Create a new Beyonwiz recording header object.

=item C<< $h->headerName([$val]); >>

Returns (sets) the name of the header document (path part only).

=item C<< $h->headerName([$val]); >>

Returns (sets) the name of the header document (path part only).

=item C<< $h->isTV; $h->isRadio; >>

Returns true if C<< $h->validMain; >> is true and the recording
is digital TV (resp digital radio). Both can return false if
C<< $h->headerName >> has not been set.

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
Returns the non-folder part of recording's index name if
it has no title set.

=item C<< $h->episode([$val]); >>

Returns (sets) the recording episode name (subtitle).

=item C<< $h->longTitle([$addEpisode[, $sep]]; >>

Returns C<< $h->title . '/' . $h->episode >> if the episode name
can be loaded and is non-empty, otherwise returns
C<< $h->title >>.
If C<$addEpisode> is specified and false, the episode name is not
added in ant case.
If C<$sep> is specified, it is used instead of C<'/'> as the separator
between title and episode name.

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

=item C<< $h->validMain; >>

=item C<< $h->validEpisode; >>

=item C<< $h->validExtInfo; >>

=item C<< $h->validBookmarks; >>

=item C<< $h->validOffsets; >>

Returns true if the last C<< $h->loadMain; >>
(resp. C<< $h->loadEpisode >>,
C<< $h->loadExtInfo >>,
C<< $h->loadBookmarks >>,
or  C<< $h->loadOffsets >>)
was successful.

=item C<< $h->size; >>

Returns the size of the header file (256kB).

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

=item C<<  $h->offsetTime($offset) >>

Convert an offset into a time. C<< $h->loadOffsets >> must have been called,
otherwise -1 is returned. Interpolates between values in the offset table.
Returns 0 if C<< $offset <= $self->offsets->[0] >> and
C<< $self->playtime >> if C<< $offset >= $self->endOffset >>.


=item C<< $h->loadMain; >>

=item C<< $h->loadEpisode; >>

=item C<< $h->loadExtInfo; >>

=item C<< $h->loadBookmarks; >>

=item C<< $h->loadOffsets; >>

Load parts of the header object from the header on the Beyonwiz.
C<< $h->loadMain >> loads the basics,
C<< $h->loadEpisode >> loads the episode name/subtitle informtion,
C<< $h->loadExtInfo >> loads the extended event informtion,
C<< $h->loadBookmarks >> loads the bookmark information
and C<< $h->loadOffsets >> loads the 10-second offset data.

=item C<< $h->decodeMain($hdr_data) >>

=item C<< $h->decodeEpisode($hdr_data) >>

=item C<< $h->decodeExtInfo($hdr_data) >>

=item C<< $h->decodeBookmarks($hdr_data) >>

=item C<< $h->decodeOffsets($hdr_data) >>

Decodes parts of the header object from C<$hdr_data> on the Beyonwiz.
The data for each part is assumed to satart at the beginning
of the respective C<$hdr_data>.

C<< $h->decodeMain >> decodes the basics,
C<< $h->decodeEpisode >> decodes the episode name/subtitle informtion,
C<< $h->decodeExtInfo >> decodes the extended event informtion,
C<< $h->decodeBookmarks >> decodes the bookmark information
and C<< $h->decodeOffsets >> decodes the 10-second offset data.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
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

use Beyonwiz::Utils;
use LWP::Simple qw(get $ua);
use URI;
use URI::Escape;

use constant DAY          => 24*60*60; # Seconds in a day
use constant TVHDR        => 'header.tvwiz';
use constant RADHDR       => 'header.radwiz';

use constant MAX_TS_POINT => 8640;
use constant HDR_SIZE     => 256 * 1024;

use constant HDR_MAIN_OFF      => 0;
use constant HDR_MAIN_SZ     => 1564;
use constant HDR_OFFSETS_OFF   => 1564;
use constant HDR_OFFSETS_SIZE  => (MAX_TS_POINT-1) * 8;
use constant HDR_BOOKMARKS_OFF => 79316;
use constant HDR_BOOKMARKS_SZ  => 20 + 64 * 8;
use constant HDR_EPISODE_OFF   => 79856;
use constant HDR_EPISODE_SZ   => 1 + 255;
use constant HDR_EXTINFO_OFF  => 80114;
use constant HDR_EXTINFO_SZ   => 2 + 1024;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
	DAY TVHDR RADHDR MAX_TS_POINT HDR_SIZE
	HDR_MAIN_OFF HDR_MAIN_SZ
	HDR_OFFSETS_OFF HDR_OFFSETS_SIZE
	HDR_BOOKMARKS_OFF HDR_BOOKMARKS_SZ
	HDR_EPISODE_OFF HDR_EPISODE_SZ
	HDR_EXTINFO_OFF HDR_EXTINFO_SZ
    );

my $accessorsDone;

sub new() {
    my ($class, $name, $path) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	validMain      => undef,
	validEpisode   => undef,
	validExtInfo   => undef,
	validBookmarks => undef,
	validOffsets   => undef,
	name           => $name,
	path           => $path,
	headerName     => undef,
	unknown        => [],
	lock           => undef,
	full           => undef,
	inRec          => undef,
	service        => undef,
	title          => undef,
	episode        => undef,
	extInfo        => undef,
	mjd            => undef,
	start          => undef,
	last           => undef,
	sec            => undef,
	endOffset      => undef,
	offsets        => [],
	bookmarks      => [],
    };

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return bless $self, $class;
}

sub unknown($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{unknown};
    $self->{unknown} = $val if(@_ == 2);
    return $ret;
}

sub lock($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{lock};
    $self->{lock} = $val if(@_ == 2);
    return $ret;
}

sub full($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{full};
    $self->{full} = $val if(@_ == 2);
    return $ret;
}

sub inRec($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{inRec};
    $self->{inRec} = $val if(@_ == 2);
    return $ret;
}

sub service($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{service};
    $self->{service} = $val if(@_ == 2);
    return $ret;
}

sub title($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{title};
    if(!defined($self->{title}) || $self->{title} eq '') {
	$ret = $self->name;
	$ret =~ s,^.*\/,,;
    }
    $self->{title} = $val if(@_ == 2);
    return $ret;
}

sub episode($;$) {
    my ($self, $val) = @_;
    $self->loadEpisode if(!$self->validEpisode);
    my $ret = $self->{episode};
    $self->{episode} = $val if(@_ == 2);
    return $ret;
}

sub extInfo($;$) {
    my ($self, $val) = @_;
    $self->loadExtInfo if(!$self->validExtInfo);
    my $ret = $self->{extInfo};
    $self->{extInfo} = $val if(@_ == 2);
    return $ret;
}

sub mjd($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{mjd};
    $self->{mjd} = $val if(@_ == 2);
    return $ret;
}

sub start($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{start};
    $self->{start} = $val if(@_ == 2);
    return $ret;
}

sub last($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{last};
    $self->{last} = $val if(@_ == 2);
    return $ret;
}

sub sec($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{sec};
    $self->{sec} = $val if(@_ == 2);
    return $ret;
}

sub endOffset($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{endOffset};
    $self->{endOffset} = $val if(@_ == 2);
    return $ret;
}

sub offsets($;$) {
    my ($self, $val) = @_;
    $self->loadOffsets if(!$self->validOffsets);
    my $ret = $self->{offsets};
    $self->{offsets} = $val if(@_ == 2);
    return $ret;
}

sub bookmarks($;$) {
    my ($self, $val) = @_;
    $self->loadBookmarks if(!$self->validBookmarks);
    my $ret = $self->{bookmarks};
    $self->{bookmarks} = $val if(@_ == 2);
    return $ret;
}

sub longTitle($;$$) {
    my ($self, $addEpisode, $sep) = @_;
    $addEpisode = 1 if(@_ < 2);
    return $self->title if(!$addEpisode);
    $sep = '/' if(@_ < 3);
    my $episode = $self->episode;
    return defined($episode) && $episode ne ''
		? $self->title . $sep . $episode
		: $self->title;
}

sub isTV($) {
    my ($self) = @_;
    return defined($self->headerName)
        && $self->headerName eq Beyonwiz::Recording::Header::TVHDR;
}

sub isRadio($) {
    my ($self) = @_;
    return defined($self->headerName)
        && $self->headerName eq Beyonwiz::Recording::Header::RADHDR;
}

sub startOffset($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{offsets}->[0];
    $self->{offsets}->[0] = $val if(@_ == 2);
    return $ret;
}

sub noffsets($) {
    my ($self) = @_;
    return scalar @{$self->offsets};
}

sub nbookmarks($) {
    my ($self) = @_;
    return scalar @{$self->bookmarks};
}

sub validMain($) {
    my ($self) = @_;
    return $self->{validMain};
}

sub validEpisode($) {
    my ($self) = @_;
    return $self->{validEpisode};
}

sub validExtInfo($) {
    my ($self) = @_;
    return $self->{validExtInfo};
}

sub validBookmarks($) {
    my ($self) = @_;
    return $self->{validBookmarks};
}

sub validOffsets($) {
    my ($self) = @_;
    return $self->{validOffsets};
}

sub size($) {
    my ($self) = @_;
    return HDR_SIZE;
}

sub playtime($) {
    my ($self) = @_;
    # Magic formula from WizFX code
    return $self->last*10 + $self->sec;
}

sub starttime($) {
    my ($self) = @_;
    # Unix epoch, 00:00 1 Jan 1970 UTC, is 40587 days after MJD epoch,
    # 00:00 17 Nov 1858.
    return ($self->mjd - 40587) * DAY + $self->start;
}

sub offsetTime($$) {
    my ($self, $offset) = @_;

    return 0 if($offset <= $self->startOffset);
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

sub decodeMain($$) {
    my ($self, $hdr_data) = @_;

    if(defined $hdr_data
    && length($hdr_data) >= HDR_MAIN_SZ) {
	my ($so0, $so1, $eo0, $eo1);
	(
	    $self->{unknown}[0],
	    $self->{unknown}[1],
	    $self->{unknown}[2],
	    $self->{unknown}[3],
	    $self->{unknown}[4],
	    $self->{unknown}[5],
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
	) = unpack 'v6 C3 @1024 Z256 Z256 v x2 V v v @1548 (V2)2',
		$hdr_data;
	$self->{validMain} = 1;
	$self->endOffset(($eo1 << 32) | $eo0);
	$self->{offsets}->[0] = (($so1 << 32) | $so0);
    } else {
	$self->{validMain} = 0;
	@{$self->{unknown}} = ();
    }
}

sub decodeEpisode($$) {
    my ($self, $hdr_data) = @_;

    if(defined $hdr_data
    && length($hdr_data) >= HDR_EPISODE_SZ) {
	my $len = unpack 'C', $hdr_data;
	$len = HDR_EPISODE_SZ if($len > HDR_EPISODE_SZ);
	my $episode = unpack '@1 Z' . $len, $hdr_data;
	$episode =~ s/^\s+//;
	$episode =~ s/\s+$//;
	$self->{validEpisode} = 1;
	$self->episode($episode);
    } else {
	$self->{validEpisode} = 0;
	$self->episode(undef);
    }
}

sub decodeExtInfo($$) {
    my ($self, $hdr_data) = @_;

    if(defined $hdr_data
    && length($hdr_data) >= HDR_EXTINFO_SZ) {
	my $len = unpack 'v', $hdr_data;
	$len = HDR_EXTINFO_SZ if($len > HDR_EXTINFO_SZ);
	my $extInfo = unpack '@2 Z' . $len, $hdr_data;
	$self->{validExtInfo} = 1;
	$self->extInfo($extInfo);
    } else {
	$self->{validExtInfo} = 0;
	$self->extInfo(undef);
    }
}

sub decodeBookmarks($$) {
    my ($self, $hdr_data) = @_;

    if(defined $hdr_data
    && length($hdr_data) >= HDR_BOOKMARKS_SZ) {
	my $nbkmk = unpack 'v', $hdr_data;
	my @offsets = unpack '@20 (V2)' . $nbkmk, $hdr_data;
	for(my $i = 0; $i < $nbkmk; $i++ ) {
	    push @{$self->bookmarks},
		(($offsets[$i*2+1] << 32) | $offsets[$i*2]);
	}
	$self->{validBookmarks} = 1;
    } else {
	$self->{validBookmarks} = 0;
	@{$self->bookmarks} = ();
    }
}

sub decodeOffsets($$) {
    my ($self, $hdr_data) = @_;

    if(defined $hdr_data
    && length($hdr_data) >= HDR_OFFSETS_SIZE) {
	my @offsets = unpack '(V2)' . ($self->last),
			    $hdr_data;
	$self->{validOffsets} = 1;
	while((my @o = splice(@offsets,0,2))) {
	    last if($o[0] == 0 && $o[1] == 0);
	    push @{$self->{offsets}}, (($o[1] << 32) | $o[0]);
	}
    } else {
	$self->{validOffsets} = 0;
	@{$self->{offsets}} = ();
    }
}

sub loadMain($) {
    my ($self) = @_;
    $self->decodeMain(
	    $self->readHdrChunk(HDR_MAIN_OFF, HDR_MAIN_SZ)
	);
}

sub loadEpisode($) {
    my ($self) = @_;
    $self->decodeEpisode(
	    $self->readHdrChunk(HDR_EPISODE_OFF, HDR_EPISODE_SZ)
	);
}

sub loadExtInfo($) {
    my ($self) = @_;
    $self->decodeExtInfo(
	    $self->readHdrChunk(HDR_EXTINFO_OFF, HDR_EXTINFO_SZ)
	);
}

sub loadBookmarks($) {
    my ($self) = @_;
    $self->decodeBookmarks(
	    $self->readHdrChunk(HDR_BOOKMARKS_OFF, HDR_BOOKMARKS_SZ)
	);
}

sub loadOffsets($) {
    my ($self) = @_;
    $self->decodeOffsets(
	    $self->readHdrChunk(HDR_OFFSETS_OFF, HDR_OFFSETS_SIZE)
	);
}

1;
