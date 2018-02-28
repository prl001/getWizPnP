package Beyonwiz::Recording::Header;

my $Copyright = 'Copyright 2008-2018 Peter Lamb.
See accompanying LICENSE file for redistribution conditions.';

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

=item C<< Beyonwiz::Recording::Header->new($accessor, $ie) >>

Create a new Beyonwiz recording header object.
C<$accessor> is a reference to a
L<C<Beyonwiz::Recording::Accessor>|Beyonwiz::Recording::Accessor>
used to carry out the media file access functions in
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>.
<$ie> is a reference to a 
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>
used to retrieve name and path information for the recording.

=item C<< $h->accessor([$val]); >>

Returns (sets) the media file accessor object reference.

=item C<< $h->ie([$val]); >>

Returns (sets) the associated
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.

=item C<< $h->path; >>

Returns folder name part of the path in the associated
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.

=item C<< $h->name; >>

Returns index name in the associated
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.

=item C<< $h->headerName([$val]); >>

Returns (sets) the name of the header document (file name part only).

=item C<< $h->magic([$val]); >>

Returns (sets) the header magic number (0x1062). Returns C<undef>
if the header is for a media file.

=item C<< $h->version([$val]); >>

Returns (sets) the header version number (0x1062). Returns C<undef>
if the header is for a media file.

=item C<< $h->pids([$val]); >>

Returns (sets) a reference to a list of Packet IDs (PIDs) for the recording.
C<< $h->pids->[0] >> is the video PID,
C<< $h->pids->[1] >> is the main audio pid,
C<< $h->pids->[2] >> is the Program Clock Reference (PCR) PID and
C<< $h->pids->[3] >> is the Program Map table PID for the recorded program.
Returns C<[0, 0, 0, 0]>
if the header is for a media file.

The lowest-order 13 bits of the values contain the PID
C<< $h->pids->[$n] & 0x1fff >>.
The remaining bits are reserved for flags.
The only known flag is C<0x8000> in the main audio PID,
which indicates that the audio AC3 (rather than MPEG-2).

=item C<< $h->pid($n); >>
=item C<< $h->pidFlags($n); >>

Two utility that return, respectively,
C<< $h->pids->[$n] & 0x1fff >>
and
C<< $h->pids->[$n] & ~0x1fff >>,
the corresponding true PID value from C<< $h->pids->[$n] >>
and the flags component.

Both methods return 0 if the header is not for a Beyonwiz recording.

=item C<< $h->isTV; $h->isRadio; $h->isMediaFolder $h->isMediaFile >>

Returns true if C<< $h->validMain; >> is true and the recording
is respectively digital TV, digital radio,
a Beyonwiz folder format for large media files,
or a single media file.
All can return false if
C<< $h->headerName >> has not been set.

=item C<< $h->lock([$val]); >>

Returns (sets) the flag implementing the Beyonwiz File Lock on
the recording.

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
Any leading ASCII control characters (0x00-0x1f) in the header value
are stripped off.

=item C<< $h->episode([$val]); >>

Returns (sets) the recording episode name (subtitle).
Any leading ASCII control characters (0x00-0x1f) in the header value
are stripped off.

In free-to-air EPGs, this field is sometimes used as the program
synopsis (see C<< $h->extInfo >>), rather than the episode name.

=item C<< $h->extInfo([$val]); >>

Returns (sets) the recording extended information (program synopsis).
Any leading ASCII control characters (0x00-0x1f) in the header value
are stripped off.

=item C<< $h->longTitle([$addEpisode[, $sep]]; >>

Returns C<< $h->title . '/' . $h->episode >> if the episode name
can be loaded and is non-empty, otherwise returns
C<< $h->title >>.
If C<$addEpisode> is specified and false, the episode name is not
added in any case.
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

=item C<< $s->reconstructed([$val]); >>

Returns (sets) a flag marking that the object represents a reconstructed
file, and the file should be encoded from the object rather than being
copied from the source.

There is no general reconstruction method for
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>,
but reconstruction of other headers may need to modify the header object,
and they should set this flag when the header is modified.


Reset by any call of C<< $h->loadMain >>,
C<< $h->loadEpisode >>,
C<< $h->loadExtInfo >>,
C<< $h->loadBookmarks >>,
or  C<< $h->loadOffsets >>.

=item C<< $h->size; >>

Returns the size of the header file (256kB).

=item C<< $h->playtime >>

A convenience method that returns the duration of
the recording in seconds.

=item C<< $h->fileLenTime([$file]) >>

Return the tuple I<($len, $modifyTime)> for the trunc file.
The modify time is a Unix timestamp (seconds since 00:00:00) Jan 1 1970 UTC).
If C<$file> is specified, use that as the name of the trunc file,
otherwise use C<$t->headerName> for the name of the file.
Returns C<undef> if the data can't be found
(access denied or file not found).

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

