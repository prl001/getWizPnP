#!/usr/bin/perl -w

=head1 NAME

getWizPnP - list and fetch recordings from a Beyonwiz DP series over the network using the WizPnP interface


=head1 SYNOPSIS

    getWizPnP [-h|--help] [-D dev|--device dev] [-m devs|--maxdev=devs]
              [-h host|--host=host] [-p port|--port=port]
              [-l|--list] [-d|--date] [-t|--ts] [-v|--verbose]
              [-r|--regexp] [-e|--expression] [-O dir|--outdir dir]
              [ patterns... ]

=head1 DESCRIPTION

List or fetch the recordings on a Beyonwiz DP series PVR over the network
using the WizPnP interface.

If no pattern arguments are given, then all recordings are listed.
Otherwise recordings matching any of the patterns are fetched
(or listed, with B<--list>).

In the absence of B<--regexp> or B<--expression> a pattern matches
if it is a substring of the string I<servicename>B<#>I<title>#I<date>,
case sensitive.
For example:

    SC10 Canberra#MOVIE: Pride & Prejudice#Fri Feb 15 20:28:00 2008

To download all recordings, an empty string will match everything:

    wizGetPnP ''

Recordings are downloaded to a name corresponding to their event name (title)
with any characters that are illegal in the file system changed to '_'.
The B<--date> option adds the day and date of the recording to the name,
helpful for series recordings.
Downloaded recordings are placed in the current directory.

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

Carry out the matches using the argument as a Perl regular expression.
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

    getWizPnp --expression '/ABC|SBS/'

is equivalent to the B<--regexp> example above.
Quite powerful; the Swiss Army knife approach.

B<--noexpression> and B<--noe> undo the setting of this option;
useful if this option is set by default in the user's C<.getwizpnp> file.

=item outdir

  --outdir=dir
  -O dir

Save the recordings in I<dir> rather than in the current directory.

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
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>,
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>,
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>,
L<C<Beyonwiz::Recording::Recording>|Beyonwiz::Recording::Recording>,
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>,
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>,
L<C<Beyonwiz::WizPnP>|Beyonwiz::WizPnP>,
L<C<Beyonwiz::WizPnPDevice>|Beyonwiz::WizPnPDevice>,
C<File::Basename>,
C<Getopt::Long>,
C<HTTP::Request>,
C<HTTP::Response>,
C<HTTP::Status>,
C<IO::Select>,
C<IO::Socket::Multicast>,
C<LWP::Simple>,
C<URI::Escape>,
C<URI>,
C<XML::DOM>.

=head1 BUGS

There is a problem with the implementation of the WizPnP search function
and it can take up to 60 seconds (average 30 seconds) to search
for the WizPnP devices on the network.
Until this problem is fixed, you may prefer to use the --host option.

File copy progress bar only updates after each (up to)
32MB recording chunk is copied.

It's not possible to restart interrupted transfers.

If the B<--ts> flag is given, downloading a recording
to the same name will overwrite the original;
if it's not given an error results.
It's not completely clear what the correct behaviour should be.

Can only download to the current directory.

The implementation of WixPnP search is slow; the Beyonwiz doesn't
respond to the WizPnP search multicast.

Uses C<bignum> for 64-bit integers, even when the underlying
Perl integers are 64 bits.

=cut

use strict;

use Beyonwiz::WizPnP;;
use Beyonwiz::Recording::Index;
use Beyonwiz::Recording::Header;
use Beyonwiz::Recording::Trunc;
use Beyonwiz::Recording::Recording;

use HTTP::Status;
use Getopt::Long qw(:config no_ignore_case bundling);

use constant CONFIG => '.getwizpnp';

our $device_name;
our $host;
our $port = 49152;
our $maxdevs = 1;
our $outdir;

our (
	$list,
	$date,
	$regexp,
	$expression,
	$verbose,
	$quiet,
	$ts,
	$help,
    ) = ((0) x 7);

