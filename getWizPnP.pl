#!/usr/bin/perl -w

=head1 NAME

getWizPnP - list and fetch recordings from a Beyonwiz DP series over the network using the WizPnP interface


=head1 SYNOPSIS

    getWizPnP [--help|-h]
              [--device dev|-D dev] [--maxdevs=devs|-m devs]
              [--host=host|-H host] [--port=port|-p port]
              [--list|-l] [--List|-L]
              [--delete|-X] [--move|-M] [--dryrun|-n]
              [--folder=folderlist|-f folderlist]
              [--recursive|--all|-a]
              [--regexp|-r] [--expression|-e] [-BWName|-B]
              [--sort=sortcode|-s sortcode]
              [--dictionarySort=ignoretype|-i ignoretype]
              [--dictStoplist=words|-S word]
              [--date|-d] [--episode|-E] [--ts|-t]
              [--resume|-R] [--force|-F]
              [--outdir=dir|-O dir] [--indir=dir|-I dir]
              [--verbose|-v] [--Verbose=level|-V level] [--quiet|-q]
	      [--index|-x]
	      [--discover] [--wizpnpPoll=npoll] [--wizpnpTimeout=timeout]
              [ patterns... ]

=head1 DESCRIPTION

List, fetch, move or delete the recordings on a Beyonwiz DP series
PVR over the network using the I<WizPnP> interface.
If B<--L<indir>> is specified, perform the same operations on
the computer where I<getWizPnP> is running.
B<--L<indir>> is most useful in combination with B<--L<ts>>.

If no pattern arguments are given, then all recordings are listed.
Otherwise recordings matching any of the patterns are fetched
(or listed, moved or deleted, with B<--L<list>>, B<--L<move>> or B<--L<delete>>
respectively).

In the absence of B<--L<regexp>> or B<--L<expression>> a pattern matches
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

Recordings are copied or moved to a name corresponding to their event name
(title) with any characters that are illegal in the file system changed to '_'.
The B<--L<date>> option adds the day and date of the recording to the name,
and the B<--L<episode>> option adds the episode name to the recording
name (if there is one set)
-- helpful for series recordings.
Downloaded recordings are placed in the current directory unless B<--L<outdir>>
has been specified.

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


=item maxdevs

  --maxdevs=devs
  -D devs

In a WizPnP search, stop searching when the number of WizPnP
devices found is I<devs>, rather than waiting for the search to
time out (currently 9 seconds). I<Devs> defaults to 1.
If set to zero, there is no limit; the search continues looking
for devices until it times out.

=item host

  --host=host
  -h host

Connect to the I<host> (DNS name or dotted-quad IP address) instead of using
WizPnP search to find the Beyonwiz, or instead of the default set in the
B<L<configuration file|/FILES>>.

If the device name is specified with B<--L<device>> then the configuration
returned by I<host> that contains the WizPnP name of the device must match
(case insensitive) the device name given by B<--L<device>>.

=item port

  --port=port
  -p port

Connect to the I<port> instead of the
file default (C<49152>), or the default set in the configuration
file (see B<L</FILES>> below).
I<port> is ignored unless B<--L<host>> is set.

=item list

  --list
  -l

List the matching recordings, rather than copying them.

=item delete

  --delete
  -X

Delete the matching recordings, rather than copying them.
Delete uses an undocumented feature of WizPnP. See B<L</BUGS>>.

=item move

  --move
  -M

Move the specified recordings to the output directory.
Equivalent to a copy followed by a delete for each matching recording.
Move uses an undocumented feature of WizPnP. See B<L</BUGS>>.

=item folder

    --folder=foldername
    -f folder

Restrict the operations to the named folder.
More that one B<--L<folder>> option may be given, the operations apply to
all the named folders.
If no folders are named, operations are on the top level
recording folder (equivalent to specifying B<--folder=>
or B<-f "">).

Recordings can be specified with either relative or absolute path names,
but they have the same meaning. The path separator characters can
be either the Unix-like B</> or the DOS-like B<\>.
Case is ignored in folder name comparisone.
So B<Movies/Comedy>,
B</movies/CoMeDy>
and B<movies\comedy>
all refer to the same folder (on Unix, the B<\> will need to be quoted).
Unlike Unix and DOS, folder names B<.> and B<..> have
no special meaning, and will simply cause any folder match to fail.

If the Beyonwiz is running firmware 01.05.261 or earlier, only recordings
directly in the recordings folder are accessible,
and using anything but the default folder will mean that
no recordings are visible.

If B<--L<indir>> is used, then all recordings in that folder will appear
to be in the top level folder seen by I<getWizPnP>.
If any foldername except B<--folder=> (or B<--folder=/>)
is used, no recprdings will be found.

=item recursive

  --recursive
  --all
  -a
  --norecursive
  --noall
  --noa

Recursively examine all subfolders under the folders specified
by B<--L<folder>> for recordings, as well as just the recordings
directly in the folders.

Has no effect if the Beyonwiz is running firmware 01.05.261 or earlier.

Has no effect if B<--L<indir>> is used.

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

B<--noL<regexp>> and B<--nor> undo the setting of this option;
useful if this option is set by default in the user's
B<L<configuration file|/FILES>>.

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

is equivalent to the B<--L<regexp>> example above.
Quite powerful; the Swiss Army knife approach.

B<--noL<expression>> and B<--noe> undo the setting of this option;
useful if this option is set by default in the user's
B<L<configuration file|/FILES>>.

