#!/usr/bin/perl -w

=head1 NAME

getWizPnP - list and fetch recordings from a Beyonwiz DP series over the network using the WizPnP interface


=head1 SYNOPSIS

    getWizPnP [-h|--help] [-D dev|--device dev] [-m devs|--maxdev=devs]
              [-h host|--host=host] [-p port|--port=port]
              [-l|--list] [-L|--List] [-d|--date] [-t|--ts] [-v|--verbose]
	      [-R|--resume] [-f|--f]
              [-r|--regexp] [-e|--expression] [-B|--BWName]
	      [-O dir|--outdir dir] [-I dir |--indir=dir]
              [ patterns... ]

=head1 DESCRIPTION

List or fetch the recordings on a Beyonwiz DP series PVR over the network
using the WizPnP interface.

If no pattern arguments are given, then all recordings are listed.
Otherwise recordings matching any of the patterns are fetched
(or listed, with B<--list>).

In the absence of B<--regexp> or B<--expression> a pattern matches
if it is a substring of the string I<servicename>B<#>I<longtitle>#I<date>,
case insensitive.
The I<longtitle> is just the title if the header has no episode information,
otherwise it is I<title>B</>I<episodename>.

For example:

    SC10 Canberra#MOVIE: Pride & Prejudice#Fri Feb 15 20:28:00 2008

or

    WIN TV Canberra#Underbelly/Team Purana#Wed May  7 20:28:00 2008

To download all recordings, an empty string will match everything:

    wizGetPnP ''

Recordings are downloaded to a name corresponding to their event name (title)
with any characters that are illegal in the file system changed to '_'.
The episode name isn't used.
The B<--date> option adds the day and date of the recording to the name,
helpful for series recordings.
Downloaded recordings are placed in the current directory.

When listing recordings, recordings that are currently recording are flagged
with C<*RECORDING NOW> next to the recording name.
The tag is not part of the name for matching.
I<GetWizPnP> won't fetch recordings that are currently in progress.

=head1 ARGUMENTS

B<GetWizPnP> takes the following arguments:

=over 4

=item help

  --help
  -h

Print a short help message and exit (overrides all other options).

=item device

  --device=dev
  -D device

Connect to the WizPnP I<device> as named in the Beyonwiz
C<<<< Setup>Network>WizPnP>Name >>>>.

If no I<device> is named and the WizPnP search finds only one
WizPnP device, that device is used.
Otherwise, if a device is named but isn't found, I<getWizPnP>
returns with an error. Device name matching is case-insensitive
(C<MyBeyonwiz> matches C<mybeyonwiz>).

B<Note:> There is a problem with the implementation of this function
and it can take up to 60 seconds (average 30 seconds) to search
for the WizPnP devices on the network.
Until this problem is fixed, you may prefer to use the --host option.

=item

  --maxdevs=devs
  -D devs

In a WizPnP search, stop searching when the number of WizPnP
devices found is I<devs>, rather than waiting for the search to
time out (currently 60 seconds). I<Devs> defaults to 1.

=item host

  --host=host
  -h host

Connect to the I<host> (DNS name or dotted-quad IP address) instead of using
WizPnP search to find the Beyonwiz, or instead of the default set in the
configuration file (see FILES below).

If the device name is specified with B<--device> then the configuration
returned by I<host> that contains the WizPnP name of the device must match
(case insensitive) the device name given by B<--device>.

=item port

  --port=port
  -p port

Connect to the I<port> instead of the
file default (C<49152>), or the default set in the configuration
file (see FILES below).
I<port> is ignored unless B<--host> is set.

=item list

  --list
  -l

List the matching recordings, rather than downloading them.

=item date

  --date
  -d

Add the recording day and date to the name of the
recording when it's downloaded.
Useful for downloading series.

=item ts

  --ts
  -t
  --nots
  --not

Download the recordings as single C<.ts> (MPEG Transport Stream) files,
rather than copying in the Beyonwiz internal recording format.

B<--nots> and B<--not> undo the setting of this option;
useful if this option is set by default in the user's C<.getwizpnp> file.

