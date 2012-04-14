package Beyonwiz::Recording::HTTPAccessor;

=head1 NAME

    use Beyonwiz::Recording::HTTPAccessor;

=head1 SYNOPSIS

Provides access to media files via HTTP.

=head1 SUPERCLASS

Inherits from
L<C<Beyonwiz::Recording::Accessor>|Beyonwiz::Recording::Accessor>

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Accessor->new($base) >>

Create a new accessor object with the base URL
C<$base>.

=item C<< $a->base([$val]); >>

Returns (sets) the base path.

=item C<< $a->fileLenTime(@path); >>

Return C<($size, $modifiedTime)> for the given C<@path>,
where the components of C<@path> are joined to form a single path name.
C<$size> in bytes, C<$modifiedTime> is the time
the file was last modified as
Unix time (seconds since 00:00:00 Jan 1 1097 UTC).

=item C<< $a->readFileChunk($offset, $size, @path) >>

Read and return a chunk of the file length C<$size> at offset C<$offset>
from the file specified by C<@path>
where the components of C<@path> are joined to form a single path name.

Returns C<''> on failure.

=item C<< $a->readFile(@path) >>

Read and return the contents of the file specified by C<@path>
where the components of C<@path> are joined to form a single path name.

Returns C<undef> on failure.

=item C<< $a->loadIndex; >>

Read and return the contents of the WizPnP index file
located at C<< $h->base([$val]); >>.

Returns C<undef> on failure.

=item C<< $a->getRecordingFileChunk($rec, $path, $file,
        $off, $size, $outOff, $progressBar, $quiet); >>

Fetch a chunk of a recording corresponding to a single
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
and write it to C<< $self->outFileHandle >>.

C<$rec> is the asociated
L<C<Beyonwiz::Recording::Recording>|Beyonwiz::Recording::Recording>.
C<$path> is the path to the folder containing the recording's
files on the Beyonwiz.
C<$name> is the name of the recording folder or file
(if C<< $rec->join >> is true).
C<$file> is the name of the Beyonwiz file containing the chunk.
C<$off> and C<$size> is the chunk to be transferred.
If C<$outdir> is defined and not the empty string, the record file is
placed in that directory, rather than the current directory.
C<$outoff> is the offset to where to write the chunk into the output file.
C<< $progressBar->done($totalTransferred) >> is
called at regular intervals to update the progress bar
and C<< $progressBar->newLine >> is used to move to a new line if the progress
bar is being drawn on the terminal.
If C<$quiet> is true, then don't print an error message if the source file
can't be found.

Returns C<HTTP_OK> if successful.
Otherwise it will print a warning with the HTTP status
message of the HTTP operation that failed, and return that status.

=item C<< $r->getRecordingFile($path, $name, $inFile, $outdir, $outFile, $progressBar, $quiet); >>

Fetch a complete 0000, 0001, etc. recording file or header file from the
Beyonwiz. Note that more than one
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
may refer to any given file.

C<$path>, C<$name>, C<$outdir> and C<$quiet>
are as in I<getRecordingFileChunk>.

C<$inFile> and C<$outFile> are the names of the input and output files
within the recording.
They are normally only different if for header files being retrieved
from an incorrect name in the recording.

C<< $progressBar->newLine >> is used to move to a new line if the progress
bar is being drawn on the terminal.

Returns C<HTTP_OK> if successful.
Otherwise it will return the HTTP error status.

=item C<< $r->renameRecording($hdr, $path, $outdir) >>

Move a recording described by C<$hdr> and the given
source C<$path> (from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>)
to C<$outdir> by renaming the recording directory.
Returns C<HTTP_OK> if successful.

On Unix(-like) systems, C<renameRecording> will  fail if the source
and destinations for the move are on different file systems.
It will also fail if C<< $r->join >> is true and it will fail if
the source recording is on the Beyonwiz.
In all these cases, it will return C<HTTP_NOT_IMPLEMENTED>,
and not print a warning.

For other errors it will print a warning with the system error message,
and return one of
C<HTTP_FORBIDDEN>,
C<HTTP_NOT_FOUND>
or C<HTTP_INTERNAL_SERVER_ERROR>.

=item C<< $r->deleteRecordingFile($path, $name, $file) >>

Delete a recording file.
C<$path> is the path name from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.
C<$name> is the name of the recording,
and C<$file> is the name of the file within the recording to delete.

Returns C<HTTP_OK> if successful.
Otherwise it will print a warning with the HTTP status
message of the HTTP operation that failed, and return that status.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::Accessor>|Beyonwiz::Recording::Accessor>,
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>,
L<C<Beyonwiz::Recording::Recording>|Beyonwiz::Recording::Recording>,
C<LWP::Simple>,
C<URI>,
C<URI::Escape>,
C<HTTP::Status>,
C<POSIX>.

=cut

use warnings;
use strict;
use bignum;

use Beyonwiz::Recording::Accessor;