=item sort

    --sort=sortcode
    -s sortcode

Sort the output according to the value of I<sortcode>.
I<Sortcode> is a string made up of the codes:
B<uu> (unsorted),
B<az> (title alphabetic ascending),
B<za> (title alphabetic descending),
B<fa> (folder name alphabetic ascending),
B<fd> (folder name alphabetic descending),
B<ta> (date and time ascending),
B<td> (date descending),
B<da> (date and time ascending) and
B<dd> (date descending).
The default I<sortcode> is B<fatd>
(folder name ascending, time descending).
Time descending is to match the Beyonwiz default sort order
(and only sort order in older firmware).
Later codes in the string are only checked if entries are equal on
all earlier codes. The default I<sortcode> sorts on folder name,
then title (not including episode title),
then from earliest to latest for the same title & folder name.

Case is ignored for the folder name sort order.

If the B<uu> code is used anywhere in the string, the output is unsorted.

Sorting on titles only works correctly with Beyonwiz firmware 01.05.261
and later.
Even where it works, sorting by name of recordings on
the Beyonwiz may differ from the
strictly ACSII ordering of some punctuation,
because there's no fast way to get the exact title
punctuation in some circumstances.

On some earlier firmware, sorting on time won't work if the
recording ha been renamed.

Sorting is by the last modified time of the folder,
not on the actual recording time when B<--L<outdir>> is used.

=item dictionarySort

    --dictionarySort=ignoretype
    -i ignoretype

Specifies the style of sorting on the title.
I<Ignoretype> is a comma-separated string of
B<movie> (B<m>),
B<punctuation> (B<p>),
B<space> (B<s>),
B<stoplist> (B<st>),
B<case> (B<c>),
B<exact> (B<none>, B<e>, B<n>)
or
B<all> (B<a>).
Either the longer or the shorter S<form(s)> in parentheses may be used.

When sorting the recordings by title (B<--sort=>I<sortcode>):

B<movie> (B<m>)

ignores any B<MOVIE:> substring at the start of a title;

B<punctuation> (B<p>)

ignores all characters except alphanumerics and white space;

B<space> (B<s>)

ignores white space in the title.

B<stoplist> (B<st>)

ignores any words in the I<dictStoplist> when they
occur at the start of a title;

B<case> (B<c>)

ignores case in alphabetic characters;

B<exact> (B<none>, B<e>, B<n>)

exact match (none of the above);

B<all> (B<a>)

all of the above, except B<exact>

The default is B<exact>.

The kewords are evaluated in order, and added to the default set
of options, except for B<exact>.
Using B<exact> clears all options and any  following options
become the only ones used.

    --dictionarySort=case,punctuation

adds B<case> and B<punctuation> to the current set of options.

    --dictionarySort=exact,case,punctuation

makes the options just B<case> and B<punctuation>.

Multiple B<--L<dictionarySort>> may be used.

    --dictionarySort=exact --dictionarySort=case,punctuation

has the same effect as

    --dictionarySort=exact,case,punctuation

=item dictStoplist

    --dictStoplist=words
    -S word

Use the word(s) specified by the comma-separated
list of I<words> as the words ignored
by B<--L<dictionarySort>> when they appear at the start of a title.
The default list is B<A>, B<An>, B<The>.
Specifying any words with B<--L<dictStoplist>>
overrides the stoplist.
Multiple instances of B<--L<dictStoplist>> add to the list.

    --dictStoplist=a,an --dictStoplist=the

has the same effect as

    --dictStoplist=a,an,the

Case is ignored checking for these words only
if B<case> is set in B<--L<dictionarySort>>.

=item date

  --date
  -d
  --nodate
  --nod

Add the recording day and date to the name of the
recording when it's downloaded.
Useful for downloading series.

=item episode

  --episode
  -E
  --noepisode
  --noE

Add the recording episode name (if there is one) to the name of the
recording when it's downloaded.
Useful for downloading series.

=item ts

  --ts
  -t
  --nots
  --not

Download the recordings as single C<.ts> (MPEG Transport Stream) files,
rather than copying in the Beyonwiz internal recording format.

B<--noL<ts>> and B<--not> undo the setting of this option;
useful if this option is set by default in the user's B<L<configuration file|/FILES>>.

=item resume

  --resume
  -R
  --noresume
  --noR

Allow resumption of downloading of recordings that appear to be incomplete.

=item resume

  --force
  -F
  --noforce
  --noF

Allow downloads to overwrite existing recordings that appear to be complete.

=item verbose

  --verbose
  -v

Provide more information. Each B<-v> increases the verbosity level by 1
from 0.

Verbosity level 1 lists some more details about
the recordings, and shows a progress indicator when copying.
The progress indicator shows the transfer rate for the last 20 mebibytes
copied while the transfer is running, and the average transfer rate
for the copy when the copy completes.
Level 2 includes the program synopsis, if there is one.
Level 3 includes a display of any bookmarks in the file.
Level 4 includes information from the C<trunc> header file, and displays
a list of the file fragments that make up the recording.
Level 5 includes a listing of the time/recording offset information
for the file. This is a long listing (one line for every 10 seconds of
the recording).

The units used in the verbose listings are in terms of mebibytes (MiB)
and mebibits (Mib).
Mebi- is the ISO name for a multipler of 2^20 (1204*1024 = 1048576).
In computing this multiplier is often (strictly incorrectly) called mega-
(prefix M). Mega- should be used for a multiplier of 1000000.
Mebi- is about 5% more than mega-.

