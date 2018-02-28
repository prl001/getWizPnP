#!/usr/bin/perl

my $Copyright = 'Copyright 2008-2018 Peter Lamb.
See accompanying LICENSE file for redistribution conditions.';

=head1 NAME

getWizPnP - list and fetch recordings from a Beyonwiz DP series over the network using the WizPnP interface


=head1 SYNOPSIS

    getWizPnP [--help|-h] [--version]
              [--device dev|-D dev] [--maxdevs=devs|-m devs]
              [--longNames]
              [--host=host|-H host] [--port=port|-p port]
              [--list|-l] [--List|-L] [--check|-c]
              [--copy|-C] [--delete|-X] [--move|-M] [--dryrun|-n]
              [--media=exts] [--stopFolders=folderlist]
              [--nameFormat=fmt|-T fmt] [--dateFormat=fmt]
              [--folder=folderlist|-f folderlist]
              [--recursive|--all|-a]
              [--regexp|-r] [--expression|-e] [-BWName|-B]
              [--sort=sortcode|-s sortcode]
              [--dictionarySort=ignoretype|-i ignoretype]
              [--dictStoplist=words|-S words]
              [--date|-d] [--episode|-E]
              [--ts|-t] [--join|-j] [--stdout]
              [--before=datetime] [--since=datetime]
              [--reconstruct[=[maxscan],[frac],[fixed]]]
              [--resume|-R] [--force|-F][--retry=n]
              [--delay=time]
              [--outDir=dir|-O dir] [--inDir=dir|-I dir]
              [--verbose|-v] [--Verbose=level|-V level] [--quiet|-q]
              [--debug=debugcode] [--index|-x]
              [--discover] [--wizpnpPoll=npoll] [--wizpnpTimeout=timeout]
              [ recording match patterns... ]
 
=head1 DESCRIPTION

List, check, fetch, move or delete the recordings on a Beyonwiz DP series
PVR over the network using the I<WizPnP> interface.
If B<--L<inDir>> is specified, perform the same operations on
the computer where I<getWizPnP> is running.
B<--L<inDir>> is most useful in combination with B<--L<ts>>.

If no pattern arguments are given, then all recordings in the included folders
are listed.
Otherwise recordings matching any of the patterns are fetched
(or listed, moved or deleted, with B<--L<list>>, B<--L<move>> or B<--L<delete>>
respectively).

So:

    getWizPnP.pl

will list all recordings in the Beyonwiz's Recordings folder, while

    getWizPnP.pl Simpsons

will copy all recordings of I<The Simpsons> (and any other recordings with
"simpsons" in the title or episode name).

In the absence of B<--L<regexp>> or B<--L<expression>> a pattern matches
if it is a substring of the string I<servicename>B<#>I<longtitle>#I<date>,
case insensitive.
The I<longtitle> is just the title if the header has no episode information,
otherwise it is I<title>B</>I<episodename>.
The format of I<date> defaults to
I<yyyy>C<->I<mm>C<->I<dd> I<HH>C<->I<MM>, but it is changed by the
B<--L<dateFormat>>
option.
The default is
C<dateFormat=default>,
which itself is equivalent to
C<dateFormat=isoLike>.

For example:

    SC10 Canberra#MOVIE: Pride & Prejudice#2008-02-15 20-28

or

    WIN TV Canberra#Underbelly/Team Purana#2012-05-25 19-30

To download all recordings, an empty string will match everything:

    wizGetPnP.pl ''

Recordings are copied or moved to a name corresponding to their event name
(title) with any characters that are illegal in the file system changed to '_'.
The B<--L<date>> option adds the day and date of the recording to the name,
and the B<--L<episode>> option adds the episode name to the recording
name (if there is one set)
-- helpful for series recordings.
Downloaded recordings are placed in the current directory unless B<--L<outDir>>
has been specified.

When listing recordings, recordings that are currently recording are flagged
with C<*RECORDING NOW> next to the recording name,
recordings that have File Lock set are flagged with C<*LOCKED>,
and recordings with AC3 (Dolby Digital) are flagged C<*AC3>.
The tags are not part of the name for matching.
B<getWizPnP> won't fetch recordings that are currently in progress.

The default is for B<getWizPnP> to perform its operations on the
recordings directly in in the C<Recordings> folder (and not in its subfolders).
See the B<--L<folder>> option for how to view the contents of other folders,
and the B<--L<recursive>> option for how to perform operations on a folder
and all its subfolders.

=head1 BEYONWIZ NAMES

The default in B<getWizPnP> is to try to use the WizPnP
device discovery protocol
(Simple Service Discovery Protocol, SSDP) to find any Beyonwiz servers
on the local net.

To do this, the Perl library module C<IO::Socket::Multicast>
must be installed on the machine running B<getWizPnP>.
If it isn't, then device discovery can't be used, and the Beyonwiz
device must be addressed using B<--L<host>>
(and possibly also B<--L<port>>).
See the C<README.txt> file in the distribution folder for more details of
how to install missing modules.

Beyonwiz WizPnP servers allow you to set the name of each server
in C<< SETUP>Network>WizPnP>Name >>.

B<getWizPnP> works best if each server is given a different name.
This helps prevent confusion in other WizPnP clients, too.

If for some reason, you want to have WizPnP servers with the same name,
see the B<--L<longNames>> option.

If you want to have the B<--L<longNames>> set by default,
set the C<$longNames> variable in the
B<L<configuration file|/FILES>>.

More compact names for Beyonwiz devices are generated by
B<--L<longNames>> if the Perl library module C<IO::Interface::Simple>
is installed on the machine running B<getWizPnP>.
See the C<README.txt> file in the distribution folder for more details on
how to install missing modules.


=head1 ARGUMENTS

B<GetWizPnP> takes the following arguments:

=over 4

=item help

  --help
  -h

Print a short help message on I<stderr> and exit
(overrides all other options except B<--L<version>>).
When used with B<--L<version>>, prints the version
number, then the help message, and exits.

=item version

  --version

Print I<getWizPnP>'s version on I<stderr> and exit (overrides all other options
except B<--L<help>>). When used with B<--L<help>>, prints the version
number, then the help message, and exits.

=item device

  --device=dev
  -D device

Connect to a matching WizPnP I<device> as named in the Beyonwiz
C<< SETUP>Network>WizPnP>Name >>.
A name matches if I<dev> is a substring of the Beyonwiz name
(case ignored).
For example, C<--device=be> matches device name C<MyBeyonwiz>.

If no I<device> is named and the WizPnP search finds only one
WizPnP device, that device is used.
Otherwise, if a device is named but isn't found, I<getWizPnP>
returns with an error.

See B<--L<longNames>> for how to distinguish Beyonwiz servers whan they have
the same name.

=item maxdevs

  --maxdevs=devs
  -D devs

In a WizPnP search, stop searching when the number of WizPnP
devices found is I<devs>, rather than waiting for the search to
time out (currently 0.9 seconds).
If set to zero, there is no limit; the search continues looking
for devices until it times out.
I<Devs> defaults to 0 (exhaustive search).

=item longNames

    --longNames
    -N
    --nolongNames
    -noN

If your WizPnP servers do not have unique names (case is ignored), then using
B<--L<longNames>> adds a unique suffix to each server name so they can be
distinguished by B<--L<device>>. The long name consists of the name set
in C<< SETUP>Network>WizPnP>Name >> on the Beyonwiz, followed by the
host part of the device's IP address, and the WizPnP port number
(set in C<< SETUP>Network>WizPnP>Port >>), all separated by
minus signs (C<->).

If a server has name C<MyBeyonwiz>, IP address C<10.1.1.4>,
netmask C<255.255.255.0> and the default port number C<49152>,
then its long name would be C<MyBeyonwiz-4-49152>.

If the Perl library module C<IO::Interface::Simple>
is not installed on the machine running B<getWizPnP>,
then B<--L<longNames>> uses the full IP address of the Beyonwiz
device instead of its host address. In the example above,
the long name would be C<MyBeyonwiz-10.1.1.4-49152> if
C<IO::Interface::Simple> is not available.
No warning or error message is given if this form of long name is
used. See B<L</BEYONWIZ NAMES>> above.

=item host

  --host=host
  -h host

Connect to the I<host> (DNS name or dotted-quad IP address) instead of using
WizPnP search to find the Beyonwiz, or instead of the default set in the
B<L<configuration file|/FILES>>.

If the device name is specified with B<--L<device>> then the configuration
returned by I<host> that contains the WizPnP name of the device must match
(case insensitive) the device name given by B<--L<device>>.

Using B<--L<host>> potentially allows a Beyonwiz's recordings and media
files to be accessed anywhere on the Internet. Using WizPnP device discovery
will only work on the local (sub)net.

=item port

  --port=port
  -p port

Connect to the I<port> instead of the
Beyonwiz default (C<49152>), or the default set in the configuration
file (see B<L</FILES>> below).
I<Port> is ignored unless B<--L<host>> is set.

=item copy

  --copy
  -C

Copy the recordings.
This is the default operation if the command has selection I<patterns>.

=item list

  --list
  -l

List the matching recordings.
This is the default operation if the command has no selection I<patterns>.

=item delete

  --delete
  -X

Delete the matching recordings, rather than copying them.
If File Lock is set on the recording, the operation will be skipped and
a warning message printed.
The operation can be forced by using B<--L<force>>.
Delete uses an undocumented feature of WizPnP. See B<L</BUGS>>.

=item move

  --move
  -M

Move the specified recordings to the output directory.
Equivalent to a copy followed by a delete for each matching recording.
If File Lock is set on the recording, the operation will be skipped and
a warning message printed.
The operation can be forced by using B<--L<force>>.
Move uses an undocumented feature of WizPnP. See B<L</BUGS>>.

=item media

    --media=exts

Specify the set of file name extensions that are recognised as media files.
The default set can also be specified in the B<L<configuration file|/FILES>>.

Media file name extension matching is case-insensitive.

Beyonwiz TV and radio recordings on the computer running B<getWizPnP>
are also recognised if they have no filename extension on their
folder.
This is to allow recognition of recordings copied using old versions
of I<getWizPnP> which did not add a .tvwiz/.radwiz extension to the folder name.
This feature may be removed in future versions.

Recognition of these beyonwiz-format recordings cannot be controlled by
C<--media>.

The user-specified default can be over-ridden by the program defaults
by specifying exactly one extension option with the name B<default>,
i.e. C<--media=default>.
This means that there is no way to have C<default> as the only recognised
media file name extension.

Multiple extensions can be given either as a comma-separated list
in one option (e.g. C<--media=jpg,mpg>) or as multiple options
(e.g. C<--media=jpg --media=mpg>).