=item resume

  --resume
  -R
  --noresume
  --noR

Allow resumption of downloading of recordings that appear to be incomplete.

=item resume

  --force
  -f
  --noforce
  --nof

Allow downloads to overwrite existing recordings that appear to be complete.

=item verbose

  --verbose
  -v

Provide more information. A single B<-v> lists some more details about
the recordings, and shows a progress indicator when copying.
Two B<-v> options list the sizes of the recording file chunks on the
Beyonwiz.

=item quiet

  --quiet
  -q

The opposite effect of B<--verbose>.
Useful if C<$verbose> is non-zero in the user's C<.getwizpnp> file.

=item regexp

  --regexp
  -r
  --noregexp
  --nor

Carry out the matches using the argument as a case-insensitive
Perl regular expression.
For example:

    getWizPnP --regexp 'ABC|SBS'

will copy all recordings made from either the ABC or SBS.

B<--noregexp> and B<--nor> undo the setting of this option;
useful if this option is set by default in the user's C<.getwizpnp> file.

=item expression

  --expression
  -e
  --noexpression
  --noe

Evaluates the match arguments as Perl expressions with C<$_> set to
the I<servicename>B<#>I<title>#I<date> string.
If any expression evaluates to true (in Perl terms),
the recording is matched.

    getWizPnp --expression '/ABC|SBS/i'

is equivalent to the B<--regexp> example above.
Quite powerful; the Swiss Army knife approach.

B<--noexpression> and B<--noe> undo the setting of this option;
useful if this option is set by default in the user's C<.getwizpnp> file.

=item outdir

  --outdir=dir
  -O dir

Save the recordings in I<dir> rather than in the current directory.

=item indir

  --indir=dir
  -I dir

Look for recordings in I<dir> on the local computer rather than on the
Beyonwiz.

=item List

  --List
  -L

Produce only a list of the index names of the recordings in the recording
index file.
Intended for use by GUIs or other programs calling I<getWizPnP>.

=item BWName

  --BWName
  -B

The pattern arguments are recording index names as listed by B<--List>.
Can find Beyonwiz recordings faster than other matching methods,
because it doesn't scan the whole file list.
Unlike the other matching methods, must be an exact string match.
Not very user-friendly.
Intended for use by GUIs or other programs calling I<getWizPnP>.

=back

=head1 FILES

The file C<.getwizpnp> is searched for in the user's C<HOME> directory,
if C<HOME> is set, or in the current directory if C<HOME> is not set.
If C<.getwizpnp> exists, it is run as a piece of Perl code by I<getWixPnP>
just after the program defaults for options are set, and just before
command-line options are set.

It is probably most useful for setting the default B<--device>
or B<--host> option.

An example C<.getwizpnp> file is included with I<getWizPnP>, in
the file C<getwizpnp.conf>.

=head1 PREREQUSITES

Uses packages 
L<C<Beyonwiz::WizPnP;>|Beyonwiz::WizPnP;>,
L<C<Beyonwiz::Recording::HTTPIndex>|Beyonwiz::Recording::HTTPIndex>,
L<C<Beyonwiz::Recording::HTTPHeader>|Beyonwiz::Recording::HTTPHeader>,
L<C<Beyonwiz::Recording::HTTPTrunc>|Beyonwiz::Recording::HTTPTrunc>,
L<C<Beyonwiz::Recording::HTTPRecording>|Beyonwiz::Recording::HTTPRecording>,
L<C<Beyonwiz::Recording::FileIndex>|Beyonwiz::Recording::FileIndex>,
L<C<Beyonwiz::Recording::FileHeader>|Beyonwiz::Recording::FileHeader>,
L<C<Beyonwiz::Recording::FileTrunc>|Beyonwiz::Recording::FileTrunc>,
L<C<Beyonwiz::Recording::FileRecording>|Beyonwiz::Recording::FileRecording>,
C<HTTP::Status>,
C<Getopt::Long>.

=head1 BUGS

Uses C<bignum> for 64-bit integers, even when the underlying
Perl integers are 64 bits.

