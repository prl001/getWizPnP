package Beyonwiz::Recording::Accessor;

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

Abstract.

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

Abstract.

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

This implementation always does
nothing and returns RC_NOT_IMPLEMENTED.

Must be implemented in a derived class for it to have any effect.

=item C<< $r->deleteRecordingFile($path, $name, $file) >>

Delete a recording file.
C<$path> is the path name from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.
C<$name> is the name of the recording,
and C<$file> is the name of the file within the recording to delete.

Returns C<RC_OK> if successful.
Otherwise it will print a warning with the HTTP status
message of the HTTP operation that failed, and return that status.

Abstract.

=back

=head1 PREREQUISITES

Uses packages:
C<HTTP::Status>,
C<Beyonwiz::Utils>.

=cut

use HTTP::Status;
use Beyonwiz::Utils;

my $accessorsDone;

sub new() {
    my ($class, $base) = @_;
    $class = ref($class) if(ref($class));

    my $self = {
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

sub getRecordingFileChunk($$$$$$$) {
    my ($self, $path, $name, $file, $outdir,
        $append, $off, $size, $outOff, $progressBar) = @_;

    Beyonwiz::Utils::isAbstract;

    return undef;
}

sub getRecordingFile($$$$$$) {
    my ($self, $path, $name, $file, $outdir, $append) = @_;

    Beyonwiz::Utils::isAbstract;

    return undef;
}

sub renameRecording($$$$$) {
    my ($self, $rec, $hdr, $path, $outdir) = @_;

    return RC_NOT_IMPLEMENTED;
}

sub deleteRecordingFile($$$$) {
    my ($self, $path, $name, $file) = @_;

    Beyonwiz::Utils::isAbstract;

    return undef;
}

1;