$| = 1;

sub Usage {
    die "Usage: $0 [-h|--help] [-D dev|--device dev] [-m devs|--maxdev=devs]\n",
	"                  [-H host|--host=host] [-p port|--port=port]\n",
	"                  [-l|--list] [-t|--ts] [-v|--verbose] [-q|--quiet]\n",
	"                  [-d|--date] [-r|--regexp] [-e|--expression]\n",
	"                  [-O dir|--outdir=dir] [ patterns... ]\n";
}

my $config = defined $ENV{HOME} && length($ENV{HOME}) > 0
		? $ENV{HOME} . '/' . CONFIG
		: CONFIG;

do $config if(-f $config);

GetOptions(
	'h|help', \$help,
	'H|host=s', \$host,
	'p|port=i', \$port,
	'D|device=s', \$device_name,
	'm|maxdevs=i', \$maxdevs,
	'l|list', \$list,
	't|ts!', \$ts,
	'd|date!', \$date,
	'r|regexp!', \$regexp,
	'e|expression!', \$expression,
	'O|outdir=s', \$outdir,
	'v|verbose+', \$verbose,
	'q|quiet+', \$quiet,
    ) or Usage;

Usage if($help);

$verbose = $verbose - $quiet;
$verbose = 0 if($verbose < 0);

sub test_string($) {
    my ($hdr) = @_;
    return join('#', $hdr->service, $hdr->title,
			scalar(gmtime($hdr->starttime)));
}

sub do_load_file($) {
    my ($hdr) = @_;
    return 0 if($hdr->inRec);
    return 0 if(@ARGV == 0 || $list);
    $_ = test_string($hdr);
    foreach my $a (@ARGV) {
	return index($_, $a) >= 0 if(!$regexp && !$expression);
	return $_ =~ /$a/ if(!$regexp);
	return eval($a) if(!$regexp);
    }
}

sub do_show_file($) {
    my ($hdr) = @_;
    return 0 if($hdr->inRec);
    return 1 if(@ARGV == 0);
    $_ = test_string($hdr);
    foreach my $a (@ARGV) {
	return index($_, $a) >= 0 if(!$regexp && !$expression);
	return $_ =~ /$a/ if($regexp);
	return eval($a) if($expression);
    }
}

sub show_progress($$) {
    my ($size, $done) = @_;
    my $percen = $done / $size * 100;
    my $donechars = int($percen / 2 + 0.5);
    my $donestr = '=' x $donechars;
    my $leftstr = '-' x (50 - $donechars);
    printf "\r|%s%s| %3d%% %.0f/%.0fMB",
	$donestr, $leftstr, int($percen + 0.5),
	$done / (1024*1024), $size / (1024*1024);
}

die "Can't set both --regexp and --expression\n" if($regexp && $expression);

my $pnp = Beyonwiz::WizPnP->new;
my $device;

if($host) {
    my $url = URI->new(Beyonwiz::WizPnP::DESC, 'http');
    $url->scheme('http');
    $url->host($host);
    $url->port($port);

    $pnp->add_device($url);
    die "Can't get a device description for $host\n" if($pnp->ndevices == 0);
    $device = $pnp->device(($pnp->device_names)[0]);
    die "Host $host isn't device $device_name, it's ", $device->name, "\n",
	if(defined($device_name) && lc($device_name) ne lc($device->name));
} else {
    warn "WizPnP device search is currently slow.\n",
         "It can take up to 60 seconds to find the WizPnP devices.\n",
	 "Consider using --host to specify your device.\n";

    print "Searching for at most $maxdevs device",
	    ($maxdevs != 1 ? 's' : ''), "\n"
	if($verbose >= 1 && $maxdevs > 0);

    $pnp->search($maxdevs);

    if($pnp->ndevices == 0) {
	die "Search for WizPnP devices failed\n";
    } elsif($pnp->ndevices == 1) {
	$device = $pnp->device(($pnp->device_names)[0]);
	die "Device $device_name isn't available.",
	    " Device ", $device->name, " was found\n",
	    if(defined($device_name) && lc($device_name) ne lc($device->name));
    } else {
	die 'Found devices [', join(', ', $pnp->device_names),
		' but no device selected with --device'
	    if(!defined $device_name);
	$device = $pnp->device($device_name);
	die "Device $device_name isn't available. [",
		join(', ', $pnp->device_names), " were found\n"
	    if(!$device);
    }
    warn "If you want to use --host,\nthen --host ", $device->base_url->host,
	" will connect you to this device.\n";
}

