package Beyonwiz::Recording::Accessor;

my $Copyright = 'Copyright 2008-2018 Peter Lamb.
See accompanying LICENSE file for redistribution conditions.';

use warnings;
use strict;
use bignum;

=head1 NAME

    use Beyonwiz::Recording::Accessor;

=head1 SYNOPSIS

Provides (mostly) abstract access to media files independent
of the access method (local files or HTTP).

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Accessor->new($base) >>

Create a new accessor object with the base path
C<$base>.

=item C<< $a->base([$val]); >>

Returns (sets) the base path.

=item C<< $a->outFileHandle([$val]); >>

Returns (sets) the accessor's output file handle. Normally set by 
C<< $a->openRecordingFileOut($self, $rec, $name, $file, $outdir, $append, $progressBar) >>.

=item C<< $a->outFileName([$val]); >>

Returns (sets) the accessor's output file name. Normally set by 
C<< $a->openRecordingFileOut($self, $rec, $name, $file, $outdir, $append, $progressBar) >>.
The name is set even if I<openRecordingFileOut> fails.
Set to C<undef> by I<closeRecordingFileOut>

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

Abstract.

=item C<< $a->readFile(@path) >>

Read and return the contents of the file specified by C<@path>
where the components of C<@path> are joined to form a single path name.

Returns C<undef> on failure.

Abstract.

=item C<< $a->loadIndex; >>

Read and return the contents of the WizPnP index file
located at C<< $h->base([$val]); >>.

Returns C<undef> on failure.

Abstract.

=item C<< $a->openRecordingFileOut($self, $rec, $name, $file, $outdir, $append, $progressBar) >>

Open a recording file for output in the local file system.

C<$rec> is the asociated
L<C<Beyonwiz::Recording::Recording>|Beyonwiz::Recording::Recording>.
C<$name> is the name of the recording folder
(or file if C<< $rec->join >> is true).
C<$file> is the name of the Beyonwiz file containing the data to be written.
C<$append> is false if C<$file> is to be created, true if
it is to be appended to.
If C<$outdir> is defined and not the empty string, the record file is
placed in that directory, rather than the current directory.
Uses C<$progressBar> to properly terminate the progress-bar line
on errors.
If C<$quiet> is true, then don't print an error message if the source file
can't be found.

Returns C<HTTP_OK> if successful, otherwise some other C<HTTP_FORBIDDEN>
if the file could not be created or opened for appending
(depending on the value of C<$append>) and
prints an operating system message describing the error.

=item C<< $a->closeRecordingFileOut >>

Close C<< $a->outFileHandle >>.
Set C<< $a->outFileHandle >>
and C<< $a->outFileName >>
to C<undef>.

Always returns C<HTTP_OK>.

=item C<< $a->getRecordingFileChunk($rec, $path, $name, $file, $outdir,
        $append, $off, $size, $outOff, $progressBar, $quiet); >>

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
C<< $progressBar->done($totalTransferred) >> is
called at regular intervals to update the progress bar
and C<< $progressBar->newLine >> is used to move to a new line
if the progress bar is being drawn on the terminal.
If C<$quiet> is true, then don't print an error message if the source file
can't be found.

Returns C<HTTP_OK> if successful.
Otherwise it will print a warning with the HTTP status
message of the HTTP operation that failed, and return that status.

Abstract.

=item C<< $a->getRecordingFile($path, $name, $inFile, $outdir, $outFile, $progressBar, $quiet); >>

Fetch a complete 0000, 0001, etc. recording file or header file from the
Beyonwiz. Note that more than one
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
may refer to any given file.

C<$path>, C<$name>, C<$outdir> and C<$quiet>
are as in I<getRecordingFileChunk>.

C<< $progressBar->newLine >> is used to move to a new line if the progress
bar is being drawn on the terminal.

Returns C<HTTP_OK> if successful.
Otherwise it will return the HTTP error status (or a HTTP status
corresponding to the underlying error for non-HTTP accessors).

Abstract.

=item C<< $a->renameRecording($hdr, $path, $outdir) >>

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

This implementation always does
nothing and returns HTTP_NOT_IMPLEMENTED.

Must be implemented in a derived class for it to have any effect.

=item C<< $r->deleteRecordingFile($path, $name, $file) >>

Delete a recording file.
C<$path> is the path name from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.
C<$name> is the name of the recording,
and C<$file> is the name of the file within the recording to delete.

Returns C<HTTP_OK> if successful.
Otherwise it will print a warning with the HTTP status
message of the HTTP operation that failed, and return that status.

Abstract.

=back

=head1 PREREQUISITES

Uses packages:
C<HTTP::Status>,
C<File::Spec::Functions>,
C<Beyonwiz::Utils>
C<Beyonwiz::Recording::Recording>.

=cut

use HTTP::Status qw(:constants);
use File::Spec::Functions;
use Beyonwiz::Utils;
use Beyonwiz::Recording::Recording qw(addDir);

my $accessorsDone;

sub new() {
    my ($class, $base) = @_;
    $class = ref($class) if(ref($class));

    my $self = {
	outFileHandle => undef,
	outFileName => undef,
    };

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return bless $self, $class;

}

sub fileLenTime($@) {
    my ($self, @path) = @_;

    Beyonwiz::Utils::isAbstract;

    return undef;
}

sub readFileChunk($$$@) {
    my ($self, $offset, $size, @path) = @_;

    Beyonwiz::Utils::isAbstract;

    return undef;
}

sub readFile($@) {
    my ($self, @path) = @_;

    Beyonwiz::Utils::isAbstract;

    return undef;
}

sub loadIndex($) {
    my ($self) = @_;

    Beyonwiz::Utils::isAbstract;

    return undef;
}

sub openRecordingFileOut($$$$$$$) {
    my ($self, $rec, $name, $file, $outdir, $append, $progressBar) = @_;

    $name = $file ne ''
		? catfile($name, $file)
		: $name if(!$rec->join);
    $name = addDir($outdir, $name);

    $self->outFileName($name);

    my $fh;

    if(!open $fh, ($append ? '+<' : '>'), $name) {
	warn( $progressBar->newLine,
	     "Can't create $name: $!\n");
	return HTTP_FORBIDDEN;
    }

    binmode $fh;
    $self->outFileHandle($fh);

    return HTTP_OK;
}

sub closeRecordingFileOut($) {
    my ($self) = @_;

    close $self->outFileHandle
	if($self->outFileHandle && $self->outFileHandle != \*STDOUT);
    $self->outFileHandle(undef);
    $self->outFileName(undef);

    return HTTP_OK;
}

sub getRecordingFileChunk($$$$$$$$$$$) {
    my ($self, $rec, $path, $name, $file, $outdir,
        $off, $size, $outOff, $progressBar, $quiet) = @_;

    Beyonwiz::Utils::isAbstract;

    return undef;
}

sub getRecordingFile($$$$$$$$) {
    my ($self, $path, $name, $inFile, $outdir, $outFile,
        $progressBar, $quiet) = @_;

    Beyonwiz::Utils::isAbstract;

    return undef;
}

sub renameRecording($$$$$) {
    my ($self, $rec, $hdr, $path, $outdir) = @_;

    return HTTP_NOT_IMPLEMENTED;
}

sub deleteRecordingFile($$$$) {
    my ($self, $path, $name, $file) = @_;

    Beyonwiz::Utils::isAbstract;

    return undef;
}

1;