See also B<--L<Verbose>>

=item Verbose

  --Verbose=level
  -V level

Sets the verbosity level to I<level>. This overrides any setting of
C<$verbose> in the B<L<configuration file|/FILES>>.

B<--Verbose> and B<--L<verbose>> options are processed in order.
Assuming that C<$verbose> isn't set to non-zero in the config file,
C<-vv -V=1> sets the verbosity level to 1, but C<-V=1 -vv> sets it to 3.

Mixing B<--Verbose> and B<--L<verbose>> probably doesn't help with
clarity in commands.

See also B<--L<verbose>>.

=item quiet

  --quiet
  -q

The opposite effect of B<--L<verbose>>.
Useful if C<$verbose> is non-zero in the user's
B<L<configuration file|/FILES>>.

=item index

  --index
  -x

Add the Beyonwiz index name for the recording.
This is the unique name for the recording used internally by WizPnP
to refer to a it.
The index name is also printed for verbosity level 4 or more.
See B<--L<verbose>>.

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

=item discover

  --discover

Print a list of the discovered Beyonwiz WizPnP servers,
name and IP address, and exit.
As in normal operation, the maximum number of devices to search for
is set by B<--L<maxdevs>>.
If B<--L<indir>> is set, no Beyonwiz device search is performed,
and I<getWizPnP> exits immediately.

=item wizpnpPoll

  --wizpnpPoll=npoll

Sets the maximum number of search requests sent by 
a WizPnP device search before terminating the search.
Defaults to 3.

=item wizpnpTimeout

  --wizpnpTimeout=timeout

Sets the maximum timeout (floating point seconds)
used when waiting for a respnse to a WizPnP SSDP device search request.
Defaults to 0.3 sec.

=back

=head1 FILES

A small Perl file, C<.getwizpnp> on Unix-like systems
(MacOS X, Cygwin, Linux, etc) and C<getwizpnp.conf> on
Windows can be used to change the default values of a number of
I<getWizPnP> options.

On Unix-like systems, the file C<.getwizpnp> is searched for in the user's
C<HOME> directory,
if C<HOME> is set,
or in the current directory if C<HOME> is not set.

On Windows, the file C<getwizpnp.conf> is searched for
in C<%APPDATA%\Prl\getWizPnP> if C<%APPDATA%> is set,
and in I<getWizPnP>'s current directory otherwise.

C<%APPDATA%> is normally set to
C<C:\Documents and Settings\>I<userName>C<\Application Data>.

If the configuration file exists,
it is run as a piece of Perl code by I<getWixPnP>
just after the program defaults for options are set, and just before
command-line options are set, so it over-rides program defaults,
but not command-line options.

It is probably most useful for setting the default B<--L<device>>
or B<--L<host>> option, or making B<--L<episode>> set by default.

An example C<.getwizpnp> file is included with I<getWizPnP>, in
the file C<getwizpnp.conf>.

=head1 PREREQUSITES

Uses packages 
L<C<Beyonwiz::WizPnP>|Beyonwiz::WizPnP>,
L<C<Beyonwiz::Recording::HTTPIndex>|Beyonwiz::Recording::HTTPIndex>,
L<C<Beyonwiz::Recording::HTTPHeader>|Beyonwiz::Recording::HTTPHeader>,
L<C<Beyonwiz::Recording::HTTPTrunc>|Beyonwiz::Recording::HTTPTrunc>,
L<C<Beyonwiz::Recording::HTTPRecording>|Beyonwiz::Recording::HTTPRecording>,
L<C<Beyonwiz::Recording::FileIndex>|Beyonwiz::Recording::FileIndex>,
L<C<Beyonwiz::Recording::FileHeader>|Beyonwiz::Recording::FileHeader>,
L<C<Beyonwiz::Recording::FileTrunc>|Beyonwiz::Recording::FileTrunc>,
L<C<Beyonwiz::Recording::FileRecording>|Beyonwiz::Recording::FileRecording>,
C<File::Spec::Functions >,
C<File::Path>,
C<HTTP::Status>,
C<Getopt::Long>.

=head1 BUGS

Although a limited amount of testing has not found any problems,
it is uncertain whether deleting a recording on the Beyonwiz
while it is currently being watched can cause any malfunction on the
Beyonwiz.
Normally, the playback of the recording is stopped with an error message
shortly after the recording is deleted.
This may be impolite to he person watching, but so far does not appear
to affect the Beyonwiz beyond that.

The WizPnP search requires the use of the Perl package
C<IO::Socket::Multicast>.
This is available for download from CPAN for Mac OS X, Linux and Cygwin
running under Windows.
It is available only through and alternative PPM ActivePerl
archive for Windows.

WizPnP device search has intermittent failure on Windows
with ActivePerl 10, and on Cygwin.
The search is either immediately successful or fails completely,
even on retry.

If C<IO::Socket::Multicast> is not available, I<getWizPnP> will
exit with an error. In this case, the Beyonwiz device must be specified
using B<--L<host>> (and B<--L<port>> if necessary).

See README.txt in the distribution for details on how to install
any Perl modules that I<getWizPnP> needs to allow it to run on
your system.

Uses C<bignum> for 64-bit integers, even when the underlying
Perl integers are 64 bits.

