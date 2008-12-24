#!/usr/bin/perl -w

=head1 NAME

getWizPnP - list and fetch recordings from a Beyonwiz DP series over the network using the WizPnP interface


=head1 SYNOPSIS

    getWizPnP [-h host|--host=host] [-p port|--port=port]
              [-l|--list] [-|--date] [-t|--ts] [-v|--verbose]
              [-r|--regexp] [-e|--expression]
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

To upload all recordings, an empty string will match everything:

    wizGetPnP ''

Recordings are uploaded to a name corresponding to their event name (title)
with any characters that are illegal in the file system changed to '_'.
The B<--date> option adds the day and date of the recording to the name,
helpful for series recordings.
Uploaded recordings are placed in the current directory.

=head1 ARGUMENTS

B<GetWizPnP> takes the following arguments:

=over 4

=item host

  --host=host
  -h host

Connect to the I<host> (DNS name or dotted-quad IP address) instead of the
file default (C<beyonwiz>), or the default set in the configuration
file (see FILES below).

=item host

  --port=port
  -p port

Connect to the I<port> instead of the
file default (C<49152>), or the default set in the configuration
file (see FILES below).

=item list

  --list
  -l

List the matching recordings, rather than uploading them.

=item date

  --date
  -d

Add the recording day and date to the name of the
recording when it's uploaded.
Useful for uploading series.

=item ts

  --ts
  -t

Upload the recordings as single C<.ts> (MPEG Transport Stream) files,
rather than copying in the Beyonwiz internal recording format.

=item verbose

  --verbose
  -v

Provide more information. A single B<-v> lists some more details about
the recordings, and shows a progress indicator when copying.
Two B<-v> options list the sizes of the recording file chunks on the
Beyonwiz.

=item regexp

  --regexp
  -r

Carry out the matches using the argument as a Perl regular expression.
For example:

    getWizPnP --regexp 'ABC|SBS'

will copy all recordings made from either the ABC or SBS.

=item expression

  --expression
  -e

Evaluates the match arguments as Perl expressions with C<$_> set to
the I<servicename>B<#>I<title>#I<date> string.
If any expression evaluates to true (in Perl terms),
the recording is matched.

    getWizPnp --expression '/ABC|SBS/'

is equivalent to the B<--regexp> example above.
Quite powerful; the Swiss Army knife approach.

=back

=head1 PREREQUSITES

Uses packages 
C<Beyonwiz::Recording::Header>,
C<Beyonwiz::Recording::Index>,
C<Beyonwiz::Recording::IndexEntry>,
C<Beyonwiz::Recording::Trunc>,
C<Beyonwiz::Recording::TruncEntry>,
C<File::Basename>,
C<Getopt::Long>,
C<HTTP::Status>,
C<LWP::Simple>,
C<URI>,
C<URI::Escape>

=head1 BUGS

File copy progress bar only updates after each (up to)
32MB chunk file is copied.

It's not possible to restart interrupted transfers.

If the I<--ts> flag is given, uploading a recording
to the same name will overwrite the original;
if it's not given an error results.
It's not completely clear what the correct behaviour should be.

Can only upload to the current directory.

Doesn't use the WizPnP protocol to find WixPnP servers.

=cut

use strict;

use Beyonwiz::Recording::Index;
use Beyonwiz::Recording::Header;
use Beyonwiz::Recording::Trunc;

use LWP::Simple;
use URI;
use URI::Escape;
use HTTP::Status;
use Getopt::Long qw(:config no_ignore_case bundling);
use File::Basename;

use constant STAT => 'stat';
use constant CONFIG => '.getwizpnp';

my $host = 'beyonwiz';
my $port = 49152;

my ($list, $date, $regexp, $expression, $verbose, $ts) = ((0) x 6);

my $badchars = '\/'; # For Unix & HFS+ filesystems
$badchars = '\\/:*?"<>|' if($^O eq 'MSWin32');

$| = 1;

sub Usage {
    die "Usage: $0 [-h host|--host=host] [-p port|--port=port]\n",
	"                  [-l|--list] [-t|--ts] [-v|--verbose]", 
	"                  [-d|--date] [-r|--regexp] [-e|--expression]", 
	" [ patterns... ]\n";
}

my $config = defined $ENV{HOME} && length($ENV{HOME}) > 0
		? $ENV{HOME} . '/' . CONFIG
		: CONFIG;

do $config if(-f $config);

GetOptions(
	'h|host=s', \$host,
	'p|port=i', \$port,
	'l|list', \$list,
	't|ts', \$ts,
	'd|date!', \$date,
	'r|regexp!', \$regexp,
	'e|expression!', \$expression,
	'v|verbose+', \$verbose,
    ) or Usage;