When resuming a download, may fetch up to 32MB more data than is
necessary.

=cut

use strict;

use Beyonwiz::WizPnP;;
use Beyonwiz::Recording::HTTPIndex;
use Beyonwiz::Recording::HTTPHeader;
use Beyonwiz::Recording::HTTPTrunc;
use Beyonwiz::Recording::HTTPRecording;
use Beyonwiz::Recording::FileIndex;
use Beyonwiz::Recording::FileHeader;
use Beyonwiz::Recording::FileTrunc;
use Beyonwiz::Recording::FileRecording;

use HTTP::Status;
use Getopt::Long qw(:config no_ignore_case bundling);

use constant CONFIG => '.getwizpnp';

our $device_name;
our $host;
our $port = 49152;
our $maxdevs = 1;
our $outdir;
our $indir;

our (
	$list,
	$List,
	$date,
	$regexp,
	$expression,
	$bwName,
	$verbose,
	$quiet,
	$ts,
	$resume,
	$force,
	$help,
    ) = ((0) x 12);

$| = 1;

sub Usage {
    die "Usage: $0 [-h|--help] [-D dev|--device dev] [-m devs|--maxdev=devs]\n",
	"                  [-H host|--host=host] [-p port|--port=port]\n",
	"                  [-l|--list] [-t|--ts] [-v|--verbose] [-q|--quiet]\n",
	"                  [-d|--date]\n",
	"                  [-r|--regexp] [-e|--expression] [-B|-BWName]\n",
	"                  [-O dir|--outdir=dir] [-I dir|--indir=dir]\n",
	"                  [ patterns... ]\n";
}

my $config = defined $ENV{HOME} && length($ENV{HOME}) > 0
		? $ENV{HOME} . '/' . CONFIG
		: CONFIG;

do $config if(-f $config);

GetOptions(
	'h|help',        \$help,
	'H|host=s',      \$host,
	'p|port=i',      \$port,
	'D|device=s',    \$device_name,
	'm|maxdevs=i',   \$maxdevs,
	'l|list',        \$list,
	'L|List',        \$List,
	't|ts!',         \$ts,
	'd|date!',       \$date,
	'R|resume!',     \$resume,
	'f|force!',      \$force,
	'r|regexp!',     \$regexp,
	'e|expression!', \$expression,
	'B|BWName!',      \$bwName,
	'O|outdir=s',    \$outdir,
	'I|indir=s',     \$indir,
	'v|verbose+',    \$verbose,
	'q|quiet+',      \$quiet,
    ) or Usage;

Usage if($help);

$verbose = $verbose - $quiet;
$verbose = 0 if($verbose < 0);

use constant MATCH_SUBSTR => 0;
use constant MATCH_REGEXP => 1;
use constant MATCH_EXPR   => 2;
use constant MATCH_BWNAME => 3;

die "Can't set more than one of --regexp, --expression or ---BWName\n"
    if($regexp + $expression + $bwName > 1);

my $match_type = MATCH_SUBSTR;
$match_type = MATCH_REGEXP if($regexp);
$match_type = MATCH_EXPR   if($expression);
$match_type = MATCH_BWNAME if($bwName);

# Class implementing a progress bar