When resuming a download, may fetch up to 32MiB more data than is
necessary.

B<--L<move>> and B<--L<delete>> use undocumented features of WizPnP.
This has a number of consequences:

=over 4

=item *

A recording can be deleted while it is being played on the Beyonwiz.
Normally, the playback will simply finish abruptly.
The same happens if I<getWizPnP> deletes a recording on the
WizPnP server while another Beyonwiz is playing the recording remotely
using WizPnP.

=item *

If the Beyonwiz is displaying the name of the deleted recording in the
file player when it is deleted, the file player view won't be updated.
Navigating away from that folder and back again will display the folder
correctly again.

=item *

The WizPnP's index of recordings (see B<--L</index>>) on the Beyonwiz
doesn't get updated when the recording on the Beyonwiz is deleted
(directly or after the copy for a move).
If you view the recordings on the Beyonwiz using WizFX,
entries for deleted recordings appear in the WizFX list of recordings.
These entries have no name, a date of 17/11/1858, and a size
of 256kB. They can't be copied using WizFX.
A recording deleted using I<getWizPnP> on a Beyonwiz WizPnP server
will appear normal in the file player on a Beyonwiz WizPnP client,
but the recording cannot be played.


=back

Problems caused by errors in the WizPnP index can be fixed by
either starting a recording on the Beyonwiz, or by shutting it
down to standby, then restarting it.

Sorting on titles does not work with Beyonwiz firmware 01.05.261
and earlier.
On some earlier firmware, sorting on time won't work if the
recording has been renamed.

Folder options (including sorting on folder name) do not work
with Beyonwiz firmware 01.05.261 and earlier.

B<--L<recursive>> has no effect if the Beyonwiz is running firmware
01.05.261 or earlier.

Folder options don't work properly in conjunction with B<--L<indir>>.

Sorting is by the last modified time of the folder,
not on the actual recording time when B<--L<outdir>> is used.

Instant recordings will not sort in their correct alphabetic sequence
(sorting on time or date will work).

=cut

use strict;

use Beyonwiz::WizPnP;
use Beyonwiz::Recording::HTTPIndex;
use Beyonwiz::Recording::HTTPHeader;
use Beyonwiz::Recording::HTTPTrunc;
use Beyonwiz::Recording::HTTPRecording;
use Beyonwiz::Recording::FileIndex;
use Beyonwiz::Recording::FileHeader;
use Beyonwiz::Recording::FileTrunc;
use Beyonwiz::Recording::FileRecording;
use File::Spec::Functions qw(catfile);
use File::Path qw(mkpath);

use HTTP::Status;
use Getopt::Long qw(:config no_ignore_case bundling);

use constant CONFIG => $^O eq 'MSWin32' ? 'getwizpnp.conf' : '.getwizpnp';

use constant MODE_LIST   => 0;
use constant MODE_LISTBW => 1;
use constant MODE_COPY   => 2;
use constant MODE_MOVE   => 3;
use constant MODE_DELETE => 4;
use constant MODE_SEARCH => 5;

use constant MATCH_SUBSTR => 0;
use constant MATCH_REGEXP => 1;
use constant MATCH_EXPR   => 2;
use constant MATCH_BWNAME => 3;

our $device_name;
our $host;
our $port = 49152;
our $maxdevs = 1;
our $outdir;
our $indir;
our $sortCode = 'faazta';
our @folderList;
our @dictionarySort;
our @defDictStoplist = qw(A An The);

our (
	# initialised to 0
	$list,
	$List,
	$recursive,
	$regexp,
	$expression,
	$bwName,
	$delete,
	$move,
	$dryrun,
	$date,
	$episode,
	$verbose,
	$indexName,
	$quiet,
	$ts,
	$resume,
	$force,
	$help,
	$discover,
	$wizpnpPoll,
	$wizpnpTimeout,
    ) = ((0) x 21);

$| = 1;

my %sortCmpLookup = (
    az => sub($$) { $_[0]->sortTitle cmp $_[1]->sortTitle },
    za => sub($$) { $_[1]->sortTitle cmp $_[0]->sortTitle },
    fa => sub($$) { $_[0]->sortFolder cmp $_[1]->sortFolder },
    fd => sub($$) { $_[1]->sortFolder cmp $_[0]->sortFolder },
    ta => sub($$) { $_[0]->time cmp $_[1]->time },
    td => sub($$) { $_[1]->time cmp $_[0]->time },
    da => sub($$) { substr($_[0]->time, 0, 8) cmp substr($_[1]->time, 0, 8) },
    dd => sub($$) { substr($_[1]->time, 0, 8) cmp substr($_[0]->time, 0, 8) },
    uu => undef,
);

my %dictionarySortMap = (
    all		=> undef,
    a		=> 'all',
    case	=> undef,
    c		=> 'case',
    exact	=> undef,
    none	=> 'exact',
    n		=> 'exact',
    e		=> 'exact',
    movie	=> undef,
    m		=> 'movie',
    punctuation	=> undef,
    p		=> 'punctuation',
    s		=> 'space',
    st		=> 'stoplist',
    space	=> undef,
    stoplist	=> undef,
);

my $dictStopRe;
my %dictionarySort;
my @dictStoplist;
my @sortCmpFns;
my $mode = MODE_COPY;
my $matchType = MATCH_SUBSTR;

