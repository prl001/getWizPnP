package Beyonwiz::Recording::FileRecording;

=head1 NAME

    use Beyonwiz::Recording::FileRecording;

=head1 SYNOPSIS

Download recordings from the Beyonwiz.

=head1 SUPERCLASS

Inherits from
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Recording>

=head1 METHODS

=over 4

=item C<< Beyonwiz::Recording::FileRecording->new($path, $ts, $date, $episode, $resume, $force) >>

Create a new Beyonwiz recording downloader object.
C<$path> is the base path for local Beyonwiz recordings.
If C<$ts> is true, the download will be into
a single C<.ts> file, otherwise the recording will
be copied as it is on the Beyonwiz.
If C<$date> is true, the recording date is added to
the recording name.
If C<$episode> is true, the recording episode name is added to
the recording name if the episode name contains any non-blank characters.
Useful for downloading series recordings.
If C<$resume> is true, allow resumption of recording download
that appear to be incomplete.
If C<$force> is true, allow a download to overwrite an existing download.

=item C<< $r->path([$val]); >>

Returns (sets) recording path name.

=item C<< $r->getRecordingFileChunk($path, $name, $file, $outdir,
        $append, $off, $size, $outOff, $progressBar); >>

Download a chunk of a recording corresponding to a single
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>.

C<$path> is the URL path to the folder containing the recording's
files on the Beyonwiz.
C<$name> is the name of the recording folder or file
(if C<< $r->ts >> is true).
C<$file> is the name of the Beyonwiz file containing the chunk.
C<$append> is false if C<$file> is to be created, true if
it is to be appended to.
C<$off> and C<$size> is the chunk to be transferred.
If C<$outdir> is defined and not the empty string, the record file is
placed in that directory, rather than the current directory.
C<$outoff> is the offset to where to write the chunk into the output file.
C<$progressBar> is as defined below in C<< $r->getRecordng(...) >>.

Returns C<RC_OK> if successful.
Otherwise it will print a warning with the system error message,
and return one of
C<RC_FORBIDDEN>,
C<RC_NOT_FOUND>
or C<RC_BAD_REQUEST>.

=item C<< $r->getRecordingFile($path, $name, $outdir, $file, $append); >>

Download a complete 0000, 0001, etc. recording file or header file from the
Beyonwiz. Note that more than one
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
may refer to any given file.

C<$path>, C<$name>, C<$outdir>, C<$file> and C<$append> are as
in I<getRecordingFileChunk>.

Returns C<RC_OK> if successful.
Otherwise it will print a warning with the system error message,
and return one of
C<RC_FORBIDDEN>,
C<RC_NOT_FOUND>
or C<RC_BAD_REQUEST>.

=item C<< $r->renameRecording($hdr, $path, $outdir) >>

Move a recording described by C<$hdr> and the given
source C<$path> (from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>)
to C<$outdir> by renaming the recording directory.
Returns C<RC_OK> if successful.

On Unix(-like) systems, C<renameRecording> will  fail if the source
and destinations for the move are on different file systems.
It will also fail if C<< $r->ts >> is true and it will fail if
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
Otherwise it will print a warning with the system error message,
and return one of
C<RC_FORBIDDEN>,
C<RC_NOT_FOUND>
or C<RC_INTERNAL_SERVER_ERROR>.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::Recording>|Beyonwiz::Recording::Recording>,
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>,
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
C<HTTP::Status>,
C<File::Basename>,
C<File::Spec::Functions>,
C<Errno>,
C<POSIX>.

=head1 BUGS

The progress callback may have inaccuracies when transferring a
recording as-is from the Beyonwiz if the recording has been edited
or made from the timeshift buffer.

Uses C<bignum> for 64-bit integers, even when the underlying
Perl integers are 64 bits.

=cut

use warnings;
use strict;
use bignum;

use Beyonwiz::Recording::Recording qw(STAT addDir);
use Beyonwiz::Recording::Trunc qw(TRUNC);
use Beyonwiz::Recording::Header qw(TVHDR RADHDR);
use HTTP::Status;
use File::Basename;
use File::Spec::Functions qw(!path);
use POSIX qw(!:errno_h);
use Errno qw(:POSIX);

use constant BADCHARS => $^O eq 'MSWin32' || $^O eq 'cygwin'
				? '\\/:*?"<>|'	# Windows or Windows inside
				: '\/';		# For Unix & HFS+ filesystems

our @ISA = qw( Beyonwiz::Recording::Recording );

my $accessorsDone;

