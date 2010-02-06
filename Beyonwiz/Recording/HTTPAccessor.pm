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

=item C<< $a->getRecordingFileChunk($rec, $path, $name, $file, $outdir,
        $append, $off, $size, $outOff, $progressBar); >>

Fetch a chunk of a recording corresponding to a single
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>.

C<$rec> is the asociated
L<C<Beyonwiz::Recording::Recording>|Beyonwiz::Recording::Recording>.
C<$path> is the path to the folder containing the recording's
files on the Beyonwiz.
C<$name> is the name of the recording folder or file
(if C<< $rec->join >> is true).
C<$file> is the name of the Beyonwiz file containing the chunk.
C<$append> is false if C<$file> is to be created, true if
it is to be appended to.
C<$off> and C<$size> is the chunk to be transferred.
If C<$outdir> is defined and not the empty string, the record file is
placed in that directory, rather than the current directory.
C<$outoff> is the offset to where to write the chunk into the output file.
C<$progressBar> is as defined below in C<< $r->getRecordng(...) >>.

Returns C<RC_OK> if successful.
Otherwise it will print a warning with the HTTP status
message of the HTTP operation that failed, and return that status.

=item C<< $r->getRecordingFile($rec, $path, $name, $outdir, $file, $append); >>

Fetch a complete 0000, 0001, etc. recording file or header file from the
Beyonwiz. Note that more than one
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
may refer to any given file.

C<$rec> C<$path>, C<$name>, C<$outdir>, C<$file>, C<$outdir>
and C<$append> are as in I<getRecordingFileChunk>.

Returns C<RC_OK> if successful.
Otherwise it will print a warning with the HTTP status
message of the HTTP operation that failed, and return that status.

=item C<< $r->renameRecording($hdr, $path, $outdir) >>

Move a recording described by C<$hdr> and the given
source C<$path> (from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>)
to C<$outdir> by renaming the recording directory.
Returns C<RC_OK> if successful.

On Unix(-like) systems, C<renameRecording> will  fail if the source
and destinations for the move are on different file systems.
It will also fail if C<< $r->join >> is true and it will fail if
the source recording is on the Beyonwiz.
In all these cases, it will return C<RC_NOT_IMPLEMENTED>,
and not print a warning.

For other errors it will print a warning with the system error message,
and return one of
C<RC_FORBIDDEN>,
C<RC_NOT_FOUND>
or C<RC_INTERNAL_SERVER_ERROR>.

=item C<< $r->deleteRecordingFile($path, $name, $file) >>

Delete a recording file.
C<$path> is the path name from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.
C<$name> is the name of the recording,
and C<$file> is the name of the file within the recording to delete.

Returns C<RC_OK> if successful.
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
use HTTP::Status;
use POSIX;

our @ISA = qw( Beyonwiz::Recording::Accessor );

my $accessorsDone;

sub new() {
    my ($class, $base) = @_;
    $class = ref($class) if(ref($class));

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
	my $prefix = 'recording';
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

sub getRecordingFileChunk($$$$$$$) {
    my ($self, $rec, $path, $name, $file, $outdir,
        $append, $off, $size, $outOff, $progressBar) = @_;

    my $data_url = $self->base->clone;

    $data_url->path(_uriPathEscape($name ne '' ? $path . '/' . $file : $path));
    $name .= '/' . $file if($name ne '' && !$rec->join);
    $name = addDir($outdir, $name);

    if(!open TO, ($append ? '+<' : '>'), $name) {
	warn "Can't create $name: $!\n";
	return RC_FORBIDDEN;
    }
    binmode TO;

    if(!sysseek TO, $outOff, SEEK_SET) {
	warn "Seek error on $name: $!\n";
	close TO;
	return RC_BAD_REQUEST;
    }

    my $request = HTTP::Request->new(GET => $data_url);
    $request->header(range => "bytes=$off-" . ($off+$size-1));

    my $progressCount = 0;
    my $response = $ua->request($request,
			sub($$$) {
			    syswrite TO, $_[0] # $content, don't copy...
				or die "Can't write to $name: $!\n";
			    if($progressBar) {
			        $progressCount += length $_[0];
				if($progressCount > 256 * 1024) {
				    $progressBar->done(
					    $progressBar->done
					    + $progressCount
					);
				    $progressCount = 0;
				}
			    }
			}
		    );

    my $status = $response->code;

    close TO;
 
    $progressBar->done($progressBar->done + $progressCount) if($progressBar);

    warn $name, ($rec->join && defined($file) && $file ne ''
    		    ? '/'.$file
		    : ''
		), ': ',
	    status_message($status), "\n"
	if(!is_success($status));
    return $status;
}

sub getRecordingFile($$$$$$) {
    my ($self, $rec, $path, $name, $file, $outdir, $append) = @_;

    my $data_url = $self->base->clone;

    $data_url->path(_uriPathEscape($self->joinPaths($path, $file)));
    $name .= '/' . $file if(!$rec->join);
    $name = addDir($outdir, $name);
    $name = '>' . $name if($append);
    my $status = getstore($data_url, $name);
    warn $name, ($rec->join && defined($file) && $file ne ''
    		    ? '/'.$file
		    : ''
		), ': ',
	    status_message($status), "\n"
	if(!is_success($status));
    return $status;
}

sub deleteRecordingFile($$$$;$) {
    my ($self, $rec, $path, $name, $file) = @_;

    my $data_url = $self->base->clone;

    if(defined $file) {
	$data_url->path(_uriPathEscape($self->joinPaths($path, $file)));
    } else {
	$data_url->path(_uriPathEscape $path);
    }

    my $request = HTTP::Request->new(DELETE => $data_url);
    my $response = $ua->request($request);
    my $status = $response->code;

    warn $name, ($rec->join && defined($file) && $file ne ''
    		    ? '/'.$file
		    : ''
		), ': ',
	    status_message($status), "\n"
	if(!is_success($status));

    return $status;
}

1;