The program default set of extensions is:

    263   aac  ac3  asf   avi bmp    divx dts  gif
    h263  iso  jpeg jpg   m1s m1v    m2p  m2t  m2t_192
    m2v   m4a  m4p  m4t   m4v mkv    mov  mp3  mp4
    mpeg  mpg  ogg  pcm   png radwiz rpcm smi  srt
    sub   tiff ts   tvwiz vob wav    wiz  wma  wmv
    wmv9

This list was extracted from the B<wizdvp> binary in the Beyonwiz
firmware, and may have errors or omissions.

=item stopFolders

    --stopFolders=folderlist

I<folderList> is a comma-separated list of folder names that
are to be excluded when building the recordings & media list
on the local computer when B<--L<inDir>> is used.

On Windows and Cygwin this defaults to the folders
C<Recycled,RECYCLER,System Volume Information>,
on Mac OS X to C<.Trash,.Trashes>,
and on Unix and Linux systems to C<lost+found,.Trash>.

=item nameFormat

    --nameFormat=fmt
    -T fmt

Specify how the names of recordings and media files will be generated
when they are copied or moved. 
I<fmt> is a text string with codes in it that are expanded in the
file or folder name.

The general of the codes is B<%=>[I<sep>]I<code>.
I<Sep> is an optional separator character.
If the field specified by I<code> exists and is not empty,
then the field is preceded by a separator made up of I<sep>
with a single space before it, and a single space following it.
If I<sep> is not specified, then the field is simply appended
directly to the name being constructed.

The allowed values for I<code> are:

B<S>

The name of the broadcast service (e.g. ABC1)
that the file or recording was made from.
Will not be set for media that are not Beyonwiz recordings.

B<T>

The title of the recording or file.
Constructed from the file name for media files.

B<E>

The episode name of the recording.
Will not be set for media that are not Beyonwiz recordings.

B<D>

The date of the recording.
The most recently modified time for media files stored on computer
file systems.
The format of the date defaults to an ISO-likeformat C<YYYY-MM-DD HH-MM>
(e.g. 2009-02-22 20-30).
The format of the date can be set using B<--L<dateFormat>>.

Codes from B<--L<dateFormat>> are also interpreted if they are present
in I<fmt>, but it is probably cleaner to change the date format using
B<--L<dateFormat>>.

Any other text is included as-is in the generated name.

The default value for B<--L<nameFormat>> is C<%=T>.

A number of "canned" formats are available, and are specified
when I<fmt> is exactly equal to one of the format names:

B<default>

C<%=T>
Scrapheap Challenge

B<short>

C<%=T>
Scrapheap Challenge

B<series>

C<%=T%=-D%=-E>
Scrapheap Challenge - 2009-03-04 18-33 - The Scrappy Races Part 2

B<long>

C<%=S%=-T%=-D%=-E> -
ABC2 - Scrapheap Challenge - 2009-03-04 18-33 - The Scrappy Races Part 2

B<episodeonly>

C<%=E> -
The Scrappy Races Part 2


B<--L<nameFormat>> can be used to give a fixed name to a recording when
it is copied or moved, but care should be taken that only a single recording
is specified.

The rules for eliminating characters not permitted by the file system
still hold.
This means that, for example, ':' will not appear in a name generated
on Windows, even if you specify it explicitly.

The default B<--L<nameFormat>> can be set in the
B<L<configuration file|/FILES>> and the list of canned formats
can be modified or extended (user definitions override program definitions
where both are specified).

Also see B<--L<episode>>,  B<--L<date>> and B<--L<dateLast>>.

=item dateFormat

 --dateFormat=fmt

Uses the POSIX C<strftime> function
L<http://www.kernel.org/doc/man-pages/online/pages/man3/strftime.3.html>
to encode dates and times for the C<%=D> code in B<--L<nameFormat>>.
There is some variation in the codes supported in various
implementations of C<strftime>.
The perl documentation for C<strftime> recommends the
use of the codes C<aAbBcdHIjmMpSUwWxXyYZ%> for portability,
but you can use whatever codes your system allows.

B<--L<dateFormat>> defaults to C<%Y-%m-%d %H-%M>,
(e.g. 2009-02-22 20:30)
which uses only codes from the portable set.
This is the "canned" format C<default>, below.

A number of "canned" formats are available, and are specified
when I<fmt> is exactly equal to one of the format names:

B<default>

C<%Y-%m-%d %H-%M> - 2009-02-20 20-30

B<compat>

C<%a %b %e %Y> - Fri Feb 20 2009
(the date format formerly used in B<getWizPnP>)

B<readable>

C<%H:%M %a %b %e %Y> - 20:30 Fri Feb 20 2009 "human-readable" date/time
stamp that distinguishes the time of day.

B<isoLike>

C<%Y-%m-%d %H-%M> - 2009-02-20 20-30 - more readble, ISO-like
date, whose string sorts by time.

B<iso>

C<%Y%m%dT%H%M> - 20090220T2030 - strict ISO format, very compact,
string sorts by date.

B<unix>

C<%a %b %e %H:%M:%S %Z %Y> - Fri Feb 20 20:30:00 EST 2009 - traditional
Unix format.

The canned formats B<compat>, B<readable> and B<unix> use a common,
but possibly not completely portable day-of-month code, C<%e>.

The default B<--L<dateFormat>> can be set in the
B<L<configuration file|/FILES>> and the list of canned formats
can be modified or extended (user definitions override program definitions
where both are specified).

As in B<--L<nameFormat>>,
the rules for eliminating characters not permitted by the file system
still hold.
This means that, for example, ':' will not appear in a name generated
on Windows, even if it is specified explicitly.

=item folder

    --folder=foldername
    -f folder

Restrict the operations to the named folder.
More that one B<--L<folder>> option may be given, the operations apply to
all the named folders.
If no folders are named, operations are on the top level
recording folder (equivalent to specifying B<--folder=Recordings>
or B<-f recordings>).

Case is ignored in naming folders, even on Unix/Linux systems.

B<--L<folder>> defaults to C<--folder=recordings>. Older versions allowed
subfolders to be specified by their name relative to B<Recordings>
(e.g. B<recordings/Movies> was specified by C<--folder=Movies>).
Now the full name must be given, i.e. C<--folder=recordings/Movies>.
But you can now also specify C<--folder=content/Movies> (for example).
To see all recordings and media on the Beyonwiz,
use C<--folder=/ --all>.

Recordings can be specified with either relative or absolute path names,
but they have the same meaning. The path separator characters can
be either the Unix-like B</> or the DOS-like B<\>.
Case is ignored in folder name comparisons.
So B<Recordings/Movies/Comedy>,
B</recordings/movies/CoMeDy>
and B<recordings\movies\comedy>
all refer to the same folder (on Unix, the B<\> will need to be quoted).
Unlike Unix and DOS, folder names B<.> and B<..> have
no special meaning, and will simply cause any folder match to fail.

Media and recordings in the C<content> folder can also be accessed
using B<getWizPnP>, by using B<--L<folder>=content>.
Subfolders of C<content> can also be accessed in the same way as
in the recordings folder, for example as B<content/MovieArchive/Drama>.
Case is ignored in names here, too, and either B</> or B<\>
can be used as path separators.

To operate on everything on the Beyonwiz internal HDD, use
B<--L<folder>=/> B<--L<recursive>>.

If the Beyonwiz is running firmware 01.05.261 or earlier, only recordings
directly in the recordings folder are accessible,
and using anything but the default folder will mean that
no recordings are visible.

If B<--L<inDir>> is used, then all recordings in that folder will appear
to be in the top level folder seen by I<getWizPnP>.
If any foldername except C<--folder=> (or C<--folder=/>)
is used, no recordings will be found.

=item recursive

  --recursive
  --all
  -a
  --norecursive
  --noall
  --noa

Recursively examine all subfolders under the folders specified
by B<--L<folder>> for recordings, as well as just the recordings
directly in the spscified folders.

Has no effect if the Beyonwiz is running firmware 01.05.261 or earlier.

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
B<ta> (date and time of day ascending),
B<td> (date and time of day descending),
B<da> (date ascending) and
B<dd> (date descending).
The default I<sortcode> is B<faazta>
(folder name ascending, title alphabetic ascending, time ascending).
Date and time of day descending is to match the Beyonwiz default sort order
(and only sort order in older firmware).
Later codes in the string are only checked if entries are equal on
all earlier codes.
The default I<sortcode> sorts on folder name,
then title (not including episode title),
then from earliest to latest for the same title & folder name.

The detail sort order for sorting on title is controlled by
B<--L<dictionarySort>>, and the default order is C<exact>.

Case is ignored for the folder name sort order.

If the B<uu> code is used anywhere in the string, the output is unsorted.

Sorting on titles only works with Beyonwiz firmware 01.05.261
and later.
Even where it works, sorting by name of recordings on
the Beyonwiz may differ from the
strictly ACSII ordering of some punctuation,
because there's no fast way to get the exact title
punctuation.

On some earlier firmware, sorting on time won't work if the
recording has been renamed.

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

ignores any B<MOVIE:> substring at the start of a title
(case insensitive, even if the rest of the match is case sensitive);

B<punctuation> (B<p>)

ignores all characters except alphanumerics and white space;

B<space> (B<s>)

ignores white space in the title.

B<stoplist> (B<st>)

ignores any words in the I<dictStoplist> when they
occur at the start of a title (will only work correctly
on recordings with a B<MOVIE:> prefix if
B<movie> is also set);

B<case> (B<c>)

ignores case in alphabetic characters;

B<exact> (B<none>, B<e>, B<n>)

exact match (none of the above);

B<all> (B<a>)

all of the above, except B<exact>

The default is B<exact>.

The keywords are evaluated in order, and added to the default set
of options, except for B<exact>.
Using B<exact> clears all options and any  following options
become the only ones used.

    --dictionarySort=case,punctuation

adds B<case> and B<punctuation> to the current set of options.

    --dictionarySort=exact,case,punctuation

makes the options just B<case> and B<punctuation>.

Multiple B<--L<dictionarySort>> options may be used.

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

=item episode

  --episode
  -E
  --noepisode
  --noE

Add the recording episode name (if there is one) to the name of the
recording when it's downloaded.
Adds the episode name to the end of the B<--L<nameFormat>> string
after the date if it's set by B<--L<date>> or before the date
it it's set by B<--L<dateLast>>.
Useful for downloading series.

=item date

  --date
  -d
  --nodate
  --nod