=item C<<  $h->updateOffsets($newStart, $newEnd) >>

Update the offsets so that C<< $h->endOffset; >> is set to C<$newEnd>
and the offset table is adjusted to start at C<$newStart>.
Intended to be used when the trunc header has been reconstructed.

=item C<< $h->loadMain; >>

=item C<< $h->loadHdrWmmeta; >>

=item C<< $h->loadHdrFile; >>

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

C<< $h->loadHdrWmmeta; >> and C<< $h->loadHdrFile; >> load as
much of the header as possible with information about media
content either in the Beyonwiz folder format for large
files (C<< $h->loadHdrWmmeta; >>),
or in single files (C<< $h->loadHdrFile; >>).

=item C<< $h->decodeMain($hdr_data) >>

=item C<< $h->decodeEpisode($hdr_data) >>

=item C<< $h->decodeExtInfo($hdr_data) >>

=item C<< $h->decodeBookmarks($hdr_data) >>

=item C<< $h->decodeOffsets($hdr_data) >>

Decodes parts of the header object from C<$hdr_data> on the Beyonwiz.
The data for each part is assumed to satart at the beginning
of the respective C<$hdr_data>.

=item C<< $h->encodeMain >>

=item C<< $h->encodeEpisode >>

=item C<< $h->encodeExtInfo >>

=item C<< $h->encodeBookmarks >>

=item C<< $h->encodeOffsets >>

Encodes parts of the header object ready for writing back
to a header file. The methods encode the corresponding data to the decode
functions above.

=item C<< $h->encodeMain >>

Encodes the header object ready for writing back
to a header file.

=back

=head1 INTERNAL METHODS

=over

=item C<< $h->_setUnixTime($time); >>

Set C<< $h->mjd([$val]); >> and C<< $h->start([$val]); >>
from the given Unix time (seconds since 00:00:00 Jan 1 1097 UTC).

=item C<< $h->_setMainMediaFile($size, $time); >>

Set as many fields as possible to reasonable values given the
size and timestamp of a media file.

=item C<< $h->_readHdrChunk($offset, $size); >>

Read a chunk of the header file.
Reads from C<< $h->headerName([$val]); >> if it
is defined, otherwise tries reading from
C<L</TVHDR>> then C<L</RADHDR>> and sets
the header name from the first to succeed.
Reads C<$size> bytes at byte offst C<$offset>
from the start of the header file.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>;
C<LWP::Simple>,
C<URI>,
C<URI::Escape>,
C<Time::Local>,
C<File::Basename>.

=head1 BUGS

Uses C<bignum> for 64-bit integers, even when the underlying
Perl integers are 64 bits.

The bugs to do with time are in the Beyonwiz.

=cut


use warnings;
use strict;
use bignum;

use Beyonwiz::Utils;
use Beyonwiz::Recording::Trunc qw(WMMETA);
use LWP::Simple qw(get $ua);
use URI;
use URI::Escape;
use Time::Local;
use File::Basename;

use constant DAY          => 24*60*60; # Seconds in a day
use constant TVEXT        => '.tvwiz';
use constant TVHDR        => 'header' . TVEXT;
use constant RADEXT       => '.radwiz';
use constant RADHDR       => 'header' . RADEXT;

use constant MAX_TS_POINT => 8640;
use constant HDR_SIZE     => 256 * 1024;
use constant MAX_BOOKMARKS=> 64;

use constant HDR_MAIN_OFF      => 0;
use constant HDR_MAIN_SZ       => 1564;
use constant HDR_OFFSETS_OFF   => 1564;
use constant HDR_OFFSETS_SIZE  => (MAX_TS_POINT-1) * 8;
use constant HDR_BOOKMARKS_OFF => 79316;
use constant HDR_BOOKMARKS_SZ  => 20 + MAX_BOOKMARKS * 8;
use constant HDR_EPISODE_OFF   => 79856;
use constant HDR_EPISODE_SZ    => 1 + 255;
use constant HDR_EXTINFO_OFF   => 80114;
use constant HDR_EXTINFO_SZ    => 2 + 1024;