sub Usage {
    die "Usage: $0 [--help|-h]\n",
	"                  [--device dev|-D dev] [--maxdevs=devs|-m devs]\n",
	"                  [--host=host|-H host] [--port=port|-p port]\n",
	"                  [--list|-l] [--List|-L]\n",
	"                  [--delete|-X] [--move|-M] [--dryrun|-n]\n",
	"                  [--folder=folderlist|-f folderlist]\n",
	"                  [--recursive|--all|-a]\n",
	"                  [--regexp|-r] [--expression|-e] [-BWName|-B]\n",
	"                  [--sort=sortcode|-s sortcode]\n",
	"                  [--dictionarySort=ignoretype|-i ignoretype]\n",
	"                  [--dictStoplist=words|-S words]\n",
	"                  [--date|-d] [--episode|-E] [--ts|-t]\n",
	"                  [--resume|-R] [--force|-F]\n",
	"                  [--outdir=dir|-O dir] [--indir=dir|-I dir]\n",
	"                  [--verbose|-v] [--Verbose=level|-V level] [--quiet|-q]\n",
	"                  [--index|-x]\n",
	"                  [--discover] [--wizpnpPoll=npoll] [--wizpnpTimeout=timeout]\n",
	"                  [ patterns... ]\n";
}

my $configDir;

if($^O eq 'MSWin32') {
    if(defined $ENV{APPDATA} and $ENV{APPDATA} ne '') {
	$configDir = catfile($ENV{APPDATA}, 'Prl', 'getWizPnP');
    }
} else {
    if(defined $ENV{HOME} and $ENV{HOME} ne '') {
	$configDir = $ENV{HOME};
    }
}

if(defined $configDir) {
    if(!-d $configDir) {
	eval { mkpath $configDir };
	if ($@) {
	    $configDir = undef;
	}
    }
}

my $config = defined $configDir && length($configDir) > 0
		? $configDir . '/' . CONFIG
		: CONFIG;


do $config if(-f $config);

GetOptions(
	'h|help'		=> \$help,
	'H|host=s'		=> \$host,
	'p|port=i'		=> \$port,
	'D|device=s'		=> \$device_name,
	'm|maxdevs=i'		=> \$maxdevs,
	'l|list'		=> \$list,
	'L|List'		=> \$List,
	's|sort=s'		=> \$sortCode,
	'i|dictionarySort=s'	=> \@dictionarySort,
	'S|dictStoplist:s'	=> \@dictStoplist,
	'f|folder:s'		=> \@folderList,
	'a|recursive|all!'	=> \$recursive,
	'X|delete'		=> \$delete,
	'M|move'		=> \$move,
	'n|dryrun'		=> \$dryrun,
	't|ts!'			=> \$ts,
	'd|date!'		=> \$date,
	'E|episode!'		=> \$episode,
	'R|resume!'		=> \$resume,
	'F|force!'		=> \$force,
	'r|regexp!'		=> \$regexp,
	'e|expression!'		=> \$expression,
	'B|BWName!'		=> \$bwName,
	'O|outdir:s'		=> \$outdir,
	'I|indir:s'		=> \$indir,
	'v|verbose+'		=> \$verbose,
	'V|Verbose=i'		=> \$verbose,
	'x|index!'		=> \$indexName,
	'discover'		=> \$discover,
	'wizpnpPoll=i'		=> \$wizpnpPoll,
	'wizpnpTimeout=f'	=> \$wizpnpTimeout,
	'q|quiet+'		=> \$quiet,
    ) or Usage;

# Class implementing a progress bar