use Beyonwiz::Recording::Index qw(INDEX);
use Beyonwiz::Recording::Recording qw(addDir);
use LWP::Simple qw(get getstore head $ua);
use URI;
use URI::Escape;
use HTTP::Status qw(:constants :is);
use POSIX;

our @ISA = qw( Beyonwiz::Recording::Accessor );

my $accessorsDone;
my $uaDone;

our $numEphemPorts;
our $ephemPortsFrac;

sub new() {
    my ($class, $base) = @_;
    $class = ref($class) if(ref($class));

    if(!$uaDone) {
	$ua = LWP::UserAgentRetry->new(retrytimeout => 15);
	$uaDone = 1;
    }

    my %fields = (
	base    => $base,
    );

    my $self = Beyonwiz::Recording::Accessor->new;

    $self = {
	%$self,
	%fields,
    };

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return bless $self, $class;

}

sub _uriPathEscape($) {
    my ($path) = @_;
    return uri_escape($path, "^A-Za-z0-9\-_.!~*'()/");
}

sub joinPaths($@) {
    my ($self, @path) = @_;
    return join '/', @path;
}

sub fileLenTime($@) {
    my ($self, @path) = @_;
    my $url = $self->base->clone;
    $url->path(_uriPathEscape $self->joinPaths(@path));
    my (undef, $documentLength, $modifiedTime) = head($url);
    return ($documentLength, $modifiedTime);
}

sub readFileChunk($$$@) {
    my ($self, $offset, $size, @path) = @_;

    my $url = $self->base->clone;
    $url->path(_uriPathEscape $self->joinPaths(@path));

    my $request = HTTP::Request->new(GET => $url);
    $request->header(range => "bytes=$offset-" . ($offset+$size-1));

    my $response = $ua->request($request);

    if($response->is_success && defined $response->content) {
	return $response->content;
    }

    return '';
}

sub readFile($@) {
    my ($self, @path) = @_;

    my $url = $self->base->clone;
    $url->path(_uriPathEscape $self->joinPaths(@path));

    return get($url);
}

sub loadIndex($) {
    my ($self) = @_;
    my $index_data = $self->readFile(INDEX);
    if(defined $index_data) {
	my $index = [];
	my $prefix = 'recordings';
	foreach my $rec (split /\r?\n/, $index_data) {
	    my @parts = split /\|/, $rec;
	    if(@parts == 2) {
		$parts[1] =~ s:/[^/]*\.((tv|rad)wizts|wiz)$::;
		push @$index,
			[ join('/', $prefix, $parts[0]), $parts[1] ];
	    } elsif(@parts == 1 && substr($parts[0], 0, 1) eq "\t") {
		$prefix = 'contents' if($parts[0] eq "\tidehdd/contents");
		next;
	    } else {
		warn "Unrecognised index entry: $rec\n";
	    }
	}
	return $index
    }
    return undef;
}

sub getRecordingFileChunk($$$$$$$$$$) {
    my ($self, $rec, $path, $file,
        $off, $size, $outOff, $progressBar, $quiet) = @_;

    my $data_url = $self->base->clone;

    $data_url->path(_uriPathEscape($file ne '' ? $path . '/' . $file : $path));

    # Avoid trying to seek on pipes and FIFOs
    if(!(-s $self->outFileHandle || -p $self->outFileHandle)
    && !sysseek $self->outFileHandle, $outOff, SEEK_SET) {
	warn( $progressBar->newLine,
	     'Seek error on ', $self->outFileName, ": $!\n" );
	$self->closeRecordingFileOut;
	return HTTP_BAD_REQUEST;
    }

    my $request = HTTP::Request->new(GET => $data_url);
    $request->header(range => "bytes=$off-" . ($off+$size-1));

    my $progressCount = 0;
    my $response = $ua->request($request,
			sub($$$) {
			    # Use $_[0] for $content, to avoid copying
			    # the data...
			    syswrite $self->outFileHandle, $_[0]
				or die ( $progressBar->newLine,
					'Write error on ',
					$self->outFileName, ": $!\n" );
			    $progressCount += length $_[0];
			    if($progressCount > 256 * 1024) {
				$progressBar->done(
					$progressBar->done
					+ $progressCount
				    );
				$progressCount = 0;
			    }
			}
		    );

    my $status = $response->code;

    $progressBar->done($progressBar->done + $progressCount);

    warn( $progressBar->newLine,
	    'Error fetching ', $self->outFileName, ' ',
	    ($file ne '' ? $path . '/' . $file : $path), ': ',
	    $response->status_line, "\n" )
	if(!$quiet && !is_success($status));
    return $status;
}

sub getRecordingFile($$$$$$$$) {
    my ($self, $path, $name, $inFile, $outdir, $outFile,
        $progressBar, $quiet) = @_;

    my $data_url = $self->base->clone;

    $data_url->path(_uriPathEscape($self->joinPaths($path, $inFile)));
    $name .= '/' . $outFile;
    $name = addDir($outdir, $name);

    my $request = HTTP::Request->new(GET => $data_url);
    my $response = $ua->request($request, $name);
    my $status = $response->code;

    warn( $progressBar->newLine, $name, ': ', $response->status_line, "\n")
	if(!$quiet && !is_success($status));

    return $status;
}