{
    package ProgressBar;

    my $accessorsDone;

    sub new() {
	my ($class) = @_;
	$class = ref($class) if(ref($class));

	my $self = {
	    total   => undef,
	    done    => undef,
	    percen  => 0,
	    totMb   => 0,
	    mb      => 0,
	    display => '',
	};

	bless $self, $class;

	unless($accessorsDone) {
	    Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	    $accessorsDone = 1;
	}

	return $self;
    }

    # Return/set the total number of bytes to transfer

    sub total($;$) {
	my ($self, $val) = @_;
	my $ret = $self->{total};
	if(@_ == 2) {
	    $self->{total} = $val;
	    $self->done(0);
	    $self->percen(0);
	    $self->mb(0);
	    $self->totMb($val / (1024*1024));
	    $self->display('');
	}
	return $ret;
    }

    # Return/set the total number of bytes transferred
    # Update the progress bar if the progress bar has changed.

    sub done($;$) {
	my ($self, $val) = @_;
	my $ret = $self->{done};
	if(@_ == 2) {
	    $self->{done} = $val;

	    my $percen = $self->{done} / $self->total * 100;
	    my $donechars = int($percen / 2 + 0.5);
	    $percen = int($percen + 0.5);
	    my $mb = int($self->{done} / (1024*1024));
	    if($percen != $self->percen
	    || $mb != $self->mb
	    || $self->display eq '') {
		my $donestr = '=' x $donechars;
		my $leftstr = '-' x (50 - $donechars);
		my $dispstr = sprintf "\r|%s%s| %3d%% %.0f/%.0fMB",
		    $donestr, $leftstr, $percen,
		    $mb, $self->totMb;
		$self->percen($percen);
		$self->mb($mb);
		print $dispstr;
		$self->display($dispstr);
	    }
	}
	return $ret;
    }

}

# Connect to a Beyonwiz WizPnP server and return
# its WizPnPDevice. If $host is set, use that as the
# server IP addr/DNS name.
# Otherwise search for up to $maxdevs servers,
# and return the matching server. If $device_name is defined,
# the server must match that name; if $server_name
# is not defined, and there is only one server found, return that,
# otherwise die.

sub connectToBW($$$) {
    my ($host, $maxdevs, $verbose) = @_; 
    my $pnp = Beyonwiz::WizPnP->new;
    my $device;

    if($host) {
	my $url = URI->new(Beyonwiz::WizPnP::DESC, 'http');
	$url->scheme('http');
	$url->host($host);
	$url->port($port);

	$pnp->addDevice($url);
	die "Can't get a device description for $host\n"
	    if($pnp->ndevices == 0);
	$device = $pnp->device(($pnp->deviceNames)[0]);
	die "Host $host isn't device $device_name, it's ", $device->name, "\n",
	    if(defined($device_name) && lc($device_name) ne lc($device->name));
    } else {
	print "Searching for at most $maxdevs device",
		($maxdevs != 1 ? 's' : ''), "\n"
	    if($verbose >= 1 && $maxdevs > 0);

	$pnp->search($maxdevs);

	if($pnp->ndevices == 0) {
	    die "Search for WizPnP devices failed\n";
	} elsif($pnp->ndevices == 1) {
	    $device = $pnp->device(($pnp->deviceNames)[0]);
	    die "Device $device_name isn't available.",
		    " Device ", $device->name, " was found\n",
		if(defined($device_name)
		&& lc($device_name) ne lc($device->name));
	} else {
	    die 'Found devices [', join(', ', $pnp->deviceNames),
		    ' but no device selected with --device'
		if(!defined $device_name);
	    $device = $pnp->device($device_name);
	    die "Device $device_name isn't available. [",
		    join(', ', $pnp->deviceNames), " were found\n"
		if(!$device);
	}
    }
    return $device;
}

# Generate the service#title#date string for matching against user pattern.

sub testString($) {
    my ($hdr) = @_;
    return join('#', $hdr->service,
			$hdr->longTitle,
			scalar(gmtime($hdr->starttime)));
}

# Return true if the header matches any user pattern argument
# and the recording isn't active, and the mode is "load recording"

sub doLoadFile($) {
    my ($hdr) = @_;
    return 0 if($hdr->inRec || @ARGV == 0 || $list);
    $_ = testString($hdr);
    foreach my $a (@ARGV) {
	return index(lc($_), lc($a)) >= 0 if($match_type == MATCH_SUBSTR);
	return $_ =~ /$a/i if($match_type == MATCH_REGEXP);
	return eval($a) if($match_type == MATCH_EXPR);
    }
}

# Return true if the header matches any user pattern argument
# and the mode is "list recording"

sub doShowFile($) {
    my ($hdr) = @_;
    return 1 if(@ARGV == 0);
    $_ = testString($hdr);
    foreach my $a (@ARGV) {
	return index(lc($_), lc($a)) >= 0 if($match_type == MATCH_SUBSTR);
	return $_ =~ /$a/i if($match_type == MATCH_REGEXP);
	return eval($a) if($match_type == MATCH_EXPR);
    }
}