{

    package ProgressBar;

    use Time::HiRes;

    my $accessorsDone;

    sub new() {
	my ($class) = @_;
	$class = ref($class) if(ref($class));

	my $self = {
	    total       => undef,
	    done        => undef,
	    starttime   => Time::HiRes::time,
	    percen      => 0,
	    totMb       => 0,
	    mb          => 0,
	    avgBuf      => [],
	    avgIndex    => 0,
	    avgBufSz => 21,
	    display     => '',
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
	    $self->starttime(Time::HiRes::time);
	    $self->percen(0);
	    $self->mb(0);
	    $self->totMb(int($val / (1024*1024) + 0.5));
	    $self->display('');
	}
	return $ret;
    }

    # Calculate the transfer rate since the last update, or if the
    # transfer is complete, the average transfer rate

    sub rate($) {
	my ($self) = @_;
        my ($startt, $endt, $startd, $endd);
	$endt = Time::HiRes::time;
	if($self->done >= $self->total) {
	    $startt = $self->starttime;
	    $startd = 0;
	    $endd = $self->total;
	} else {
	    $endd = $self->done;
	    $self->avgBuf->[$self->avgIndex] = {
					    time => $endt,
					    data => $endd,
					};
	    $self->avgIndex($self->avgIndex+1);
	    if($self->avgIndex >= $self->avgBufSz) {
		$self->avgIndex(0);
	    }
	    my $lastIndex = @{$self->avgBuf} < $self->avgBufSz
				? 0
				: $self->avgIndex;
	    $startt = $self->avgBuf->[$lastIndex]{time};
	    $startd = $self->avgBuf->[$lastIndex]{data};
	}
	return $startt != 0 && $endt > $startt 
		    ? ($endd - $startd)/
		      (($endt - $startt)*1024*1024)
		    : 0;
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
	    my $mb = int($self->{done} / (1024*1024) + 0.5);
	    if($percen != $self->percen
	    || $mb != $self->mb
	    || $self->display eq ''
	    || $self->{done} >= $self->total) {
		my $donestr = '=' x $donechars;
		my $leftstr = '-' x (50 - $donechars);
		my $now = Time::HiRes::time;
		my $dispstr = sprintf "\r|%s%s|%4.1fMiB/s %3d%% %.0f/%.0fMiB",
		    $donestr, $leftstr,
		    $self->rate,
		    $percen,
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

sub expandCommaList($;$$) {
    my ($list, $lc, $trailing) = @_;
    $trailing = 0 if(!defined $trailing);
    foreach my $i (0..$#$list) {
	my @f = split /,/, ($lc ? lc $$list[$i] : $$list[$i]), -$trailing;
	if($#f >= 0) {
	    $$list[$i] = $f[0];
	    push @$list, @f[1..$#f] if($#f > 0);
	} else {
	    $$list[$i] = '';
	}
    }
    return  $list;
}

sub processOpts() {

    $verbose = $verbose - $quiet;
    $verbose = 0 if($verbose < 0);

    die "Can't set more than one of --regexp, --expression or ---BWName\n"
	if($regexp + $expression + $bwName > 1);

    $mode = MODE_LIST   if(!@ARGV);
    $mode = MODE_DELETE if($delete);
    $mode = MODE_MOVE   if($move);
    $mode = MODE_LIST   if($list);
    $mode = MODE_LISTBW if($List);
    $mode = MODE_SEARCH if($discover);

    $matchType = MATCH_REGEXP if($regexp);
    $matchType = MATCH_EXPR   if($expression);
    $matchType = MATCH_BWNAME if($bwName);

    # Use default stop list if none given
    @dictStoplist = @defDictStoplist if(!@dictStoplist);
    @dictStoplist = @{expandCommaList(\@dictStoplist)};
    $dictStopRe = '^(' . join('|', @dictStoplist) . ') +'
	if(@dictStoplist);

    # Force folder name options to lower case
    # and expand comma-separated lists

    @folderList = @{expandCommaList(\@folderList, 1, 1)};

    # Convert '\' in folder names to '/',
    # and strip leading and trailing '/'s
    foreach my $f (@folderList) {
	$f =~ s,\\,/,g;
	$f =~ s,^/+,,;
	$f =~ s,/+$,,;
	$f =~ s,//+,/,g;
    }

    # If there are no folders, add the root folder.

    if(!@folderList) {
	push @folderList, '';
    }

    # Force dictionary sort options to lower case,
    # expand comma-separated lists, and set values in
    # %dictionarySort

    my $errs = 0;
    @dictionarySort = @{expandCommaList(\@dictionarySort, 1)};
    foreach my $d (@dictionarySort) {
	if(!exists $dictionarySortMap{$d}) {
	    warn "Unknown --dictionarySort option $d\n";
	    $errs++;
	    next;
	}
	$d = $dictionarySortMap{$d} if(defined $dictionarySortMap{$d});
	if($d eq 'exact') {
	    %dictionarySort = ();
	} elsif($d eq 'all') {
	    foreach my $k (keys %dictionarySortMap) {
		$dictionarySort{$k} = 1
		    if($k ne 'exact' && $k ne 'all'
		    && exists($dictionarySortMap{$k})
		    && !defined($dictionarySortMap{$k}));
	    }
	} else {
	    $dictionarySort{$d} = 1;
	}
    }
    die "--dictionarySort option errors\n"
        if($errs);
}

sub makeSortTitle($) {
    my ($title) = @_;
    $title =~ s/^MOVIE_ // if($dictionarySort{movie});
    if($dictionarySort{movie}) {
	if($dictionarySort{case}) {
	    $title =~ s/$dictStopRe//io;
	} else {
	    $title =~ s/$dictStopRe//o;
	}
    }
    $title = lc $title if($dictionarySort{case});
    $title =~ s/[^0-9a-z ]//g if($dictionarySort{punctuation});
    $title =~ s/ //g if($dictionarySort{space});
    return $title;
}

# Construct the ordered list of comparison
# functions to sort the file index list
# from the --sort sortcode argument

sub makeSortCmp($$$) {
    my ($sortCode, $sortCmpLookup, $sortCmp) = @_;
    die "Sort code must have an even number of characters\n"
	if(length($sortCode) % 2 != 0);
    foreach my $code ($sortCode =~ /(..)/g) {
	die "Unrecognised sort code: $code\n"
	    if(!exists $sortCmpLookup->{$code});
	if(!defined $sortCmpLookup->{$code}) {
	    @$sortCmp = ();
	    last;
	}
	push @$sortCmp, $sortCmpLookup->{$code}
    }
}

# Sort compare function using the sort functions in
# @sortCmp

sub sortCmp($$) {
    foreach my $cmpFn (@sortCmpFns) {
	my $cmp = &$cmpFn($_[0], $_[1]);
	return $cmp if($cmp);
    }
    return 0;
}

# Return the host:port string for the device.
# :port is omitted if the port is the default for the protocol.


sub deviceHostPort($) {
    my ($device) = @_;

    return $device->location->authority
	? $device->location->host . ':' . $device->location->port
	: '';
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

    $pnp->maxDevs($maxdevs);
    $pnp->wizpnpPoll($wizpnpPoll) if($wizpnpPoll > 0);
    $pnp->wizpnpTimeout($wizpnpTimeout) if($wizpnpTimeout > 0);

    my $device;

    if($host) {
	my $url = URI->new(Beyonwiz::WizPnP::DESC, 'http');
	$url->scheme('http');
	$url->host($host);
	$url->port($port);

	$pnp->addDevice($url);
	if($mode != MODE_SEARCH) {
	    die "Can't get a device description for $host\n"
		if($pnp->ndevices == 0);
	    $device = $pnp->device(($pnp->deviceNames)[0]);
	    die "Host $host isn't device $device_name, it's ",
		    $device->name, "\n",
		if(defined($device_name)
		&& lc($device_name) ne lc($device->name));
	}
    } else {
	print "Searching for at most $maxdevs device",
		($maxdevs != 1 ? 's' : ''), "\n"
	    if($verbose >= 1 && $maxdevs > 0);

	$pnp->search;

	if($mode != MODE_SEARCH) {
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
			"] but no device selected with --device\n"
		    if(!defined $device_name);
		$device = $pnp->device($device_name);
		die "Device $device_name isn't available. [",
			join(', ', $pnp->deviceNames), "] were found\n"
		    if(!$device);
	    }
	}
    }
    if($mode == MODE_SEARCH) {
	foreach my $name (sort $pnp->deviceNames) {
	    $device = $pnp->device($name);
	    printf "%-16s%s\n",  $device->name,
		deviceHostPort($device);
	}
	exit;
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

sub matchFolder($) {
    my ($f) = @_;
    $f = lc $f;
    foreach my $fe (@folderList) {
	return 1 if(($recursive ? substr($f, 0, length($fe)) : $f) eq $fe);
    }
    return 0;
}

# Return true if the mode is MODE_LIST and the argument list is empty,
# or the header matches the user pattern argument,
# and the recording isn't active, and the mode is not MODE_LIEST

sub matchRecording($$$) {
    my ($ie, $hdr, $mode) = @_;
    return 0 unless(matchFolder($ie->sortFolder));
    return 1 if($mode == MODE_LIST && @ARGV == 0);

    # Force lazy fetch if it hasn't already happened
    # and test for a valid header
    $hdr->loadMain if(!$hdr->validMain);
    return 0 if(!$hdr->validMain);

    return 0 if($mode != MODE_LIST && $hdr->inRec);
    $_ = testString($hdr)
	if(@ARGV);
    foreach my $a (@ARGV) {
	return 1 if($matchType == MATCH_SUBSTR && index(lc($_), lc($a)) >= 0);
	return 1 if($matchType == MATCH_REGEXP && $_ =~ /$a/i);
	return 1 if($matchType == MATCH_EXPR && eval($a));
    }
    return 0;
}

# Create a new index object for he recording source, either local or HTTP.

sub newIndex($$)
{
    my ($indir, $device) = @_;
    return defined $indir
	? Beyonwiz::Recording::FileIndex->new(
				$indir, \&makeSortTitle
			    )
	: Beyonwiz::Recording::HTTPIndex->new(
				$device->baseUrl, \&makeSortTitle
			    )
}

# Create a new recording object for he recording source, either local or HTTP.

sub newRecording($$$$$$$) {
    my ($indir, $device, $ts, $date, $episode, $resume, $force) = @_;
    return defined $indir
	? Beyonwiz::Recording::FileRecording->new(
			$indir, $ts, $date, $episode, $resume, $force
		    )
	: Beyonwiz::Recording::HTTPRecording->new(
			$device->baseUrl, $ts, $date, $episode, $resume, $force
		    );
}

# Create a new recording header object for he recording source,
# either local or HTTP.

sub newHeader($$$) {
    my ($indir, $device, $ie) = @_;
    return defined $indir
	? Beyonwiz::Recording::FileHeader->new($ie->name, $ie->path)
	: Beyonwiz::Recording::HTTPHeader->new(
    			$ie->name, $device->baseUrl, $ie->path
		    );
}

# Create a new recording file index object for he recording source,
# either local or HTTP.

sub newTrunc($$$) {
    my ($indir, $device, $ie) = @_;
    return defined $indir
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

# List, copy, move or delete the recording dependiing on $mode.
# If $indir us defined, it's the input directory for a local transfer.
# $device is the WixPnPDevice, $hdr is the header object,
# $ie is the IndexEntry object, $rec is the recording object.

sub doRecordingOperation($$$$$$) {
    my ($indir, $device, $hdr, $ie, $rec, $mode) = @_;

    my $trunc;

    # Force lazy fetch if it hasn't already happened
    # and test for a valid header
    $hdr->loadMain if(!$hdr->validMain);
    return if(!$hdr->validMain);

    print $hdr->service, ': ', $hdr->longTitle,
		($hdr->inRec          ? ' *RECORDING NOW' : ''),
		($mode == MODE_COPY   ? ' - Copy'         : ''),
		($mode == MODE_DELETE ? ' - Delete'       : ''),
		($mode == MODE_MOVE   ? ' - Move'         : ''),
		"\n";
    if($verbose >= 2 && $hdr->extInfo && length($hdr->extInfo) > 0) {
	$info = $hdr->extInfo;
	write STDOUT;
    }
    print "    Index name: ", $ie->name, "\n" if($verbose >= 3 || $indexName);
    if($verbose >= 1) {
	print "    ", scalar(gmtime($hdr->starttime)),
	    ' - ', scalar(gmtime($hdr->starttime + $hdr->playtime)),
	    "\n";
	printf "    playtime: %4d:%02d",
		int($hdr->playtime/60),  $hdr->playtime % 60;
	my $mbytes = ($hdr->endOffset - $hdr->startOffset)/(1024*1024);
	printf "    recording size: %8.1f MiB",
		$mbytes;
	printf "    bit rate: %5.1f Mib/s\n",
		$mbytes * 8 / $hdr->playtime;
	printf "    recording name: %s\n",
		$rec->getRecordingName($hdr, $ie->path, $rec->ts)
	    if($mode == MODE_COPY || $mode == MODE_MOVE);
    }
    if($verbose >= 3) {
	if($hdr->nbookmarks > 0) {
	    printf "    %4s %7s %14s\n", 'Num', 'Time', 'Bookmark';
	    for(my $i = 0; $i < $hdr->nbookmarks; $i++) {
		my $t = int($hdr->offsetTime($hdr->bookmarks->[$i]));
		printf "    %4d %4d:%02d %14s\n", $i,
		    int($t/60), $t % 60, $hdr->bookmarks->[$i];
	    }
	}
    }
    if($verbose >= 4) {
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
    if($verbose >= 5) {
	if($hdr->noffsets > 0) {
	    printf "    %4s %7s %14s\n", 'Num', 'Time', 'Rec Offset';
	    for(my $i = 0; $i < $hdr->noffsets; $i++) {
		printf "    %4d %4d:%02d %14s\n",
		    $i, int($i/6), $i * 10 % 60, $hdr->offsets->[$i];
	    }
	}
    }
    if(!$dryrun) {
	if($mode == MODE_MOVE) {
	    # Try to move recording by renaming it
	    my $status = $rec->renameRecording($hdr, $ie->path, $outdir);
	    if($status == RC_OK) {
		print "\n" if($verbose >= 1);
		return;
	    }
	}
	if($mode == MODE_COPY || $mode == MODE_MOVE) {
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
		if(!is_success($status)) {
		    warn "Download failed: ",
			    status_message($status), "\n";
		    return;
		}
	    } else {
		warn $ie->name, " skipped\n";
		return;
	    }
	}
	if($mode == MODE_DELETE || $mode == MODE_MOVE) {
	    if(!$trunc) {
		$trunc = newTrunc($indir, $device, $ie);
		$trunc->load;
	    }
	    if($trunc->valid) {
		my $status = $rec->deleteRecording(
					    $hdr, $trunc,
					    $ie->path,
					    $outdir,
					    undef
					);
		warn "Delete failed: ",
			status_message($status), "\n"
		    if(!is_success($status));
	    } else {
		warn $ie->name, " skipped\n"
	    }
	}
    }
    print "\n" if($verbose >= 1);

}

# Normal selection function for recordings using
# the default substring match, --regexp or --expression
# Determine whether to list or copy the recording.
# $device is the WixPnPDevice, $index is the Index object,
# $rec is the recording object.

sub scanRecordings($$$$$) {
    my ($indir, $device, $index, $rec, $mode) = @_;
    foreach my $ie (@{$index->entries}) {
	my $hdr = newHeader($indir, $device, $ie);

	doRecordingOperation($indir, $device, $hdr, $ie, $rec, $mode)
	    if(matchRecording($ie, $hdr, $mode));
    }
}


# Normal selection function for recordings using
# --BWName selection.
# Determine whether to list or copy the recording.
# $device is the WixPnPDevice, $index is the Index object,
# $rec is the recording object.

sub scanRecordingsBWName($$$$$) {
    my ($indir, $device, $index, $rec, $mode) = @_;
    my %args = map { ( $_ => 1 ) } @ARGV;
    foreach my $ie (@{$index->entries}) {
	if($args{$ie->name}) {
	    my $hdr = newHeader($indir, $device, $ie);

	    if(matchFolder($ie->sortFolder)) {
		# Force lazy fetch if it hasn't already happened
		# and test for a valid header
		$hdr->loadMain if(!$hdr->validMain);
		return if(!$hdr->validMain);

		if($mode == MODE_LIST || !$hdr->inRec) {
		    doRecordingOperation(
				$indir, $device, $hdr, $ie, $rec, $mode)
		}
	    }
	}
    }
}

Usage if($help);

processOpts();
makeSortCmp($sortCode, \%sortCmpLookup, \@sortCmpFns);

my $device;

# Get the connection as a WizPnPDevice in $device

if(!defined $indir) {
    $device = connectToBW($host, $maxdevs, $verbose);

    print 'Connecting to ', $device->name, ' (', deviceHostPort($device), ")\n"
	if($verbose >= 1 && $mode != MODE_SEARCH);
} elsif($mode == MODE_SEARCH) {
    exit;
}


# Load the recording index

my $index = newIndex($indir, $device);

$index->load;

die "Couldn't load index file from $host\n" if(!$index->valid);

$index->sort(\&sortCmp);

# Perform the copy or list operations

my $rec = newRecording($indir, $device, $ts, $date, $episode, $resume, $force);

if($mode == MODE_LISTBW) {
    foreach my $ie (@{$index->entries}) {
	print $ie->name, "\n"
	    if(matchFolder($ie->sortFolder));
    }
} else {
    if($matchType == MATCH_BWNAME) {
	scanRecordingsBWName($indir, $device, $index, $rec, $mode);
    } else {
	scanRecordings($indir, $device, $index, $rec, $mode);
    }
}