sub deleteRecordingFile($$$$;$) {
    my ($self, $path, $name, $file) = @_;

    my $data_url = $self->base->clone;

    if(defined $file) {
	$data_url->path(_uriPathEscape($self->joinPaths($path, $file)));
    } else {
	$data_url->path(_uriPathEscape $path);
    }

    my $request = HTTP::Request->new(DELETE => $data_url);
    my $response = $ua->request($request);
    my $status = $response->code;

    warn $name, ': ', $response->status_line, "\n"
	if(!is_success($status));

    return $status;
}

{
    package LWP::UserAgentRetry;

    use vars qw(@ISA);
    use LWP::UserAgent;
    use Beyonwiz::Utils;
    use HTTP::Status qw(:constants);

    our @ISA = qw(LWP::UserAgent);

    my $accessorsDone;

    my @portTimeQueue;


    use constant PORTWAIT => 120;
    use constant EPORTSSMALL => 5000 - 1024;
    use constant EPORTSLARGE => 65536 - 49152;

    my $hasWin32;

    my $sleepResid = 0;

    BEGIN {
	$hasWin32 = Beyonwiz::Utils::tryUse Win32;
    }

    sub new {
	my ($class, %config) = @_;
	$class = ref($class) if(ref($class));

	my $retrytimeout = delete $config{retrytimeout};

	my $self = LWP::UserAgent->new(%config);

	unless($accessorsDone) {
	    Beyonwiz::Utils::makeAccessors(__PACKAGE__,
					    qw(retrytimeout portuse));
	    $accessorsDone = 1;
	}

	$self->{retrytimeout} = $retrytimeout;

	my ($numPorts, $ephemFrac);


	if($^O eq 'MSWin32' || $^O eq 'cygwin') {
	    if($hasWin32) {
		my (undef, $major, $minor, undef, $id) = Win32::GetOSVersion();
		if($id >= 2 && $major >= 6) {
		    $numPorts = defined($numEphemPorts)
					? $numEphemPorts
					: EPORTSLARGE;
		    $ephemFrac = defined($ephemPortsFrac)
					? $ephemPortsFrac
					: 0.1;
		} else {
		    $numPorts = defined($numEphemPorts)
					? $numEphemPorts
					: EPORTSSMALL;
		    $ephemFrac = defined($ephemPortsFrac)
					? $ephemPortsFrac
					: 0.2;
		}
	    } else {
		warn "Can't determine Windows variant,",
		     ' using small port range: ',
		     "Can't load Win32 module\n";
		$numPorts = defined($numEphemPorts)
				    ? $numEphemPorts
				    : EPORTSSMALL;
		$ephemFrac = defined($ephemPortsFrac)
				    ? $ephemPortsFrac
				    : 0.2;
	    }
	} else {
	    $numPorts = defined($numEphemPorts)
				? $numEphemPorts
				: EPORTSLARGE;
	    $ephemFrac = defined($ephemPortsFrac)
				? $ephemPortsFrac
				: 0.1;
	}

	$ephemFrac = 0 if($ephemFrac < 0);
	$ephemFrac = 1 if($ephemFrac > 1);

	$self->{portuse} = int($numPorts * $ephemFrac);

	return bless $self, $class;
    }

    sub _dequeuePorts($) {
	my ($self, $now) = @_;
	while(@portTimeQueue && $now - $portTimeQueue[0] >= PORTWAIT) {
	    shift @portTimeQueue;
	}
    }

    sub request {
	my ($self, @args) = @_;
	my $response;

	my $portUse = $self->portuse;

	my $now = time;



	$self->_dequeuePorts($now) if($portUse > 0);

	while($portUse > 0 && @portTimeQueue > 0) {
	    my $sleeptime;
	    if(@portTimeQueue >= $portUse - 1) {
		$sleeptime =  PORTWAIT - $now + $portTimeQueue[0];
	    } else {
		$sleeptime = int((PORTWAIT * @portTimeQueue / $portUse)
		      - $portTimeQueue[-1] + $portTimeQueue[0] + 0.5);
	    }
	    last unless($sleeptime > 0);
	    sleep $sleeptime;
	    $now = time;
	    $self->_dequeuePorts($now);
	    last if(@portTimeQueue <= $portUse);
	}

	my $retrytimeout = $self->retrytimeout;
	my $repeat = 1;
	$repeat = int(($self->timeout + $retrytimeout - 1) / $retrytimeout)
	    if($retrytimeout);
	$repeat = 1 if($repeat < 1);
	foreach my $i (1..$repeat) {
	    $response = $self->SUPER::request(@args);
	    last if($response->code != HTTP_INTERNAL_SERVER_ERROR
		 && ($response->status_line !~ /timeout/));
	}

	push @portTimeQueue, time if($portUse > 0);

	return $response;
    }

}

1;