Add the recording day and date (in the format set by B<--L<dateFormat>>)
to the name of the recording when it's downloaded.
Useful for downloading series.
Adds the date to the end of the B<--L<nameFormat>> string
before the episode name if it's set by B<--L<episode>>.
Using C<--date --episode> will generate names that sort in order of the
episode recording date if the default B<--L<dateFormat>> is used,
or if B<--L<dateFormat>> is any of B<default>, B<iso> or B<isoLike>.

=item dateLast

  --dateLast
  --nodateLast

Add the recording day and date (in the format set by B<--L<dateFormat>>)
to the name of the recording when it's downloaded.
Useful for downloading series.
Adds the date to the end of the B<--L<nameFormat>> string
after the episode name if it's set by B<--L<episode>>.

=item since

  --since=timeString

Restricts I<getWizPnP> to operate on recordings made since the time given in
the time string. If the time string specifies only the day,
it is recordings since 00:00 in the morning of the day concerned, so
C<--since today>
will operate on anything recorded today.

The format of I<timeString> is intended to allow for relatively free-form
conversational dates and times, as well as more formal dates, but some
uses may find them unintuitive.
For example, "1 day before yesterday" is not recognised, but
"yesterday 1 day ago" is recognised (as the same thing).

More documentation of the formats allowed is on CPAN
L<http://search.cpan.org/~schubiger/DateTime-Format-Natural-0.99/lib/DateTime/Format/Natural/Lang/EN.pm>. Dates with '/' are in the form d/m/y, not m/d/y.

=item since

  --before=timeString

Restricts I<getWizPnP> to operate on recordings made before the time given in
the time string. If the time string specifies only the day,
it is recordings before 00:00 in the morning of the day concerned, so
C<--before today>
will operate on anything recorded before (the start of) today.

See B<--L<since>> for the format of I<timeString>.

=item ts

  --ts
  -t
  --nots
  --not

Download Beyonwiz recordings as single C<.ts> (MPEG Transport Stream) files,
rather than copying in the Beyonwiz internal recording format.

B<--noL<ts>> and B<--not> undo the setting of this option;
useful if this option is set by default in the user's B<L<configuration file|/FILES>>.

=item stdout

  --stdout
  --nostdout

Output the downloaded recordings to standard output.
Sets B<--L<ts>> and B<--L<join>> if set, even if
B<--Lno<ts>> and B<--Lno<join>> are specified
in the command line.

Useful if you want to send the recording to standard output
of some other program, or use it in some other configuration
using POSIX pipes or similar.
Mainly intended for use to stream recordings and media direct
from the Beyonwiz to a player without the need for temporary files.

Only has any effect in the I<copy> and I<move>
operations (whether resulting from explicit command-line
options or implicitly).
Prints a warning message and has no other effect for other operations.

When B<--L<stdout>> is used with I<copy> and I<move>
operations any output that would normally be sent to standard output
(e.g, the output generated by B<--L<verbose>> or  B<--L<debug>>)
will be sent to standard error instead.

B<--noL<stdout>> undoes the setting of this option;
useful if this option is set by default in the user's
B<L<configuration file|/FILES>>.

B<--L<stdout>> gives a fatal error if standard output is is a terminal.

=item join

  --join
  -j
  --nojoin
  --noj

Download media files stored in Beyonwiz C<.wiz> folder as single files,
rather than copying in the Beyonwiz internal recording format.

Defaults to B<--L<join>>.
B<--noL<join>> is useful for copying media folders as-is
from the Beyonwiz for examination on a PC.

B<--noL<join>> and B<--noj> undo the setting of this option.

=item reconstruct

  --reconstruct[=[percen],[fixed],[maxscan],[minscan]]

Try to reconstruct the C<stat> and C<trunc> header files in the recording
if they are missing.
Sometimes "missing" header files have actually been renamed to incorrect
names by bugs in the Beyonwiz.
Even without B<--L<reconstruct>>, I<getWizPnP> will try some of the well-known
incorrect names.

Reconstruction should normally be able to recover unedited normal recordings
completely.

Edits in the recording performed on the Beyonwiz can only be
partially reconstructed.

Short cut-outs in the recording may re-appear in full.
Other edits are likely to no longer accurately reflect the original editing. 
Recordings trimmed at the end may have problems with navigation
in the last 30 sec or so of the recording.
Recordings from the timeshift buffer and recordings that have been trimmed
at the start may have some problems with navigation.
Recordings with internal editing may not play correctly across
the edit locations in the original.
Where a recording has gaps in the sequence of the data files that make up
the Beyonwiz native recording format, a list of these gaps is printed.
These are the locations where playback or navigation problems are most
likely to occur.

However, B<--L<reconstruct>> should be able to recover all the recording data
that is on the Beyonwiz, even if the recording does not play correctly on
the Beyonwiz.

The C<trunc> header file normally contains a list of all the parts of all
recording data files that make up the recording.
These are 32MiB files with names that are 4-digit numbers.
Unedited normal recordings start with file number C<0000>,
then C<0001>, C<0002>, etc.
Edited recordings and recordings from the timeshift buffer may not
start with C<0000> and may have breaks in the sequence.

The I<WizPnP> protocol that I<getWizPnP> uses does not allow I<getWizPnP>
to load a list of the recording data files from the Beyonwiz,
so it must scan for them.
The four optional parameters to B<--L<reconstruct>>,
I<percen>, I<fixed>, I<maxscan> and I<minscan>,
allow control of that scan.

I<Maxscan> is the maximum value of the data recording file number that
B<--L<reconstruct>> will use when it searches for the start of the recording.
It must be an integer between 0 and 9999.
I<Minscan> is used as the first value to test for the scan.
It is a fatal error for I<minscan> to exceed I<maxscan>.
Both are silently set to 9999 if they are greater than 9999.

Once the start of the recording has been found,
I<getWizPnP> estimates the upper limit of its scan to find the rest of the
files by dividing the recording size (in the C<header.tvwiz> header)
by 32MiB, and then adjusting this to allow for editing.
The number of files scanned is calculated as:
I<ceil>((I<size> * (1 + I<percen>/100) + I<fixed>) / 32MiB).

I<fixed> may take suffixes C<k>, C<M> or C<G> for 10^3, 10^6 and 10^9
respectively,
or C<ki>, C<Mi> or C<Gi> for 2^10, 2^20 or 2^30, respectively.
The suffix may be followed by an optional C<B>, which has no effect, so
C<4ki> and C<4kiB> both denote 4096 bytes.

If there is no suffix, I<fixed> is interpreted as a number of
recording data files.
That is, it is effectively has a multiplier of 32MiB,
C<5> as a value for I<fixed> denotes 167772160 bytes.

    --reconstruct

alone is equivalent to

    --reconstruct=0.2,5,200,0

Fields may be empty, and trailing empty fields may be omitted.
Empty fields leave the corresponding default unchanged, so:

    --reconstruct=,10

is equivalent to

    --reconstruct=0.2,10,200,0

=item resume

  --resume
  -R
  --noresume
  --noR

Allow resumption of downloading of recordings that appear to be incomplete.

=item force

  --force
  -F
  --noforce
  --noF

Allow downloads to overwrite existing recordings that appear to be complete.
If B<--L<reconstruct>> is also set, then also force reconstruction of the
C<stat> and C<trunc> header files even if they can be found.
The interaction with B<--L<reconstruct>> is mainly intended for debugging use.

=item retry

  --retry=n

Automatically try to resume recording downloads (B<--L<copy>> or B<--L<copy>>)
up to <n> times on particular kinds of HTTP error.
The I<n> retries are in addition to the initial download request.
There is a short pause (2 sec) before each attempted retry.
These retries resume recording downloads even if the original
download did not have B<--L<resume>> set.

At the moment, retries are only attempted for HTTP C<BAD_REQUEST> errors.

The main intention of this option is to help overcome a problem
with downloads from Windows systems, which occasionally fail with
C<BAD_REQUEST> for an unknown reason.

I<This option may be removed at some future time if the underlying problem
is fixed>.

=item delay

  --delay=time

Delay I<time> seconds between HTTP requests when downloading a
recording from a Beyonwiz. I<Time> may be given in floating point,
so using, say, C<--time=0.5> should work as expected.

The main intention of this option is to try to help overcome a
problem with downloads from Windows systems, which occasionally
fail with C<BAD_REQUEST> for an unknown reason.

I<This option may be removed at some future time if the underlying problem
is fixed>.

=item verbose

  --verbose
  -v

Provide more information. Each B<--L<verbose>> increases the verbosity
level by 1 from 0 (the default), or from the setting of
C<$verbose> in the B<L<configuration file|/FILES>>, if it is set there.

Verbosity level 1 lists some more details about
the recordings, and shows a progress indicator when copying.
The progress indicator shows the transfer rate for the last 20 mebibytes
copied while the transfer is running, and the average transfer rate
for the copy when the copy completes.
Level 2 includes the program synopsis, if there is one.
Level 3 includes a display of any bookmarks in the file.
Level 4 includes the recording's index name, even if B<--L<index>>
is not set.

The units used in the verbose listings are in terms of megabytes (MB)
and megabits (Mb).
Mega- is strictly used as meaning 10^6 (1000000),
not as a shorthand for mebi-, the ISO name for a multipler of
2^20 (1204*1024 = 1048576).
Mebi- is about 5% more than mega-.

See also B<--L<Verbose>>

=item Verbose

  --Verbose=level
  -V level

Sets the verbosity level to I<level>. This overrides any setting of
C<$verbose> in the B<L<configuration file|/FILES>>.

B<--L<Verbose>> and B<--L<verbose>> options are processed in order.
Assuming that C<$verbose> isn't set to non-zero in the config file,
C<-vv -V=1> sets the verbosity level to 1, but C<-V=1 -vv> sets it to 3.

Mixing B<--L<Verbose>> and B<--L<verbose>> probably doesn't help with
clarity in commands.

See also B<--L<verbose>>.

=item debug

  --debug=debugcodes

Prints some technical debugging information about a Beyonwiz recording.
The options print nothing for non-Beyonwiz media files.
The debug options are a comma-separated list of:

B<pids> prints the Transport Stream Packet IDs in the recording header,
along with the header "magic number" and version number.

B<trunc> prints information from the C<trunc> header file, and displays
a list of the file fragments that make up the recording.

B<offsets> prints a listing of the time/recording offset information
for the file. This can be a long listing (one line for every 10 seconds of
the recording).

B<stat> prints the recording size in the C<stat> file.

B<all> enables all debug options.