use constant HEADER_DATA_OFF  => HDR_MAIN_OFF;
use constant HEADER_DATA_SZ   => HDR_EXTINFO_OFF + HDR_EXTINFO_SZ;

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

sub new($$$) {
    my ($class, $accessor, $ie) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	accessor	=> $accessor,
	validData	=> undef,
	validMain	=> undef,
	validEpisode	=> undef,
	validExtInfo	=> undef,
	validBookmarks	=> undef,
	validOffsets	=> undef,
	reconstructed	=> undef,
	ie		=> $ie,
	data		=> undef,
	headerName	=> undef,
	magic		=> undef,
	version		=> undef,
	pids		=> [],
	lock		=> undef,
	full		=> undef,
	inRec		=> undef,
	autoDelete	=> undef,
	autoDeleteFlags	=> undef,
	service		=> undef,
	title		=> undef,
	episode		=> undef,
	extInfo		=> undef,
	mjd		=> undef,
	start		=> undef,
	last		=> undef,
	sec		=> undef,
	endOffset	=> undef,
	offsets		=> [],
	bookmarks	=> [],
    };

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return bless $self, $class;
}

sub magic($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{magic};
    $self->{magic} = $val if(@_ == 2);
    return $ret;
}

sub version($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{version};
    $self->{version} = $val if(@_ == 2);
    return $ret;
}

sub headerName($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{headerName};
    $self->{headerName} = $val if(@_ == 2);
    return $ret;
}

sub pids($;$) {
    my ($self, $val) = @_;
    $self->loadMain if(!$self->validMain);
    my $ret = $self->{pids};
    $self->{pids} = $val if(@_ == 2);
    return $ret;
}

sub pid($$) {
    my ($self, $p) = @_;
    my $pids = $self->pids;
    return undef if(!defined $pids);
    return $pids->[$p] & 0x1fff;
}

sub pidFlags($$) {
    my ($self, $p) = @_;
    my $pids = $self->pids;
    return undef if(!defined $pids);
    return $pids->[$p] & ~0x1fff;
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
        && $self->headerName eq TVHDR;
}

sub isRadio($) {
    my ($self) = @_;
    return defined($self->headerName)
        && $self->headerName eq RADHDR;
}

sub isMediaFolder($) {
    my ($self) = @_;
    return defined($self->headerName)
        && $self->headerName eq WMMETA;
}

sub isMediaFile($) {
    my ($self) = @_;
    return defined($self->headerName)
	&& !$self->isTV
	&& !$self->isRadio
	&& !$self->isMediaFolder
}

sub path($) {
    my ($self) = @_;
    $self->ie->path;
}

sub name($) {
    my ($self) = @_;
    $self->ie->name;
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
    return ($self->last >= 0 && $self->sec >= 0)
		? $self->last*10 + $self->sec
		: -1;
}

sub fileLenTime($$) {
    my ($self, $file) = @_;
    if(@_ >= 2) {
	return $self->accessor->fileLenTime($self->path, $file);
    }
    return $self->accessor->fileLenTime($self->path, $self->headerName);
}

sub starttime($) {
    my ($self) = @_;
    # Unix epoch, 00:00 1 Jan 1970 UTC, is 40587 days after MJD epoch,
    # 00:00 17 Nov 1858.
    return ($self->mjd - 40587) * DAY + $self->start;
}

sub _setUnixTime($$) {
    my ($self, $time) = @_;
    if(defined $time) {
	my ($sec,$min,$hour,$mday,$mon,$year) = localtime $time;
	$time = timegm $sec,$min,$hour,$mday,$mon,$year;
    } else {
	$time = time;
    }
    $self->mjd(int($time / DAY) + 40587);
    $self->start($time % DAY);
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

    return 10 * $index + $dt * ($offset - $low) / ($high - $low);
}