# Create a new index object for he recording source, either local or HTTP.

sub newIndex($$)
{
    my ($indir, $device) = @_;
    return $indir
	? Beyonwiz::Recording::FileIndex->new($indir)
	: Beyonwiz::Recording::HTTPIndex->new($device->baseUrl)
}

# Create a new recording object for he recording source, either local or HTTP.

sub newRecording($$$$$$) {
    my ($indir, $device, $ts, $date, $resume, $force) = @_;
    return $indir
	? Beyonwiz::Recording::FileRecording->new(
			$indir, $ts, $date, $resume, $force
		    )
	: Beyonwiz::Recording::HTTPRecording->new(
			$device->baseUrl, $ts, $date, $resume, $force
		    );
}

# Create a new recording header object for he recording source,
# either local or HTTP.

sub newHeader($$$) {
    my ($indir, $device, $ie) = @_;
    return $indir
	? Beyonwiz::Recording::FileHeader->new($ie->name, $ie->path)
	: Beyonwiz::Recording::HTTPHeader->new(
    			$ie->name, $device->baseUrl, $ie->path
		    );
}

# Create a new recording file index object for he recording source,
# either local or HTTP.

sub newTrunc($$$) {
    my ($indir, $device, $ie) = @_;
    return $indir
	? Beyonwiz::Recording::FileTrunc->new($ie->name, $ie->path)
	: Beyonwiz::Recording::HTTPTrunc->new(
			$ie->name, $device->baseUrl, $ie->path
		    );
}

# Format to write the extended info as multi-line, filled,
# left-justified.

my $info;
format STDOUT =
~~  ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    $info
.

# Either list or copy the recording.
# List if $do_show; copy if $do_load.
# $device is the WixPnPDevice, $hdr is the header object,
# $ie is the IndexEntry object, $rec is the recording object.

sub listOrCopy($$$$$$$) {
    my ($indir, $device, $hdr, $ie, $rec, $do_show, $do_load) = @_;

    my $trunc;

    if($do_show) {
	print $hdr->service, ': ', $hdr->longTitle,
		    ($hdr->inRec ? ' *RECORDING NOW' : ''), "\n";
	if($verbose >= 2) {
	    $hdr->loadExtInfo;
	    if($hdr->validExtInfo
	    && $hdr->extInfo && length($hdr->extInfo) > 0) {
		$info = $hdr->extInfo;
		write STDOUT;
	    }
	}
	if($verbose >= 1) {
	    print "    Index name: ", $ie->name, "\n";
	    print "    ", scalar(gmtime($hdr->starttime)),
		' - ', scalar(gmtime($hdr->starttime + $hdr->playtime)),
		"\n";
	    printf "    playtime: %4d:%02d",
		    int($hdr->playtime/60),  $hdr->playtime % 60;
	    printf "    recording size: %8.1f MB\n",
		    ($hdr->endOffset - $hdr->startOffset)/(1024*1024);
	}
	if($verbose >= 3) {
	    $trunc = newTrunc($indir, $device, $ie);
	    $trunc->load;

	    if($trunc->valid) {
		# Print offsets with %s rather than %d, because %d forces
		# conversion to internal integer size
		printf "    Recording start offset: %19s\n",
		    $hdr->startOffset;
		printf "    Recording end offset:   %19s\n",
		    $hdr->endOffset;
		printf "    %4s %12s %10s %14s\n",
		    'File', 'File Offset', 'Size', 'Rec Offset';
		foreach my $tr (@{$trunc->entries}) {
		    printf "    %04d %12s %10d %14s\n",
			$tr->fileNum, $tr->offset,
			$tr->size, $tr->wizOffset;
		}
	    }
	}
	if($verbose >= 4) {
	    $hdr->loadOffsets;
	    $hdr->loadBookmarks;
	    if($hdr->validOffsets
	    && $hdr->validBookmarks && $hdr->nbookmarks > 0) {
		printf "    %4s %7s %14s\n", 'Num', 'Time', 'Bookmark';
		for(my $i = 0; $i < $hdr->nbookmarks; $i++) {
		    my $t = int($hdr->offsetTime($hdr->bookmarks->[$i]));
		    printf "    %4d %4d:%02d %14s\n", $i,
			int($t/60), $t % 60, $hdr->bookmarks->[$i];
		}
	    }
	}
	if($verbose >= 5) {
	    if($hdr->validOffsets && $hdr->noffsets > 0) {
		printf "    %4s %7s %14s\n", 'Num', 'Time', 'Rec Offset';
		for(my $i = 0; $i < $hdr->noffsets; $i++) {
		    printf "    %4d %4d:%02d %14s\n",
			$i, int($i/6), $i * 10 % 60, $hdr->offsets->[$i];
		}
	    }
	}
    }
    if($do_load) {
	if(!$trunc) {
	    $trunc = newTrunc($indir, $device, $ie);
	    $trunc->load;
	}
	if($trunc->valid) {
	    my $status = $rec->getRecording(
					$hdr, $trunc,
					$ie->path,
					$outdir,
					$verbose >= 1
					    ? ProgressBar->new
					    : undef
				    );
	    print "\n" if($verbose >= 1);
	    warn "Download failed: ",
		    status_message($status), "\n"
		if(!is_success($status));
	} else {
	    warn $ie->name, " skipped\n"
	}
    }
    print "\n" if($do_show && $verbose >= 1);

}