Any unique substring in debugcodes matches the option.
C<--debug=p,t> is equivalent to C<--debug=pids,trunc>.
If a I<debugcode> matches more than one option, a warning is printed
(this should not be possible with the current option set), but the operation
proceeds.

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

=item outDir

  --outDir=dir
  --outdir=dir
  -O dir

Save the recordings in I<dir> rather than in the current directory.
B<--outdir> is deprecated.

=item inDir

  --inDir=dir
  --indir=dir
  -I dir

Look for recordings in I<dir> on the local computer rather than on the
Beyonwiz.
B<--indir> is deprecated.

=item List

  --List
  -L

Produce only a list of the index names of the recordings in the recording
index file.
The options B<--L<folder>> and  B<--L<recursive>> apply to B<--L<List>>.

Intended for use by GUIs or other programs calling I<getWizPnP>.

=item check

  --check
  -c

Perform some basic consistency checks on the recordings and media
on the Beyonwiz, indicating missing and misnamed (in some instances)
header files, and checking that the sizes of the header files are correct.

Also check that all recording & media data files mentioned in the header files
are on the Beyonwiz.

Specifically:

=over

=item

Checks that the main header file exists (if one is expected)
and that it is the correct size, but it cannot distinguish between
a completely missing recording folder
and a folder that is missing its header file.

=item

Checks that the I<trunc> header file exists (if one is expected)
and that it is a valid size, and whether it is present
but under a known incorrect name.

=item

Checks that the I<stat> header file exists (if one is expected)
and that it is the correct size, and whether it is present
but under a known incorrect name.

=item

Checks that the data file indicated by each I<trunc> file entry is
large enough to contain the span of data indicated in the entry.
Checks that the recording offset of each I<trunc> entry after the first is
consistent with the corresponding offset and lenght of the previous
I<trunc> entry.
Makes no attempt to check the contents of the data files.

=back

The options B<--L<folder>> and  B<--L<recursive>> apply to B<--L<check>>.

If verbosity is non-zero, print the name of each recording and media file
as it is checked.
Normally only prints the names of recordings or media files where
there is an error found.

Without any further options, B<--L<check>> will only check recordings directly
contained in the C<Recordings> folder.

To check all recordings on the recording HDD, use:

	getWizPnP --check --recursive

To check all media files on the internal HDD, use:

	getWizPnP --check --folder=/Contents --recursive

And to check all the recordings and media on the recording drive:

	getWizPnP --check --folder=/ --recursive

B<B<--L<check>>> and ephemeral IP ports - Advanced Users

The process for B<--L<check>> produces large numbers of HTTP C<HEAD> requests
to test the existence and size of the files in the recordings it checks.
These requests tpically take much less time than the HTTP C<GET> requests that
ate used to fetch recording and media data from the Beyonwiz.
B<--L<check>> generates about 30 HTTP C<HEAD> requests for each 1GB of
recording data on the Beyonwiz.
Because of limitations in the Beyonwiz HTTP server,
each request creates a new TCP connection to the Beyonwiz.
The local (computer) side uses an IP port number in the ephemeral ports range,
and normally recovers the port number for reuse only 120 seconds
after the request completes.
The ports in the ephemeral ports range are shared by all applications
using the Internet.
Some older systems,
Windows XP in particular,
do not have a large number of these ports available,
typically only 3976 of them.
That is only enough to support B<--L<check>> to check about
130GB of recordings.
If the available ephemeral ports are all in use
(in this case mostly waiting the 120 seconds timeout after closing),
then applications using the Internet protocols (including I<getWizPnP>)
can fail to make connections.

For this reason, I<getWizPnP> limits the number of ports that
it holds in use by limiting the rate at which it issues HTTP
requests.
On systems that have only a small number of ephemeral ports available,
it limits its own use of ports to 20% of the total number available
(795 in the case of Windows XP).
On systems with more generaous ephemeral port allocations
(Windows Vista, Windows 7 and Windows 8, OS X and Linux)
it limits its use of ephemeral ports to 10% of the total available
number (10% of 16384, or 1638 ports).

These limitations mean that B<--L<check>> will take about
4.5 sec/GB of recordings on the Beyonwiz on Windows XP or earlier),
and will take about 2.1 sec/GB on systems with more ports available.

It is possible to increase the fraction of the available ephemeral ports that
I<getWizPnP> uses by setting
C<$Beyonwiz::Recording::HTTPAccessor::ephemPortsFrac>
in the I<getWizPnP> B<L<configuration file|/FILES>>.
It is probably inadvisable to set this value greater than 0.5 (50%).

It is possible to increase the number of ephemeral ports
available in Windows XP by modifications to the Registry
by following the "Resolution" instructions
in the Microsoft Support article
I<When you try to connect from TCP ports greater than 5000
you receive the error 'WSAENOBUFS (10055)'>
at L<http://support.microsoft.com/default.aspx?scid=kb;en-us;196271>.
If you do this, you need to correspondingly set the number of
available ephemeral ports by setting
C<$Beyonwiz::Recording::HTTPAccessor::numEphemPorts>
in the I<getWizPnP> B<L<configuration file|/FILES>>.
I<getWizPnP> otherwise has no way of discovering the number
of available ephemeral ports.
Make a backup of your Registry before modifying it
in this way.

If I<getWizPnP> does exhaust the available ephemeral ports,
it will retry the request several times.
The retries occur after a timeout, thus allowing
closed ephemeral ports in use to time out and become available.
If this happens, I<getWizPnP> may stall for up to 2 minutes.

=item BWName

  --BWName
  -B

The pattern arguments are recording index names as listed by B<--List>.
Can find Beyonwiz recordings faster than other matching methods,
because it doesn't scan the whole file list.
Unlike the other matching methods, must be an exact string match.
Not very user-friendly.
Intended for use by GUIs or other programs calling I<getWizPnP>.

Selection using B<--L<folder>> and  B<--L<recursive>> still applies
when using B<--L<BWName>>, so normally you'll want to use the same
folder and recursion options with B<--L<BWName>> as you used
with B<--L<List>> to generate the index name(s).

Beyonwiz index names can contain spaces, and these will normally need
to be quoted when including them in a command run by the operating
system's command-line shell.

=item discover

  --discover

Print a list of the discovered Beyonwiz WizPnP servers,
IP address and name, and exit.
As in normal operation, the maximum number of devices to search for
is set by B<--L<maxdevs>>.
If B<--L<inDir>> is set, no Beyonwiz device search is performed,
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
it is run as a piece of Perl code by I<getWizPnP>
just after the program defaults for options are set, and just before
command-line options are set, so it over-rides program defaults,
but not command-line options.

It is probably most useful for setting the default B<--L<device>>
or B<--L<host>> option, or making B<--L<episode>> set by default.

An example I<getWizPnP> configuration file file is included with the
I<getWizPnP> distribution, in the file C<getwizpnp.conf>.

The I<getWizPnP> configuration file can be specified explicitly by setting
the C<GETWIZPNPCONF> environment variable.
For example (on Unix Bourne-like shells like I<bash>):

    export GETWIZPNPCONF=~/mygetwizpnp.conf

If C<GETWIZPNPCONF> is set to the empty string, then no configuration
file is executed:

    export GETWIZPNPCONF=

=head1 PREREQUSITES

Uses packages
L<C<Beyonwiz::WizPnP>|Beyonwiz::WizPnP>,
L<C<Beyonwiz::Recording::HTTPAccessor>|Beyonwiz::Recording::HTTPAccessor>,
L<C<Beyonwiz::Recording::FileAccessor>|Beyonwiz::Recording::FileAccessor>,
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>,
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>,
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>,
L<C<Beyonwiz::Recording::Stat>|Beyonwiz::Recording::Stat>,
L<C<Beyonwiz::Recording::Recording>|Beyonwiz::Recording::Recording>,
L<C<Beyonwiz::Recording::Check>|Beyonwiz::Recording::Check>,
C<File::Spec::Functions>,
C<File::Path>,
C<HTTP::Status>,
C<Getopt::Long>,
C<POSIX>,
C<DateTime>,
C<DateTime::Format::Natural>.

=head1 BUGS

Although a limited amount of testing has not found any problems,
it is uncertain whether deleting a recording on the Beyonwiz
while it is currently being watched can cause any malfunction on the
Beyonwiz.
Normally, the playback of the recording is stopped with an error message
shortly after the recording is deleted.
This may be impolite to the person watching, but so far does not appear
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

If WizPnP device search is used and C<IO::Socket::Multicast> is not
available, I<getWizPnP> will exit with an error.
In this case, the Beyonwiz device must be specified
using B<--L<host>> (and B<--L<port>> if necessary).

There is presently no C<IO::Interface::Simple> module available
in the B<ppm> repository for ActivePerl 10.x for Windows.
This means that B<--L<longNames>> will use longer names
than it would if the module was available.
I<getWizPnP> will otherwise function normally.

See README.txt in the distribution for details on how to install
any Perl modules that I<getWizPnP> needs to allow it to run on
your system.

Uses C<bignum> for 64-bit integers, even when the underlying
Perl integers are 64 bits.

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

When a recording is deleted, the file player view won't be updated.
Navigating in the file player, or exiting it and re-entering it
does not update the view.

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

The inconsistencies in the file player and the WizPnP index caused
by B<--L<move>> and B<--L<delete>> can be fixed by entering the
file player and pressing the SOUNDTRACK (speaker/question mark)
button.

Sorting on titles does not work with Beyonwiz firmware 01.05.261
and earlier.
On some earlier firmware, sorting on time won't work if the
recording has been renamed.

Folder options (including sorting on folder name) do not work
with Beyonwiz firmware 01.05.261 and earlier.

B<--L<recursive>> has no effect if the Beyonwiz is running firmware
01.05.261 or earlier.

Folder options don't work properly in conjunction with B<--L<inDir>>.

Instant recordings will not sort in their correct alphabetic sequence
(sorting on time or date will work).

=cut

use strict;
use warnings;

my $VERSION = '0.5.4a';

use Beyonwiz::WizPnP;
use Beyonwiz::Recording::HTTPAccessor;
use Beyonwiz::Recording::FileAccessor;
use Beyonwiz::Recording::Index;
use Beyonwiz::Recording::Header;
use Beyonwiz::Recording::Stat qw(STAT);
use Beyonwiz::Recording::Trunc;
use Beyonwiz::Recording::Recording;
use Beyonwiz::Recording::Check;
use File::Spec::Functions qw(catfile);
use File::Path qw(mkpath);

use POSIX;
use DateTime;
use DateTime::Format::Natural;

use HTTP::Status qw(:constants :is status_message);
use Getopt::Long qw(:config no_ignore_case bundling);