my $url = URI->new('', 'http');
$url->scheme('http');
$url->host($host);
$url->port($port);

sub get_info($$$$$) {}

sub get_recording_file($$$$$) {
    my ($url, $path, $name, $file, $append) = @_;

    my $data_url = $url->clone;

    $data_url->path($path . '/' . uri_escape($file));
    $name .= '/' . $file if(!$ts);
    $name = '>' . $name if($append);
    my $status = getstore($data_url, $name);
    warn "$name/$file : ", status_message($status), "\n"
	if(!is_success($status));
    return $status;
}

sub show_progress($$) {
    my ($size, $done) = @_;
    my $percen = $done / $size * 100;
    my $donechars = int($percen / 2 + 0.5);
    my $donestr = '=' x $donechars;
    my $leftstr = '-' x (50 - $donechars);
    printf "\r|%s%s| %3d%% %.0f/%.0fMB",
	$donestr, $leftstr, int($percen + 0.5), $done, $size;
}

sub get_recording($$$$) {
    my ($hdr, $trunc, $url, $path) = @_;
    my $status;

    my $name = uri_unescape(basename($path));
    if(defined($hdr->title) && length($hdr->title) > 0) {
	$name = $hdr->title;
	if($date) {
	    my $d = gmtime($hdr->starttime);
	    substr $d, 11, 9, '';
	    $name .= ' ' . $d;
	}
    }
    $name =~ s/[$badchars]/_/g;
    if($ts) {
	$name =~ s/.(tv|rad)wiz$//;
	$name .= '.ts';
    } 

    print "Uploading to: $name\n" if($verbose >= 1);

    if(!$ts) {
	if(-d $name) {
	    warn "Recording $name already exists\n";
	    return RC_PRECONDITION_FAILED;
	}
	if(!mkdir($name)) {
	    warn "Can't create $name: $!\n";
	    return RC_PRECONDITION_FAILED;
	}
	$status = get_recording_file($url, $path, $name,
					$hdr->headerName, 0);
	return $status if(!is_success($status));
	$status = get_recording_file($url, $path, $name, STAT, 0);
	return $status if(!is_success($status));
	$status = get_recording_file($url, $path, $name,
					Beyonwiz::Recording::Trunc::TRUNC, 0);
	return $status if(!is_success($status));

    }

    my $size;
    foreach my $tr (@{$trunc->entries}) {
	$size += $tr->size / (1024 * 1024);
    }
    my $done = 0;
    my $append = 0;

    show_progress($size, $done) if($verbose >= 1);

    foreach my $tr (@{$trunc->entries}) {
	my $fn = sprintf "%04d", $tr->fileNum;

	$status = get_recording_file($url, $path, $name, $fn, $append);

	last if(!is_success($status));

	$done += $tr->size / (1024 * 1024);

	show_progress($size, $done) if($verbose >= 1);

	$append = $ts;
    }
    print "\n" if($verbose >= 1);
    return $status;
}

sub test_string($) {
    my ($hdr) = @_;
    return join('#', $hdr->service, $hdr->title,
			scalar(gmtime($hdr->starttime)));
}

sub do_load_file($) {
    my ($hdr) = @_;
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
    return 1 if(@ARGV == 0);
    $_ = test_string($hdr);
    foreach my $a (@ARGV) {
	return index($_, $a) >= 0 if(!$regexp && !$expression);
	return $_ =~ /$a/ if($regexp);
	return eval($a) if($expression);
    }
}

die "Can't set both --regexp and --expression\n" if($regexp && $expression);

my $index = Beyonwiz::Recording::Index->new($url);

$index->load;

die "Couldn't load index file from $host\n" if(!$index->valid);

foreach my $ie (@{$index->entries}) {
    my $hdr = Beyonwiz::Recording::Header->new($ie->name, $url, $ie->path);
    $hdr->load;
    if($hdr->valid) {
	my ($do_show, $do_load) = (do_show_file($hdr), do_load_file($hdr));
	my $trunc;
	if($do_load || $verbose >= 2) {
	    $trunc = Beyonwiz::Recording::Trunc->new(
					$ie->name, $url, $ie->path);
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
		printf "    %4s %10s\n", 'File', 'Size';
		foreach my $tr (@{$trunc->entries}) {
		    printf "    %04d %10d\n", $tr->fileNum, $tr->size;
		}
	    }
	}
	if($do_load) {
	    if($trunc->valid) {
		my $status = get_recording($hdr, $trunc, $url, $ie->path);
		warn "Upload failed!\n" if(!is_success($status));
	    } else {
		warn $ie->name, " skipped\n"
	    }
	}
	print "\n" if($do_show && $verbose >= 1);
    }
}