# Normal selection function for recordings using
# the default substring match, --regexp or --expression
# Determine whether to list or copy the recording.
# $device is the WixPnPDevice, $index is the Index object,
# $rec is the recording object.

sub selectListOrCopy($$$$) {
    my ($indir, $device, $index, $rec) = @_;
    foreach my $ie (@{$index->entries}) {
	my $hdr = newHeader($indir, $device, $ie);

	$hdr->loadMain;

	if($hdr->validMain) {
	    $hdr->loadEpisode;
	    my ($do_show, $do_load) = (doShowFile($hdr), doLoadFile($hdr));
	    listOrCopy($indir, $device, $hdr,
			$ie, $rec, $do_show, $do_load);
	}
    }
}


# Normal selection function for recordings using
# --BWName selection.
# Determine whether to list or copy the recording.
# $device is the WixPnPDevice, $index is the Index object,
# $rec is the recording object.

sub selectListOrCopyBWName($$$$) {
    my ($indir, $device, $index, $rec) = @_;
    my %args = map { ( $_ => 1 ) } @ARGV;
    foreach my $ie (@{$index->entries}) {
	my ($do_show, $do_load) = (0, 0);
	if($list) {
	    $do_show = $args{$ie->name};
	} else {
	    $do_show = $do_load = $args{$ie->name};
	}
	if($do_show || $do_load) {
	my $hdr = newHeader($indir, $device, $ie);

	    $hdr->loadMain;

	    if($hdr->validMain && !($hdr->inRec && $do_load)) {
		listOrCopy($indir, $device, $hdr,
			    $ie, $rec, $do_show, $do_load);
	    }
	}
    }
}

# Get the connection as a WizPnPDevice in $device

my $device;

if(!$indir) {
    my $pnp = Beyonwiz::WizPnP->new;

    $device = connectToBW($host, $maxdevs, $verbose);

    print 'Connecting to ', $device->name, "\n" if($verbose >= 1);
}

# Load the recording index

my $index = newIndex($indir, $device);

$index->load;

die "Couldn't load index file from $host\n" if(!$index->valid);

# Perform the copy or list operations

my $rec = newRecording($indir, $device, $ts, $date, $resume, $force);

if($List) {
    foreach my $ie (@{$index->entries}) {
	print $ie->name, "\n";
    }
} else {
    if($match_type == MATCH_BWNAME) {
	selectListOrCopyBWName($indir, $device, $index, $rec);
    } else {
	selectListOrCopy($indir, $device, $index, $rec);
    }
}