use constant CONFIG => $^O eq 'MSWin32' ? 'getwizpnp.conf' : '.getwizpnp';

#use bignum; # Bug in Cygwin perl's handling of sort comparison routines

use constant MODE_LIST    => 0;
use constant MODE_LISTBW  => 1;
use constant MODE_CHECKBW => 2;
use constant MODE_COPY    => 3;
use constant MODE_MOVE    => 4;
use constant MODE_DELETE  => 5;
use constant MODE_SEARCH  => 6;

use constant MATCH_SUBSTR => 0;
use constant MATCH_REGEXP => 1;
use constant MATCH_EXPR   => 2;
use constant MATCH_BWNAME => 3;

use constant DEBUG_PIDS    => 1 << 0;
use constant DEBUG_TRUNC   => 1 << 1;
use constant DEBUG_OFFSETS => 1 << 2;
use constant DEBUG_STAT    => 1 << 3;
use constant DEBUG_ALL     => DEBUG_PIDS
			   | DEBUG_TRUNC
			   | DEBUG_OFFSETS
			   | DEBUG_STAT;

my %debugOpts = (
    pids    => DEBUG_PIDS,
    trunc   => DEBUG_TRUNC,
    offsets => DEBUG_OFFSETS,
    stat    => DEBUG_STAT,
    all     => DEBUG_ALL,
);

our $device_name;
our $host;
our $port = 49152;
our $maxdevs = 0;
our $outDir;
our $inDir;
our $sortCode = 'faazta';
our @folderList;
our @dictionarySort;
our @defDictStoplist = qw(A An The);
our $nameFormat = 'default';
our $dateFormat = 'default';
our $reconstruct;
our $reconMinScan = 0;
our $reconMaxScan = 200;
our $reconFrac = 0.2;
our $reconFixed = 5 * 32 * 2**20;
our $before;
our $since;


our (
	# initialised to 0
	$list,
	$List,
	$check,
	$delete,
	$copy,
	$move,
	$recursive,
	$regexp,
	$expression,
	$bwName,
	$dryrun,
	$date,
	$dateLast,
	$episode,
	$verbose,
	$debug,
	$indexName,
	$longNames,
	$quiet,
	$ts,
	$useStdout,
	$resume,
	$force,
	$retry,
	$help,
	$printVersion,
	$discover,
	$wizpnpPoll,
	$wizpnpTimeout,
    ) = ((0) x 29);

our (
	# initialised to 1
	$join,
    ) = ((1) x 1);

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

my %nameFormats = (
    default	=> '%=T',
    short	=> '%=T',
    series	=> '%=T%=-D%=-E',
    long	=> '%=S%=-T%=-D%=-E',
    episodeonly	=> '%=E',
);

our %userNameFormats = ();

my %dateFormats = (
    default	=> '%Y-%m-%d %H-%M',
    compat	=> '%a %b %e %Y',
    readable	=> '%H:%M %a %b %e %Y',
    isoLike	=> '%Y-%m-%d %H-%M',
    iso		=> '%Y%m%dT%H%M',
    unix	=> '%a %b %e %H:%M:%S %Z %Y',
);

our %userDateFormats = ();

my @defaultMediaExtensions = qw (
		263   aac  ac3  asf   avi bmp    divx dts  gif
		h263  iso  jpeg jpg   m1s m1v    m2p  m2t  m2t_192
		m2v   m4a  m4p  m4t   m4v mkv    mov  mp3  mp4
		mpeg  mpg  ogg  pcm   png radwiz rpcm smi  srt
		sub   tiff ts   tvwiz vob wav    wiz  wma  wmv
		wmv9
);
our @mediaExtensions;

my @defaultStopFolders =
	$^O eq 'MSWin32' || $^O eq 'cygwin'	# Windows
	    ? ('Recycled', 'RECYCLER', 'System Volume Information')
	: $^O eq 'darwin'			# OS X
	    ? ('.Trash', '.Trashes')
	:     ('lost+found', '.Trash');
my @stopFolders;

my %retryCodes = map { $_, 1 } (
			HTTP_BAD_REQUEST,
		    );
my $dictStopRe;
my %dictionarySort;
my @dictStoplist;
my @sortCmpFns;
my $debugStr;
my $mode = MODE_COPY;
my $matchType = MATCH_SUBSTR;
my $accessor;
my $parseDT;
my ($beforeDT, $sinceDT);

my @pids = qw( vidPID audPID PCRPID PMTPID );

my $outFile = \*STDOUT;
select($outFile);

sub Usage(;$) {
    my ($warn) = @_;
    my $message = "Usage: $0 [--help|-h] [--version]\n"
	. "                  [--device dev|-D dev] [--maxdevs=devs|-m devs]\n"
	. "                  [--longNames]\n"
	. "                  [--host=host|-H host] [--port=port|-p port]\n"
	. "                  [--list|-l] [--List|-L] [--check|-c]\n"
	. "                  [--copy|-C] [--delete|-X] [--move|-M] [--dryrun|-n]\n"
	. "                  [--media=exts] [--stopFolders=folderlist]\n"
	. "                  [--nameFormat=fmt|-T fmt] [--dateFormat=fmt]\n"
	. "                  [--folder=folderlist|-f folderlist]\n"
	. "                  [--recursive|--all|-a]\n"
	. "                  [--regexp|-r] [--expression|-e] [-BWName|-B]\n"
	. "                  [--sort=sortcode|-s sortcode]\n"
	. "                  [--dictionarySort=ignoretype|-i ignoretype]\n"
	. "                  [--dictStoplist=words|-S words]\n"
	. "                  [--date|-d] [--episode|-E]\n"
	. "                  [--ts|-t] [--join|-j] [--stdout]\n"
	. "                  [--before=datetime] [--since=datetime]\n"
	. "                  [--reconstruct[=[maxscan],[frac],[fixed]]]\n"
	. "                  [--resume|-R] [--force|-F][--retry=n]\n"
	. "                  [--delay=time]\n"
	. "                  [--outDir=dir|-O dir] [--inDir=dir|-I dir]\n"
	. "                  [--verbose|-v] [--Verbose=level|-V level] [--quiet|-q]\n"
	. "                  [--debug=debugcode] [--index|-x]\n"
	. "                  [--discover] [--wizpnpPoll=npoll] [--wizpnpTimeout=timeout]\n"
	. "                  [ recording match patterns... ]\n";

    if($warn) {
	warn $message;
    } else {
	die $message;
    }
}

sub Version($) {
    my ($do_exit) = @_;
    warn "$VERSION\n";
    exit(0) if($do_exit);
}

my $configDir;
my $config;

if(defined $ENV{GETWIZPNPCONF}) {
    $config = $ENV{GETWIZPNPCONF};
} else {
    if($^O eq 'MSWin32') {
	if(defined $ENV{APPDATA} and $ENV{APPDATA} ne '') {
	    $configDir = catfile($ENV{APPDATA}, 'Prl', 'getWizPnP');
	}
    } else {
	if(defined $ENV{HOME} and $ENV{HOME} ne '') {
	    $configDir = $ENV{HOME};
	}
    }
    $config = defined $configDir && length($configDir) > 0
		? $configDir . '/' . CONFIG
		: CONFIG;
}


do $config if(length($config) > 0 && -f $config);
warn "Config file: $@\n" if($@);

GetOptions(
	'version'		=> \$printVersion,
	'h|help'		=> \$help,
	'H|host=s'		=> \$host,
	'p|port=i'		=> \$port,
	'D|device:s'		=> \$device_name,
	'm|maxdevs=i'		=> \$maxdevs,
	'N|longNames!'		=> \$longNames,
	'l|list'		=> \$list,
	'L|List'		=> \$List,
	'c|check'		=> \$check,
	'X|delete'		=> \$delete,
	'C|copy'		=> \$copy,
	'M|move'		=> \$move,
	's|sort=s'		=> \$sortCode,
	'i|dictionarySort=s'	=> \@dictionarySort,
	'S|dictStoplist:s'	=> \@dictStoplist,
	'f|folder:s'		=> \@folderList,
	'a|recursive|all!'	=> \$recursive,
	'T|nameFormat=s'	=> \$nameFormat,
	'dateFormat=s'		=> \$dateFormat,
	'n|dryrun'		=> \$dryrun,
	't|ts!'			=> \$ts,
	'stdout!'		=> \$useStdout,
	'j|join!'		=> \$join,
	'd|date!'		=> \$date,
	'dateLast!'		=> \$dateLast,
	'E|episode!'		=> \$episode,
	'before=s'		=> \$before,
	'since=s'		=> \$since,
	'reconstruct:s'		=> \$reconstruct,
	'R|resume!'		=> \$resume,
	'F|force!'		=> \$force,
	'retry=i'		=> \$retry,
	'r|regexp!'		=> \$regexp,
	'e|expression!'		=> \$expression,
	'B|BWName!'		=> \$bwName,
	'O|outdir|outDir:s'	=> \$outDir,
	'I|indir|inDir:s'	=> \$inDir,
	'media=s'		=> \@mediaExtensions,
	'stopFolders:s'		=> \@stopFolders,
	'v|verbose+'		=> \$verbose,
	'V|Verbose=i'		=> \$verbose,
	'debug=s'		=> \$debugStr,
	'x|index!'		=> \$indexName,
	'discover'		=> \$discover,
	'wizpnpPoll=i'		=> \$wizpnpPoll,
	'wizpnpTimeout=f'	=> \$wizpnpTimeout,
	'q|quiet+'		=> \$quiet,
	'delay=f',		=> \$Beyonwiz::Recording::HTTPAccessor::reqDelay,
    ) or Usage;

# Class implementing a generic (no action) progress bar

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
	};

	bless $self, $class;

	unless($accessorsDone) {
	    Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	    $accessorsDone = 1;
	}

	return $self;
    }

    # Set newline character if needed to move to next line after display
    # Reset it when used

    sub newLine($;$) {
	return '';
    }

    # Return/set the total number of bytes to transfer

    sub total($;$) {
	my ($self, $val) = @_;
	my $ret = $self->{total};
	if(@_ == 2) {
	    $self->{total} = $val;
	    $self->{done} = 0;
	    $self->starttime(Time::HiRes::time);
	    $self->percen(0);
	    $self->mb(0);
	    $self->totMb(int($val / 1000000 + 0.5));
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
		      (($endt - $startt)*1000000)
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
	    my $mb = int($self->{done} / 1000000 + 0.5);
	    if($percen != $self->percen
	    || $mb != $self->mb
	    || $self->{done} >= $self->total) {
		$self->percen($percen);
		$self->mb($mb);
	    }
	}
	return $ret;
    }

}