sub new($$$$$$$) {
    my ($class, $path, $ts, $date, $episode, $resume, $force) = @_;
    $class = ref($class) if(ref($class));

    my %fields = (
	path    => $path,
    );

    my $self = Beyonwiz::Recording::Recording->new(
				$ts, $date, $episode, $resume, $force
			    );

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

sub sameFile($$) {
}

sub getRecordingFileChunk($$$$$$$$) {
    my ($self, $path, $name, $file, $outdir,
        $append, $off, $size, $outOff, $progressBar) = @_;

    $path = catfile($path, $file);
    $name = catfile($name, $file) if(!$self->ts);
    $name = addDir($outdir, $name);

    if(!open FROM, '<', $path) {
	warn "Can't open $file: $!\n";
	return RC_NOT_FOUND;
    }
    binmode FROM;

    if(!open TO, ($append ? '+<' : '>'), $name) {
	warn "Can't create $name: $!\n";
	close FROM;
	return RC_FORBIDDEN;
    }
    binmode TO;

    if(!sysseek FROM, $off, SEEK_SET) {
	warn "Seek error on $file: $!\n";
	close FROM;
	close TO;
	return RC_BAD_REQUEST;
    }

    if(!sysseek TO, $outOff, SEEK_SET) {
	warn "Seek error on $name: $!\n";
	close FROM;
	close TO;
	return RC_BAD_REQUEST;
    }

    my $nread;
    my $buf;
    my $status = RC_OK;
    my $progressCount = 0;
    while($nread = sysread FROM, $buf, ($size > 4096 ? 4096 : $size)) {
	my $nwrote;
	if(!defined syswrite TO, $buf, $nread) {
	    warn "Write error on $name: $!\n";
	    $status = RC_BAD_REQUEST;
	    last;
	}
	$size -= $nread;
	if($progressBar) {
	    $progressCount += $nread;
	    if($progressCount > 256 * 1024) {
		$progressBar->done(
			$progressBar->done
			+ $progressCount
		    );
		$progressCount = 0;
	    }
	}
    }

    $progressBar->done($progressBar->done + $progressCount) if($progressBar);

    if(!defined $nread) {
	warn "Read error on $file: $!\n";
	$status = RC_BAD_REQUEST;
    }
    close TO;
    close FROM;
    return RC_OK;
}

sub getRecordingFile($$$$$$) {
    my ($self, $path, $name, $file, $outdir, $append) = @_;

    $path = catfile($path, $file);
    $name = catfile($name, $file) if(!$self->ts);
    $name = addDir($outdir, $name);

    if(!open FROM, '<', $path) {
	warn "Can't open $file: $!\n";
	return RC_NOT_FOUND;
    }
    if(!open TO, ($append ? '>>' : '>'), $name) {
	warn "Can't create $name: $!\n";
	close FROM;
	return RC_FORBIDDEN;
    }
    my $nread;
    my $buf;
    my $status = RC_OK;
    while($nread = sysread FROM, $buf, 4096) {
	if(!defined syswrite TO, $buf, $nread) {
	    warn "Write error on $name: $!\n";
	    $status = RC_BAD_REQUEST;
	    last;
	}
    }
    if(!defined $nread) {
	warn "Read error on $file: $!\n";
	$status = RC_BAD_REQUEST;
    }
    close TO;
    close FROM;
    return RC_OK;
}

sub renameRecording($$$$$$) {
    my ($self, $hdr, $path, $outdir) = @_;

    return RC_NOT_IMPLEMENTED if($self->ts);

    my $name = $self->getRecordingName($hdr, $path);

    $name .= $hdr->isRadio ? '.radwiz' : '.tvwiz';

    my $dirname = Beyonwiz::Recording::Recording::addDir($outdir, $name);

    my $errno = 0;
    my $errstr = '';
    if(!rename $path, $dirname) {
	$errno = int($!) + 0;
	$errstr = $!.'';
    }

    my $status = RC_OK;

    if($errno == EACCES || $errno == EPERM || $errno == ENOTEMPTY) {
	$status = RC_UNAUTHORIZED;
    } elsif($errno == EROFS || $errno == EBUSY || $errno == ENAMETOOLONG
         || $errno == ELOOP || $errno == EFAULT || $errno == EDQUOT
	 || $errno == EISDIR || $errno == ELOOP || $errno == ENOSPC) {
	$status = RC_FORBIDDEN;
    } elsif($errno == ENOENT || $errno ==  ENOTDIR) {
	$status = RC_NOT_FOUND;
    } elsif($errno == EIO) {
	$status = RC_INTERNAL_SERVER_ERROR;
    } elsif($errno == EXDEV) {
	$status = RC_NOT_IMPLEMENTED;
    } elsif($errno != 0) {
	$status = RC_INTERNAL_SERVER_ERROR;
    }

    warn 'Recording file/directory ', $name, ' at ',  $path, ': ',
	    $errstr, "\n"
	if(!is_success($status) && $status != RC_NOT_IMPLEMENTED);

    return $status;
}

sub deleteRecordingFile($$$$) {
    my ($self, $path, $name, $file) = @_;

    $path = catfile($path, $file)
        if(defined $file);

    my $errno = 0;
    my $errstr = '';
    if(-d $path) {
	if(!rmdir $path) {
	    $errno = int($!) + 0;
	    $errstr = $!.'';
	}
    } else {
	if(!unlink $path) {
	    $errno = int($!) + 0;
	    $errstr = $!.'';
	}
    }

    my $status = RC_OK;

    if($errno == EACCES || $errno == EPERM || $errno == ENOTEMPTY) {
	$status = RC_UNAUTHORIZED;
    } elsif($errno == EROFS || $errno == EBUSY || $errno == ENAMETOOLONG
         || $errno == ELOOP || $errno == EFAULT ) {
	$status = RC_FORBIDDEN;
    } elsif($errno == ENOENT || $errno ==  ENOTDIR) {
	$status = RC_NOT_FOUND;
    } elsif($errno == EIO) {
	$status = RC_INTERNAL_SERVER_ERROR;
    } elsif($errno != 0) {
	$status = RC_INTERNAL_SERVER_ERROR;
    }

    warn 'Recording file/directory ', $name, ' at ',  $path, ': ',
	    $errstr, "\n"
	if(!is_success($status));
    return $status;
}

1;