print 'Connecting to ', $device->name, "\n" if($verbose >= 1);

my $index = Beyonwiz::Recording::Index->new($device->base_url);

$index->load;

die "Couldn't load index file from $host\n" if(!$index->valid);

my $rec = Beyonwiz::Recording::Recording->new($device->base_url, $ts, $date);

foreach my $ie (@{$index->entries}) {
    my $hdr = Beyonwiz::Recording::Header->new(
    				$ie->name, $device->base_url, $ie->path
			    );
    $hdr->load;
    if($hdr->valid) {
	my ($do_show, $do_load) = (do_show_file($hdr), do_load_file($hdr));
	my $trunc;
	if($do_load || $verbose >= 2) {
	    $trunc = Beyonwiz::Recording::Trunc->new(
					$ie->name, $device->base_url,
					$ie->path
				    );
	    $trunc->load;
	}
	if($do_show) {
	    print $hdr->service, ': ', $hdr->title, "\n";
	    if($verbose >= 1) {
		print "    ", $ie->name, "\n";
		print "    ", scalar(gmtime($hdr->starttime)),
		    ' - ', scalar(gmtime($hdr->starttime + $hdr->playtime)),
		    "\n";
		printf "    playtime: %d:%02d\n",
			int($hdr->playtime/60),  $hdr->playtime % 60;
	    }
	    if($verbose >= 2) {
		# Print offsets with %s rather than %d, because %d forces
		# conversion to internal integer size
		printf "    Recording start offset: %19s\n", $hdr->startOffset;
		printf "    Recording end offset:   %19s\n", $hdr->endOffset;
		printf "    %4s %12s %10s %14s\n",
		    'File', 'File Offset', 'Size', 'Rec Offset';
		foreach my $tr (@{$trunc->entries}) {
		    printf "    %04d %12s %10d %14s\n",
			$tr->fileNum, $tr->offset,
			$tr->size, $tr->wizOffset;
		}
	    }
	    if($verbose >= 3) {
		$hdr->load(1);
		if($hdr->valid && $hdr->nbookmarks > 0) {
		    printf "    %4s %14s\n", 'Num', 'Bookmark';
		    for(my $i = 0; $i < $hdr->nbookmarks; $i++) {
			printf "    %4d %14s\n", $i, $hdr->bookmarks->[$i];
		    }
		}
	    }
	    if($verbose >= 4 && $hdr->valid && $hdr->noffsets > 0) {
		printf "    %4s %7s %14s\n", 'Num', 'Time', 'Rec Offset';
		for(my $i = 0; $i < $hdr->noffsets; $i++) {
		    printf "    %4d %4d:%02d %14s\n",
			$i, int($i/6), $i * 10 % 60, $hdr->offsets->[$i];
		}
	    }
	}
	if($do_load) {
	    if($trunc->valid) {
		my $status = $rec->get_recording(
					    $hdr, $trunc,
					    $ie->path,
					    $outdir,
					    $verbose >= 1
						? \&show_progress
						: undef
					);
		print "\n" if($verbose >= 1);
		warn "Download failed!\n" if(!is_success($status));
	    } else {
		warn $ie->name, " skipped\n"
	    }
	}
	print "\n" if($do_show && $verbose >= 1);
    }
}