# Class implementing a text progress bar

{

    package TextProgressBar;

    use Time::HiRes;

    our @ISA = qw( ProgressBar );

    my $accessorsDone;

    sub new() {
	my ($class) = @_;
	$class = ref($class) if(ref($class));

	my %fields = (
	    display     => '',
	    newLine	=> '',
	);

	my $self = ProgressBar->new;

	$self = {
	    %$self,
	    %fields,
	};

	bless $self, $class;

	unless($accessorsDone) {
	    Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	    $accessorsDone = 1;
	}

	return $self;
    }

    # Set newline character if needed to move to next line after display
    # Reset it when used

    sub newLine($;$) {
	my ($self, $nl) = @_;
	my $retVal;
	$retVal = $self->{newLine};
	if(@_ == 2) {
	    $self->{newLine} = $nl;
	} else {
	    $self->{newLine} = '';
	}
	return $retVal;
    }

    # Return/set the total number of bytes to transfer

    sub total($;$) {
	my ($self, $val) = @_;
	my $ret;
	if(@_ == 2) {
	    $ret = $self->SUPER::total($val);
	    $self->display('');
	    $self->newLine('');
	} else {
	    $ret = $self->SUPER::total;
	}
	return $ret;
    }

    # Return/set the total number of bytes transferred
    # Update the progress bar if the progress bar has changed.

    sub done($;$) {
	my ($self, $val) = @_;
	my $ret = $self->SUPER::done;
	if(@_ == 2) {
	    my $oldPercen = $self->percen;
	    my $mb = $self->mb;

	    $ret = $self->SUPER::done($val);

	    if($self->percen != $oldPercen
	    || $mb != $self->mb
	    || $self->display eq '') {
		my $donechars = int($self->percen / 2 + 0.5);
		my $donestr = '=' x $donechars;
		my $leftstr = '-' x (50 - $donechars);
		if($donechars <= 50) {
		    $donestr = '=' x $donechars;
		    $leftstr = '-' x (50 - $donechars);
		} else {
		    $donestr = '=' x 49;
		    $leftstr = '+';
		}
		my $dispstr = sprintf "\r|%s%s|%4.1fMB/s %3d%% %.0f/%.0fMB",
		    $donestr, $leftstr,
		    $self->rate,
		    $self->percen,
		    $self->mb, $self->totMb;
		print $dispstr;
		$self->display($dispstr);
		$self->newLine("\n");
	    }
	} else {
	    $ret = $self->SUPER::done;
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

sub mergeHash($$) {
    my ($to, $from) = @_;
    while(my ($k, $v) = each %$from) {
	$to->{$k} = $v;
    }
}

sub processTimeOpt($$$) {
    my ($name, $dtStr, $dt) = @_;

    return if(!defined $dtStr);

    $parseDT = DateTime::Format::Natural->new(
		    lang          => 'en',
		    format        => 'd/m/y',
		    prefer_future => 0,
		    time_zone     => 'local',
		    daytime       => {
					morning   => 06,
					afternoon => 13,
					evening   => 19
				    }
		)
	if(!defined $parseDT);
    die "$0: Can't construct date/time parser can't be constructed\n"
	if(!defined $parseDT);
    my $newDT = $parseDT->parse_datetime($dtStr);
    die "$0: Error in '--$name=$dtStr' - ",  $parseDT->error, "\n"
	if(!$parseDT->success);
    $newDT->set_time_zone('floating');
    $$dt = $newDT;
}

sub processDebug($) {
    my ($debugStr) = @_;
    return if(!$debugStr);
    my @opts = @{expandCommaList([$debugStr], 1)};
    foreach my $o (@opts) {
	my $matches = 0;
	foreach my $k (keys %debugOpts) {
	    if(length $o > 0 && $o eq substr $k, 0, length $o) {
		$debug |= $debugOpts{$k};
		$matches++;
	    }
	}
	if($matches == 0) {
	    warn "Unrecognised debug option $o\n";
	}
	if($matches > 1) {
	    warn "Debug option $o matches more than one option\n";
	}
    }
}

sub processOpts() {

    $verbose = $verbose - $quiet;
    $verbose = 0 if($verbose < 0);

    die "Can't set more than one of --regexp, --expression or ---BWName\n"
	if($regexp + $expression + $bwName > 1);

    $mode = MODE_LIST    if(!@ARGV);
    $mode = MODE_DELETE  if($delete);
    $mode = MODE_MOVE    if($move);
    $mode = MODE_COPY    if($copy);
    $mode = MODE_LIST    if($list);
    $mode = MODE_LISTBW  if($List);
    $mode = MODE_CHECKBW if($check);
    $mode = MODE_SEARCH  if($discover);

    if($useStdout) {
	if($mode == MODE_COPY || $mode == MODE_MOVE) {
	    $join = $ts = 1;
	    $outFile = \*STDERR;
	    select $outFile;
	    die "Redirect stdout away from a terminal if --stdout is set\n"
		if(-t STDOUT);
	} else {
	    warn "--stdout only has any effect on moves and copies\n";
	}
    }

    $matchType = MATCH_REGEXP if($regexp);
    $matchType = MATCH_EXPR   if($expression);
    $matchType = MATCH_BWNAME if($bwName);

    $device_name = '' if(!defined $device_name);

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

    # If there are no folders, add the default folder list.

    if(!@folderList) {
	push @folderList, ($inDir ? '' : 'recordings');
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

    @mediaExtensions = @{expandCommaList(\@mediaExtensions, 1)};
    if(@mediaExtensions == 0
    || @mediaExtensions == 1 && $mediaExtensions[0] eq 'default') {
	@mediaExtensions = @defaultMediaExtensions;
    }
    @stopFolders = @{expandCommaList(\@stopFolders, 0)};
    if(@stopFolders == 0
    || @stopFolders == 1 && $stopFolders[0] eq 'default') {
	@stopFolders = @defaultStopFolders;
    }

    mergeHash(\%nameFormats, \%userNameFormats);
    mergeHash(\%dateFormats, \%userDateFormats);
    $nameFormat = $nameFormats{$nameFormat}
	if(defined $nameFormats{$nameFormat}) ;
    $dateFormat = $dateFormats{$dateFormat}
	if(defined $dateFormats{$dateFormat}) ;
    $nameFormat .= "%=-D" if($date && !$dateLast);
    $nameFormat .= "%=-E" if($episode);
    $nameFormat .= "%=-D" if($date && $dateLast);

    if(!defined $reconstruct) {
	$reconstruct = 0;
    } else {
	$reconstruct = 1;
	my @vals = @{expandCommaList([$reconstruct])};
	if(defined($vals[0]) && $vals[0] ne '') {
	    if($vals[0] =~ /^(\d+(\.\d*)?|\.\d+)$/) {
		$reconFrac = $vals[0] / 100;
	    } else {
		die "Invalid format for reconstruct frac ", $vals[1], "\n";
	    }
	}
	if(defined($vals[1]) && $vals[1] ne '') {
	    if($vals[1] =~ /^(\d+)(k|M|G|ki|Mi|Gi)?B?$/) {
		$reconFixed = $1;
		if(defined $2) {
		    $reconFixed *= 10**3 if($2 eq 'k');
		    $reconFixed *= 10**6 if($2 eq 'M');
		    $reconFixed *= 10**9 if($2 eq 'G');
		    $reconFixed *= 2**10 if($2 eq 'ki');
		    $reconFixed *= 2**20 if($2 eq 'Mi');
		    $reconFixed *= 2**30 if($2 eq 'Gi');
		} else {
		    $reconFixed *= 32 * 2**20;
		}
	    } else {
		die "Invalid format for reconstruct fixed ", $vals[1], "\n";
	    }
	}
	if(defined($vals[2]) && $vals[2] ne '') {
	    if($vals[2] =~ /^\d+$/) {
		$reconMaxScan = $vals[2] <= 9999 ? $vals[2] : 9999;
	    } else {
		die "Invalid format for reconstruct maxscan ", $vals[2], "\n";
	    }
	}
	if(defined $vals[3] && $vals[3] ne '') {
	    if($vals[3] =~ /^\d+$/) {
		$reconMinScan = $vals[3] <= 9999 ? $vals[3] : 9999;
	    } else {
		die "Invalid format for reconstruct maxscan ", $vals[3], "\n";
	    }
	}
	warn "Reconstruct scan minimum > scan maximum\n"
	    if($reconMinScan > $reconMaxScan);
    }
    processTimeOpt('before', $before, \$beforeDT);
    processTimeOpt('since', $since, \$sinceDT);
    processDebug($debugStr);
}

sub joinFlag($) {
    my ($hdr) = @_;
    return $hdr->isTV || $hdr->isRadio
		? $ts
	 : $hdr->isMediaFolder
	 	? $join
	 : 0;
}

sub makeSortTitle($) {
    my ($title) = @_;
    $title =~ s/^movie: *//i if($dictionarySort{movie});
    if($dictionarySort{stoplist}) {
	if($dictionarySort{case}) {
	    $title =~ s/$dictStopRe//io;
	} else {
	    $title =~ s/$dictStopRe//o;
	}
    }
    $title = lc $title if($dictionarySort{case});
    $title =~ s/[^[:alnum:] ]//g if($dictionarySort{punctuation});
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

    return $device->hostIP . ':' . $device->portNum;
}

# Connect to a Beyonwiz WizPnP server and return
# its WizPnPDevice. If $host is set, use that as the
# server IP addr/DNS name.
# Otherwise search for up to $maxdevs servers,
# and return the matching server. If search is used, $device_name
# must match only one device.

sub connectToBW($$$) {
    my ($host, $maxdevs, $verbose) = @_; 
    my $pnp = Beyonwiz::WizPnP->new;

    $pnp->maxDevs($maxdevs);
    $pnp->wizpnpPoll($wizpnpPoll) if($wizpnpPoll > 0);
    $pnp->wizpnpTimeout($wizpnpTimeout) if($wizpnpTimeout > 0);
    $pnp->useLongNames($longNames);

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
	    $device = $pnp->devices->[0];
	    die "Host $host isn't device '$device_name', it's ",
		    $device->name, "\n",
		if(index(lc($device->name), lc($device_name)) < 0);
	}
    } else {
	print "Searching for at most $maxdevs device",
		($maxdevs != 1 ? 's' : ''), "\n"
	    if($verbose >= 1 && $maxdevs > 0);

	$pnp->search;

	if($mode != MODE_SEARCH) {
	    if($pnp->ndevices == 0) {
		die "Search for WizPnP devices failed\n";
	    } else {
		my @match_devs = $pnp->lookup($device_name);
		my %unique_names = map { $_->name, 1 } @match_devs;
		my @unique_names = keys %unique_names;
		die "Device '$device_name' isn't available.\n",
			"[", join(', ', $pnp->deviceNames), "] ",
			(@{$pnp->devices} == 1 ? 'was' : 'were'),
			" found\n"
		    if(!@match_devs);
		if(@match_devs > 1) {
		    warn "Device name '$device_name'",
			" matches more than one device:\n",
			    "    [",
				join(', ', map { $_->longName } @match_devs),
			    "] were found\n";
		    warn 'Use unique names for your Beyonwiz devices, or use',
			    " --longNames\n",
			    'to discriminate between devices',
			    " with the same name\n"
			if(!$longNames && @unique_names == 1);
		    exit(1);
		}
	        $device = $match_devs[0];
	    }
	}
    }
    if($mode == MODE_SEARCH) {
	foreach my $dev (@{$pnp->devices}) {
	    printf "%-21s %s\n", deviceHostPort($dev), $dev->name;
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
			POSIX::strftime($dateFormat, gmtime $hdr->starttime));
}

sub matchFolder($) {
    my ($f) = @_;
    $f = lc $f;
    foreach my $fe (@folderList) {
	return 1 if(($recursive ? substr($f, 0, length($fe)) : $f) eq $fe);
    }
    return 0;
}

# Make a DateTime object from a Unix time, in the UTC time zone

sub constructDT($) {
    my ($uTime) = @_;
    my ($second,$minute,$hour,$day,$month,$year) = gmtime($uTime);
    my $newDT = DateTime->new(
		    year      => $year + 1900,
		    month     => $month + 1,
		    day       => $day,
		    hour      => $hour,
		    minute    => $minute,
		    second    => $second,
		    time_zone => 'UTC',
		);
    $newDT->set_time_zone('floating');
    return $newDT;
}

# Return true if the mode is MODE_LIST and the argument list is empty,
# or the header matches the user pattern argument,
# and the recording isn't active, and the mode is not MODE_LIST

sub matchRecording($$$) {
    my ($ie, $hdr, $mode) = @_;
    return 0 unless(matchFolder($ie->sortFolder));

    return 0 if($mode != MODE_LIST && $hdr->inRec
	     && !defined($beforeDT) && !defined($sinceDT));

    # Force lazy fetch if it hasn't already happened
    # and test for a valid header
    $hdr->loadMain if(!$hdr->validMain);
    return 0 if(!$hdr->validMain);

    return 0 if($mode != MODE_LIST && $hdr->inRec);

    # Check that the recording start time is in the time range
    return 0
	if(defined($beforeDT)
	&& DateTime->compare($beforeDT, constructDT($hdr->starttime)) <= 0);
    return 0
	if(defined($sinceDT)
	&& DateTime->compare($sinceDT, constructDT($hdr->starttime)) > 0);

    return 1 if($mode == MODE_LIST && @ARGV == 0);

    # Construct the match string and
    # use $_ for the benefit of the eval() below

    $_ = testString($hdr)
	if(@ARGV);

    foreach my $a (@ARGV) {
	return 1 if($matchType == MATCH_SUBSTR && index(lc($_), lc($a)) >= 0);
	return 1 if($matchType == MATCH_REGEXP && $_ =~ /$a/i);
	return 1 if($matchType == MATCH_EXPR && eval($a));
    }
    return 0;
}

# Create a new index object for the recording source, either local or HTTP.

sub newIndex($$)
{
    my ($inDir, $device) = @_;
    return Beyonwiz::Recording::Index->new($accessor, \&makeSortTitle);
}

# Create a new recording object for the recording source, either local or HTTP.

sub newRecording($$$$$$$) {
    my ($inDir, $device, $join, $nameFormat, $dateFormat,
				$resume, $force) = @_;
    return Beyonwiz::Recording::Recording->new(
			$accessor, $join, $nameFormat, $dateFormat,
			$resume, $force
		    );
}

# Create a new recording header object for he recording source,
# either local or HTTP.

sub newHeader($$$) {
    my ($inDir, $device, $ie) = @_;
    return Beyonwiz::Recording::Header->new($accessor, $ie);
}

# Create a new recording file stat object for he recording source,
# either local or HTTP.

sub newStat($$$) {
    my ($inDir, $device, $ie) = @_;
    return Beyonwiz::Recording::Stat->new($accessor, $ie->name, $ie->path);
}

# Load or reconstruct the stat object

sub getStat($$$$$) {
    my ($stat, $inDir, $device, $ie, $hdr) = @_;
    $stat = newStat($inDir, $device, $ie) if(!defined $stat);
    if(!$stat->valid) {
	$stat->load;
	if($reconstruct && (!$stat->valid || $force) && $hdr->validMain) {
	    warn "Reconstructing stat header file\n";
	    $stat->reconstruct($hdr->endOffset);
	}
    }
    warn "Fetching ", $stat->fileName,
	    " from ", $stat->beyonwizFileName, "\n"
	if($stat->valid && $stat->fileName ne $stat->beyonwizFileName);
    return $stat;
}

# Create a new recording file trunc object for the recording source,
# either local or HTTP.

sub newTrunc($$$) {
    my ($inDir, $device, $ie) = @_;
    return Beyonwiz::Recording::Trunc->new($accessor, $ie->name, $ie->path);
}

# Load or reconstruct the trunc object

sub getTrunc($$$$$) {
    my ($trunc, $inDir, $device, $ie, $hdr) = @_;
    $trunc = newTrunc($inDir, $device, $ie) if(!defined $trunc);
    if(!$trunc->valid) {
	$trunc->load;
	if($reconstruct && (!$trunc->valid || $force)) {
	    warn "Reconstructing trunc header file\n";
	    my $targetSize = $hdr->endOffset - $hdr->startOffset;
	    $targetSize = int($targetSize * 1 + $reconFrac) + $reconFixed;
	    $trunc->reconstruct($reconMinScan, $reconMaxScan, $targetSize);
	    my $teStart = $trunc->entries->[0];
	    my $teEnd = $trunc->entries->[$trunc->nentries - 1];
	    $hdr->updateOffsets(
		    $teStart->wizOffset,
		    $teEnd->wizOffset + $teEnd->size
		);
	}
    }
    warn "Fetching ", $trunc->fileName,
	    " from ", $trunc->beyonwizFileName, "\n"
	if($trunc->valid && $trunc->fileName ne $trunc->beyonwizFileName);
    return $trunc;
}

# Format to write the extended info as multi-line, filled,
# left-justified.

my $info;
format EXTINFO =
~~  ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    $info
.

sub printRec($$$) {
    my ($hdr, $ie, $rec) = @_;
    print $hdr->service, ': ', $hdr->longTitle,
		($hdr->inRec			? ' *RECORDING NOW' : ''),
		($hdr->lock			? ' *LOCKED'        : ''),
		(($hdr->pidFlags(1) & 0x8000)	? ' *AC3'           : ''),
		($mode == MODE_COPY		? ' - Copy'         : ''),
		($mode == MODE_DELETE		? ' - Delete'       : ''),
		($mode == MODE_MOVE		? ' - Move'         : ''),
		"\n";
    if($verbose >= 2 && $hdr->extInfo && length($hdr->extInfo) > 0) {
	$info = $hdr->extInfo;
	$~ = 'EXTINFO';
	write;
    }
    print '    Index name: ', $ie->name, "\n"
	if($verbose >= 4 || $indexName);
    if($verbose >= 1) {
	print '    ', scalar(gmtime($hdr->starttime)),
	    ' - ', scalar(gmtime($hdr->starttime + $hdr->playtime)),
	    "\n";
	printf '    playtime: %s',
		$hdr->playtime >= 0
		    ? sprintf '%4d:%02d', int($hdr->playtime/60),
					     $hdr->playtime % 60
		    : '----:--';
	my $mbytes = ($hdr->endOffset - $hdr->startOffset)/1000000;
	printf "    recording size: %8.1f MB",
		$mbytes;
	printf "    bit rate: %s Mb/s\n",
		$hdr->playtime >= 0
		    ? sprintf '%5.1f', $mbytes * 8 / $hdr->playtime
		    : '-----';
	if(defined $hdr->autoDelete) {
	    if($hdr->autoDeleteFlags & 0x2) {
		my $delTime = gmtime($hdr->starttime + $hdr->autoDelete);
		$delTime = substr($delTime, 0, 10) . substr($delTime, 19);
		printf "    autoDelete: %d day%s (on %s)",
		    $hdr->autoDelete,
		    ($hdr->autoDelete == 1 ? '' : 's'),
		    $delTime;
	    } else {
		print "    autoDelete: Never";
	    }
	    print "\n";
	}
	printf "    recording name: %s\n",
		$rec->getRecordingName($hdr, $ie->name, $rec->join)
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
}

sub printPIDs($) {
    my ($hdr) = @_;
    printf "    magic: 0x%04x version: %d\n",
	$hdr->magic, $hdr->version;
    foreach my $p (0..3) {
	printf '   ' if(!($p & 1));
	my $pid = $hdr->pid($p);
	my $pFlags = $hdr->pidFlags($p);
	printf ' %s: %4d (0x%04x) %s',
	    $pids[$p], $pid, $pid,
	    ($p == 1 && ($pFlags & 0x8000) ? ' AC3' : '');
	printf "\n" if($p & 1);
    }
}

sub timeFromOffset($$) {
    my ($hdr, $off) = @_;
    my $offTime = $hdr->offsetTime($off);
    my $offHour = int($offTime / 3600);
    $offTime -= $offHour * 3600;
    my $offMin = int($offTime / 60);
    $offTime -= $offMin * 60;
    my $offSec = int($offTime + 0.5);
    return ($offHour, $offMin, $offSec);
}

sub printTrunc($$) {
    my ($hdr, $trunc) = @_;
    # Print offsets with %s rather than %d, because %d and %u force
    # conversion to internal integer size in ActivePerl
    printf "    Recording start offset: %19s\n",
	$hdr->startOffset;
    printf "    Recording end offset:   %19s\n",
	$hdr->endOffset;
    printf "    %4s %12s %10s %14s %8s %10s\n",
	'File', 'File Offset', 'Size', 'Rec Offset', 'Dup Flags',
	'Start Time';
    foreach my $tr (@{$trunc->entries}) {
	printf "    %04d %12u %10d %14s %9s %10s\n",
	    $tr->fileNum, $tr->offset,
	    $tr->size, $tr->wizOffset, 
	    (($tr->flags & 0xff) == 0xc3
	        ? sprintf '0x%02x', ($tr->flags & 0xff) 
		: ''),
	    sprintf '%02d:%02d:%02d', timeFromOffset($hdr, $tr->wizOffset);
    }
}

sub printTruncGaps($$) {
    my ($hdr, $trunc) = @_;
    if($trunc->nentries > 1) {
	my $printHdr = 1;
	for my $i (1..$trunc->nentries-1) {
	    if($trunc->entries->[$i-1]->fileNum
		    != $trunc->entries->[$i]->fileNum-1) {
		if($printHdr) {
		    print "    Edit gaps in recovered recording\n";
		    printf "    %4s %4s %10s\n",
			'From', 'To', 'Start Time';
		    $printHdr = 0;
		}
		printf "    %04d %04d %10s\n",
		    $trunc->entries->[$i-1]->fileNum,
		    $trunc->entries->[$i]->fileNum,
		    sprintf '%02d:%02d:%02d',
			timeFromOffset($hdr,
			    $trunc->entries->[$i]->wizOffset
			);
	    }
	}
    }
}

sub printStat($$) {
    my ($stat, $hdr) = @_;
    # Print offsets with %s rather than %d, because %d and %u force
    # conversion to internal integer size in ActivePerl
    printf "    Stat recording end offset: %14s\n", $stat->recordingEndOffset;
}

sub printOffsets($) {
    my ($hdr) = @_;
    if($hdr->noffsets > 0) {
	# Print offsets with %s rather than %d, because %d and %u force
	# conversion to internal integer size in ActivePerl
	printf "    %4s %7s %14s\n", 'Num', 'Time', 'Rec Offset';
	for(my $i = 0; $i < $hdr->noffsets; $i++) {
	    printf "    %4d %4d:%02d %14s\n",
		$i, int($i/6), $i * 10 % 60, $hdr->offsets->[$i];
	}
    }
}

# List, copy, move or delete the recording dependiing on $mode.
# If $inDir is defined, it's the input directory for a local transfer.
# $device is the WixPnPDevice, $hdr is the header object,
# $ie is the IndexEntry object, $rec is the recording object.

sub doRecordingOperation($$$$$$) {
    my ($inDir, $device, $hdr, $ie, $rec, $mode) = @_;

    my $trunc;
    my $stat;

    # Force lazy fetch if it hasn't already happened
    # and test for a valid header
    $hdr->loadMain if(!$hdr->validMain);
    return if(!$hdr->validMain);

    printRec($hdr, $ie, $rec);

    printPIDs($hdr) if(($debug & DEBUG_PIDS) && defined $hdr->magic);

    if($debug & DEBUG_TRUNC) {
	$trunc = getTrunc($trunc, $inDir, $device, $ie, $hdr);
	if(!$trunc->valid) {
	    warn "Can't load or reconstruct trunc file\n";
	}
    }

    if($debug & DEBUG_STAT) {
	$stat = getStat($stat, $inDir, $device, $ie, $hdr);
	if(!$stat->valid) {
	    warn "Can't load or reconstruct stat file\n";
	}
    }

    if($hdr->reconstructed) {
	print "After reconstruction:\n";
	printRec($hdr, $ie, $rec);
	printTruncGaps($hdr, $trunc) if(defined($trunc) && $trunc->valid);
    }

    if(($debug & DEBUG_STAT) && $stat->valid) {
	printStat($stat, $hdr);
    }
    if(($debug & DEBUG_TRUNC) && $trunc->valid) {
	printTrunc($hdr, $trunc);
    }
    printOffsets($hdr) if($debug & DEBUG_OFFSETS);

    if(($mode == MODE_DELETE || $mode == MODE_MOVE)
    && $hdr->lock && !$force) {
	warn "Recording ", $hdr->longTitle, " is locked, skipped\n";
	print "\n" if($verbose >= 1);
	return;
    }
    if(!$dryrun) {
	if($mode == MODE_MOVE) {
	    # Try to move recording by renaming it
	    my $status = $rec->renameRecording($hdr, $ie->path, $outDir);
	    if(is_success($status)) {
		print "\n" if($verbose >= 1);
		return;
	    }
	}

	if($mode == MODE_COPY || $mode == MODE_MOVE) {
	    $trunc = getTrunc($trunc, $inDir, $device, $ie, $hdr);
	    if(!$trunc->valid) {
		warn $ie->name,
		     " skipped - can't load or reconstruct trunc file\n";
		return;
	    }
	    $stat = getStat($stat, $inDir, $device, $ie, $hdr);
	    if($trunc->fileName eq STAT && !$stat->valid) {
		warn $ie->name,
		     " can't load or reconstruct stat file\n";
	    }
	    my ($progressBar, $status);
	    $progressBar = $verbose >= 1
				? TextProgressBar->new
				: ProgressBar->new;
	    $status = $rec->getRecording(
					$hdr, $trunc, $stat,
					$ie->name,
					$ie->path,
					$outDir,
					$useStdout,
					$progressBar
				    );
	    print $progressBar->newLine;
	    if($useStdout == 0) {
		my $retries = 0;
		while(!is_success($status) && $retryCodes{$status}
		   && $retries < $retry) {
		    warn "Copy failed: ",
			status_message($status), " - retrying\n";
		    sleep(2);
		    $progressBar = $verbose >= 1
					? TextProgressBar->new
					: ProgressBar->new;
		    $rec->resume(1);
		    $status = $rec->getRecording(
						$hdr, $trunc, $stat,
						$ie->name,
						$ie->path,
						$outDir,
						$useStdout,
						$progressBar
					    );
		    print $progressBar->newLine;
		    $retries++;
		}
	    }
	    if(!is_success($status)) {
		warn "Copy failed: ",
			status_message($status), "\n";
		return;
	    }
	}
	if($mode == MODE_DELETE || $mode == MODE_MOVE) {
	    $trunc = getTrunc($trunc, $inDir, $device, $ie, $hdr);
	    if(!$trunc->valid) {
		warn $ie->name,
		     " skipped - can't load or reconstruct trunc file\n";
		return;
	    }
	    $stat = getStat($stat, $inDir, $device, $ie, $hdr);
	    if($trunc->fileName eq STAT && !$stat->valid) {
		warn $ie->name,
		     " warning - can't load or reconstruct stat file\n";
	    }
	    my $status = $rec->deleteRecording(
					$hdr, $trunc, $stat,
					$ie->name,
					$ie->path,
					$outDir,
					undef
				    );
	    warn "Delete failed: ",
		    status_message($status), "\n"
		if(!is_success($status));
	}
    }
    print "\n" if($verbose >= 1 || $debug);

}

# Normal selection function for recordings using
# the default substring match, --regexp or --expression
# Determine whether to list or copy the recording.
# $device is the WixPnPDevice, $index is the Index object,
# $rec is the recording object.

sub scanRecordings($$$$) {
    my ($inDir, $device, $index, $mode) = @_;
    foreach my $ie (@{$index->entries}) {
	my $hdr = newHeader($inDir, $device, $ie);

	if(matchRecording($ie, $hdr, $mode)) {
	    my $rec = newRecording($inDir, $device, joinFlag($hdr),
				    $nameFormat, $dateFormat, $resume,
				    $force);

	    doRecordingOperation($inDir, $device, $hdr, $ie, $rec, $mode);
	}
    }
}


# Normal selection function for recordings using
# --BWName selection.
# Determine whether to list or copy the recording.
# $device is the WixPnPDevice, $index is the Index object,
# $rec is the recording object.

sub scanRecordingsBWName($$$$) {
    my ($inDir, $device, $index, $mode) = @_;
    my %args = map { ( $_ => 1 ) } @ARGV;
    foreach my $ie (@{$index->entries}) {
	if($args{$ie->name} && matchFolder($ie->sortFolder)) {
	    my $hdr = newHeader($inDir, $device, $ie);

	    # Force lazy fetch if it hasn't already happened
	    # and test for a valid header
	    $hdr->loadMain if(!$hdr->validMain);
	    return if(!$hdr->validMain);

	    if($mode == MODE_LIST || !$hdr->inRec) {
		my $rec = newRecording($inDir, $device, joinFlag($hdr),
					$nameFormat, $dateFormat,
					$resume, $force);
		doRecordingOperation(
			    $inDir, $device, $hdr, $ie, $rec, $mode)
	    }
	}
    }
}

sub checkRecordings($$$$) {
    my ($inDir, $device, $index, $mode) = @_;

    foreach my $ie (@{$index->entries}) {
	if(matchFolder($ie->sortFolder)) {
	    my $hdr = newHeader($inDir, $device, $ie);

	    my $checker = Beyonwiz::Recording::Check->new(
				*STDERR, $hdr->name , $verbose >= 1
			    );

	    $checker->checkHeader($hdr);

	    my $trunc = newTrunc($inDir, $device, $ie);
	    $checker->checkTrunc($trunc);

	    my $stat = newStat($inDir, $device, $ie);
	    $checker->checkStat($stat, $trunc);

	    $checker->checkTruncEntries($trunc);
	}
    }
}

Version(!$help) if($printVersion);

if($help) {
    Usage(1);
    exit(0);
}


processOpts();
makeSortCmp($sortCode, \%sortCmpLookup, \@sortCmpFns);

my $device;

# Get the connection as a WizPnPDevice in $device

if(!defined $inDir) {
    $device = connectToBW($host, $maxdevs, $verbose);

    print 'Connecting to ', $device->name, ' (', deviceHostPort($device), ")\n"
	if($verbose >= 1 && $mode != MODE_SEARCH);
} elsif($mode == MODE_SEARCH) {
    exit;
}

$accessor = defined $inDir
			? Beyonwiz::Recording::FileAccessor->new(
				$inDir, \@mediaExtensions, \@stopFolders
			    )
			: Beyonwiz::Recording::HTTPAccessor->new(
				$device->baseUrl
			    );


# Load the recording index

my $index = newIndex($inDir, $device);

$index->load;

die "Couldn't load index file from $host\n" if(!$index->valid);

$index->sort(\&sortCmp);

# Perform the copy or list operations

if($mode == MODE_LISTBW) {
    foreach my $ie (@{$index->entries}) {
	print $ie->name, "\n"
	    if(matchFolder($ie->sortFolder));
    }
} elsif($mode == MODE_CHECKBW) {
    checkRecordings($inDir, $device, $index, $mode);
} else {
    if($matchType == MATCH_BWNAME) {
	scanRecordingsBWName($inDir, $device, $index, $mode);
    } else {
	scanRecordings($inDir, $device, $index, $mode);
    }
}