sub updateOffsets($$$) {
    my ($self, $newStart, $newEnd) = @_;
    my $byteRate = ($self->endOffset - $self->startOffset) / $self->playtime;
    # startOffset is updated in the loop, because it's $self->offsets->[0]
    my $diff = $newStart - $self->startOffset;
    if($diff != 0) {
	foreach my $o (0..$self->last) {
	    $self->offsets->[$o] += $diff;
	}
    }
    for(my $off =  $self->last + 1;
        int($off * 10 * $byteRate) <= $newEnd;
	$off++) {
	push @{$self->offsets}, int($off * 10 * $byteRate);
    }
    $self->last($#{$self->offsets});
    $self->sec(int(($newEnd - $self->offsets->[$self->last]) / $byteRate));
    $self->endOffset($newEnd);
    $self->reconstructed(1);
}

sub decodeMain($) {
    my ($self) = @_;

    $self->{reconstructed} = undef;
    if(defined $self->data
    && length($self->data) >= HDR_MAIN_OFF+HDR_MAIN_SZ) {
	my ($ad0, $ad1, $so0, $so1, $eo0, $eo1);
	(
	    $self->{magic},
	    $self->{version},
	    $self->{pids}[0],
	    $self->{pids}[1],
	    $self->{pids}[2],
	    $self->{pids}[3],
	    $self->{lock},
	    $self->{full},
	    $self->{inRec},
	    $ad0, $ad1,
	    $self->{service},
	    $self->{title},
	    $self->{mjd},
	    $self->{start},
	    $self->{last},
	    $self->{sec},
	    $eo0, $eo1,
	    $so0, $so1,
	) = unpack 'v6 C3 x C2 @1024 Z256 Z256 v x2 V v v @1548 (V2)2',
		substr $self->data, HDR_MAIN_OFF, HDR_MAIN_SZ;
	$self->{validMain} = 1;
	$self->endOffset(($eo1 << 32) | $eo0);
	$self->{offsets}->[0] = (($so1 << 32) | $so0);
	$self->{autoDelete} = (($ad0 & 0xf0) << 4) | $ad1;
	$self->{autoDeleteFlags} = $ad0 & 0xf;
	$self->{title} =~ s/^[\x00-\x1f]+//;
    } else {
	$self->{validMain} = 0;
    }
}

sub encodeMain($) {
    my ($self) = @_;

    my $hdr_data = pack 'v6 C3 x C2 @1024 Z256 Z256 v x2 V v v @1548 (V2)2', (
	$self->magic,
	$self->version,
	$self->pids->[0],
	$self->pids->[1],
	$self->pids->[2],
	$self->pids->[3],
	$self->lock,
	$self->full,
	$self->inRec,
	$self->autoDeleteFlags | (($self->autoDelete >> 4) & 0xf0),
	$self->autoDelete & 0xff,
	$self->service,
	$self->title,
	$self->mjd,
	$self->start,
	$self->last,
	$self->sec,
	$self->endOffset & 0xffffffff,
	($self->endOffset >> 32) & 0xffffffff,
	$self->offsets->[0] & 0xffffffff,
	($self->offsets->[0] >> 32) & 0xffffffff,
    );
    return $hdr_data;
}

sub decodeEpisode($) {
    my ($self) = @_;

    $self->{reconstructed} = undef;

    if(defined $self->data
    && length($self->data) >= HDR_EPISODE_OFF + HDR_EPISODE_SZ) {
	my $len = unpack 'C',
		    substr $self->data, HDR_EPISODE_OFF, 1;
	$len = HDR_EPISODE_SZ - 1 if($len > HDR_EPISODE_SZ - 1);
	my $episode = unpack 'Z' . $len,
			substr $self->data, HDR_EPISODE_OFF + 1,
						HDR_EPISODE_SZ - 1;
	$episode =~ s/^[\x00-\x1f]+//;
	$episode =~ s/^\s+//;
	$episode =~ s/\s+$//;
	$self->{validEpisode} = 1;
	$self->episode($episode);
    } else {
	$self->{validEpisode} = 0;
	$self->episode(undef);
    }
}

sub encodeEpisode($) {
    my ($self) = @_;

    my $hdr_data = pack 'C Z' . (HDR_EPISODE_SZ - 1) , (
	length $self->episode, $self->episode
    );
    return $hdr_data;
}

sub decodeExtInfo($) {
    my ($self) = @_;

    $self->{reconstructed} = undef;

    if(defined $self->data
    && length($self->data) >= HDR_EXTINFO_OFF + HDR_EXTINFO_SZ) {
	my $len = unpack 'v', substr $self->data, HDR_EXTINFO_OFF, 2;
	$len = HDR_EXTINFO_SZ - 2 if($len > HDR_EXTINFO_SZ - 2);
	my $extInfo = unpack 'Z' . $len,
			substr $self->data, HDR_EXTINFO_OFF + 2,
						HDR_EXTINFO_SZ - 2;
	$extInfo =~ s/^[\x00-\x1f]+//;
	$self->{validExtInfo} = 1;
	$self->extInfo($extInfo);
    } else {
	$self->{validExtInfo} = 0;
	$self->extInfo(undef);
    }
}

sub encodeExtInfo($) {
    my ($self) = @_;

    my $hdr_data = pack 'v Z' . (HDR_EXTINFO_SZ - 2) , (
	length $self->extInfo, $self->extInfo
    );
    return $hdr_data;
}

sub decodeBookmarks($) {
    my ($self) = @_;

    $self->{reconstructed} = undef;
    @{$self->{bookmarks}} = ();
    if(defined $self->data
    && length($self->data) >= HDR_BOOKMARKS_OFF + HDR_BOOKMARKS_SZ) {
	my $nbkmk = unpack 'v', substr $self->data, HDR_BOOKMARKS_OFF, 2;
	my @offsets = unpack '(V2)' . $nbkmk,
			substr $self->data, HDR_BOOKMARKS_OFF+20,
						HDR_BOOKMARKS_SZ-20;
	if($nbkmk > MAX_BOOKMARKS) {
	    warn 'Too many bookmarks. Found ', $nbkmk,
		 '. Should be no more than ', MAX_BOOKMARKS, "\n";
	    $nbkmk = MAX_BOOKMARKS;
	}
	for(my $i = 0; $i < $nbkmk; $i++ ) {
	    push @{$self->{bookmarks}},
		(($offsets[$i*2+1] << 32) | $offsets[$i*2]);
	}
	$self->{validBookmarks} = 1;
    } else {
	$self->{validBookmarks} = undef;
    }
}

sub encodeBookmarks($$) {
    my ($self) = @_;

    my $hdr_data = pack 'v @20', $self->nbookmarks;
    foreach my $b (@{$self->bookmarks}) {
	$hdr_data .= pack 'V2', $b & 0xffffffff, ($b >> 32) & 0xffffffff;
    }
    $hdr_data .= "\0" x (HDR_BOOKMARKS_SZ - length $hdr_data);
    return $hdr_data;
}

sub decodeOffsets($) {
    my ($self) = @_;

    $self->{reconstructed} = undef;
    if(defined $self->data
    && length($self->data) >= HDR_OFFSETS_OFF + HDR_OFFSETS_SIZE) {
	my @offsets = unpack '(V2)' . ($self->last),
			    substr $self->data, HDR_OFFSETS_OFF,
			    			HDR_OFFSETS_SIZE;
	$self->{validOffsets} = 1;
	while((my @o = splice(@offsets,0,2))) {
	    last if($o[0] == 0 && $o[1] == 0);
	    push @{$self->{offsets}}, (($o[1] << 32) | $o[0]);
	}
    } else {
	$self->{validOffsets} = undef;
	@{$self->{offsets}} = ($self->{offsets}[0]);
    }
}

sub encodeOffsets($) {
    my ($self) = @_;

    my $hdr_data = '';
    for(my $o = 1; $o < $self->noffsets; $o++) {
	my $off = $self->offsets->[$o];
	$hdr_data .= pack 'V2', $off & 0xffffffff, ($off >> 32) & 0xffffffff;
    }
    $hdr_data .= "\0" x (HDR_OFFSETS_SIZE - length $hdr_data);
    return $hdr_data;
}

sub encodeHeader($) {
    my ($self) = @_;
    return
	  $self->encodeMain
	. ("\0" x (HDR_OFFSETS_OFF - (HDR_MAIN_OFF + HDR_MAIN_SZ)))
	. $self->encodeOffsets
	. ("\0" x (HDR_BOOKMARKS_OFF - (HDR_OFFSETS_OFF + HDR_OFFSETS_SIZE)))
	. $self->encodeBookmarks
	. ("\0" x (HDR_EPISODE_OFF - (HDR_BOOKMARKS_OFF + HDR_BOOKMARKS_SZ)))
	. $self->encodeEpisode
	. ("\0" x (HDR_EXTINFO_OFF - (HDR_EPISODE_OFF + HDR_EPISODE_SZ)))
	. $self->encodeExtInfo
	. ("\0" x (HDR_SIZE - (HDR_EXTINFO_OFF + HDR_EXTINFO_SZ)));
}

sub _setMainMediaFile($$$) {
    my ($self, $size, $time)= @_;
    $self->{magic}		 = undef,
    $self->{version}		 = undef,
    @{$self->{pids}}		 = [0, 0, 0, 0],
    $self->{autoDelete}		 = undef,
    $self->{autoDeleteFlags}	 = undef,
    $self->{lock}		 = 0;
    $self->{full}		 = 0;
    $self->{inRec}		 = 0;
    $self->{service}		 = 'Content';
    $self->{title}		 = basename($self->name);
    $self->{last}		 = -1;
    $self->{sec}		 = -1;
    $self->{validMain}		 = 1;
    $self->endOffset($size);
    $self->{offsets}->[0]	 = 0;
    $self->_setUnixTime($time);

    $self->{reconstructed}	 = undef;

    $self->{validEpisode}	 = 1;
    $self->episode('');

    $self->{validExtInfo}	 = 1;
    $self->extInfo('');

    $self->{validBookmarks}	 = 1;
    @{$self->{bookmarks}}	 = ();

    $self->{validOffsets}	 = 1;
    $self->size(0);
}

sub loadHdrWmmeta() {
    my ($self) = @_;
    if(substr($self->path, -4, 4) eq '.wiz') {
	my ($size, $time) = $self->accessor->fileLenTime($self->path, WMMETA);
	if(defined $size) {
	    my $trunc = Beyonwiz::Recording::Trunc->new(
					    $self->accessor,
					    $self->name, $self->path
					);
	    $trunc->load;
	    if($trunc->fileName eq WMMETA) {
		$self->_setMainMediaFile($trunc->recordingSize, $time)
		    if($trunc->valid);
		$self->{headerName} = $trunc->fileName;
	    }
	}
    }
}

sub loadHdrFile() {
    my ($self) = @_;
    if(substr($self->path, -length(TVEXT)) ne TVEXT
    && substr($self->path, -length(RADEXT)) ne RADEXT) {
	my ($size, $time) = $self->accessor->fileLenTime($self->path);
	if(defined $size) {
	    $self->_setMainMediaFile($size, $time);
	    $self->{headerName} = '';
	}
    }
}

sub loadHdrData($) {
    my ($self) = @_;
    $self->data($self->_readHdrChunk(HEADER_DATA_OFF, HEADER_DATA_SZ))
	if(!$self->validData);
    $self->validData(defined($self->data));
}

sub loadMain($) {
    my ($self) = @_;
    $self->loadHdrFile;
    if(!$self->validMain) {
	$self->loadHdrData;
	$self->decodeMain(HDR_MAIN_OFF, HDR_MAIN_SZ)
	    if($self->validData);
    }
    $self->loadHdrWmmeta if(!$self->validMain);
}

sub loadEpisode($) {
    my ($self) = @_;
    if(!$self->validEpisode) {
	$self->loadHdrData;
	$self->decodeEpisode(HDR_EPISODE_OFF, HDR_EPISODE_SZ)
	    if($self->validData);
    }
}

sub loadExtInfo($) {
    my ($self) = @_;
    if(!$self->validExtInfo) {
	$self->loadHdrData;
	$self->decodeExtInfo(HDR_EXTINFO_OFF, HDR_EXTINFO_SZ)
	    if($self->validData);
    }
}

sub loadBookmarks($) {
    my ($self) = @_;
    if(!$self->validBookmarks) {
	$self->loadHdrData;
	$self->decodeBookmarks(HDR_BOOKMARKS_OFF, HDR_BOOKMARKS_SZ)
	    if($self->validData);
    }
}

sub loadOffsets($) {
    my ($self) = @_;
    $self->decodeOffsets(
	    $self->_readHdrChunk(HDR_OFFSETS_OFF, HDR_OFFSETS_SIZE)
	);
    if(!$self->validOffsets) {
	$self->loadHdrData;
	$self->decodeOffsets(HDR_OFFSETS_OFF, HDR_OFFSETS_SIZE)
	    if($self->validData);
    }
}

sub _readHdrChunk($$$) {
    my ($self, $offset, $size) = @_;

    foreach my $h (defined($self->{headerName})
			? ($self->headerName) : (TVHDR, RADHDR)) {

        my $hdr_data = $self->accessor->readFileChunk(
					$offset, $size, $self->path, $h
				    );

	if(defined($hdr_data) && length($hdr_data) > 0) {
	    $self->{headerName} = $h;
	    return $hdr_data;
	}

    }
    $self->{headerName} = undef;
    return '';
}

1;
