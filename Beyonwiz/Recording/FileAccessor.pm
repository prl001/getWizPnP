package Beyonwiz::Recording::FileAccessor;

=head1 NAME

    use Beyonwiz::Recording::HTTPAccessor;

=head1 SYNOPSIS

Provides access to media files via HTTP.

=head1 SUPERCLASS

Inherits from
L<C<Beyonwiz::Recording::Accessor>|Beyonwiz::Recording::Accessor>

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Accessor->new($base, $extensions) >>

Create a new accessor object with the base URL
C<$base>
and list of extensions to be recognised as media files
from the array reference C<$extensions>.

=item C<< $a->base([$val]); >>

Returns (sets) the base path.

=item C<< $a->extensions([$val]); >>

Returns (sets) the list of recognised media extensions
Expects and returns an array reference.

=item C<< $a->fileLenTime(@path); >>

Return C<($size, $modifiedTime)> for the given C<@path>,
where the components of C<@path> are joined to form a single path name.

Returns the empty list, C<()>, if the path is not the name of a normal file.

C<$size> in bytes, C<$modifiedTime> is the time
the file was last modified as
Unix time (seconds since 00:00:00 Jan 1 1097 UTC).

=item C<< $a->readFileChunk($offset, $size, @path) >>

Read and return a chunk of the file length C<$size> at offset C<$offset>
from the file specified by C<@path>
where the components of C<@path> are joined to form a single path name..

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
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>,
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>,
L<C<Beyonwiz::Recording::Recording>|Beyonwiz::Recording::Recording>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
C<File::Spec::Functions>,
C<File::Find>,
C<File::Basename>,
C<HTTP::Status>,
C<POSIX>.

=cut

use warnings;
use strict;
use bignum;

use Beyonwiz::Recording::Accessor;
use Beyonwiz::Recording::Header qw(TVHDR RADHDR);
use Beyonwiz::Recording::Trunc qw(TRUNC WMMETA);
use Beyonwiz::Recording::Recording qw(addDir);
use Beyonwiz::Utils;
use File::Spec::Functions qw(!path splitdir);
use File::Find;
use File::Basename;
use HTTP::Status;
use POSIX;

our @ISA = qw( Beyonwiz::Recording::Accessor );

my $accessorsDone;

sub new() {
    my ($class, $base, $extensions, $stopFolders) = @_;
    $class = ref($class) if(ref($class));

    my %fields = (
	base        => $base,
	extensions  => { map { ($_, 1) } @$extensions },
	stopFolders => { map { ($_, 1) } @$stopFolders },
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

sub extensions($;$) {
    my ($self, $val) = @_;
    my $oldval = [ keys %{$self->{extensions}} ];
    if(@_ == 2) {
	%{$self->{extensions}} = { map { ($_, 1) } @$val },
    }
    return $oldval;
}

sub stopFolders($;$) {
    my ($self, $val) = @_;
    my $oldval = [ keys %{$self->{stopFolders}} ];
    if(@_ == 2) {
	%{$self->{stopFolders}} = { map { ($_, 1) } @$val },
    }
    return $oldval;
}

sub joinPaths($@) {
    my ($self, @path) = @_;
    return catfile @path;
}

sub fileLenTime($@) {
    my ($self, @path) = @_;
    my $fn = $self->joinPaths(@path);
    return () if(!-f $fn);
    my ($size, $mtime) = (stat _)[7,9];
    return ($size, $mtime);
}

sub readFileChunk($$$@) {
    my ($self, $offset, $size, @path) = @_;

    my $fn = $self->joinPaths(@path);

    if(open HDR, '<', $fn) {
	my $hdr_data = '';
	if(sysseek HDR, $offset, SEEK_SET) {
	    my $nread = sysread HDR, $hdr_data, $size;
	    if(defined($nread) && $nread == $size) {
		close HDR;
		return $hdr_data;
	    }
	}
	close HDR;
    }

    return undef;
}

sub readFile($@) {
    my ($self, @path) = @_;

    my $fn = $self->joinPaths(@path);

    if(open HDR, '<', $fn) {
	my $hdr_data = '';
	my $off = 0;
	my $rdLen = 4096;
	while(1) {
	    my $nread = sysread HDR, $hdr_data, $rdLen, $off;
	    if(!defined($nread) || $nread == 0) {
		close HDR;
		return defined($nread) ? $hdr_data : undef;
	    }
	    $off += $nread;
	}
	close HDR;
    }

    return undef;
}

my @monNames = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );

sub loadIndex($) {
    our ($self) = @_;

    our $indexData = [];

    our $base = canonpath($self->base);
    $base = '.' if($base eq '');

    if($^O eq 'MSWin32') {
	# File::Find on windows doesn't find any files if the path
	# is a bare drive letter, like X: Make it X:\

	$base .= '\\' if($base =~ /^[[:alpha:]]:$/);

	# File::Find uses '/' as a path separator, even on Windows!
	# Change all the '\' characters in the path to '/' on Windows
	# ('/' isn't a valid file name letter on Windows,
	# so this won't break anything) so that paths in File::Find
	# error messages have consistent path separtor characters,
	# even if they're the "wrong" ones for Windows.

	$base =~ s:\\:/:g;
    }

    our $baseLen = length($base);

    sub process() {
	# Prune search if the current folder's name is in the stop list
	if(-d $_ && $self->{stopFolders}{basename($_)}) {
	    $File::Find::prune = 1;
	    return;
	}

	my $cutBase = substr($File::Find::name, $baseLen, 1) eq '/'
			? $baseLen + 1
			: $baseLen;
	my $relpath = length($File::Find::name) > $cutBase
			? substr $File::Find::name, $cutBase
			: $File::Find::name;
	/\.([^.]+)$/;
	my $ext = lc $1;

	# Fake up parsed index.txt lines for identified recordings/media files

	if((   !defined($ext)
	    || (   ($ext eq 'tvwiz' || $ext eq 'radwiz')
	        && $self->{extensions}{$ext}
		)
	   )
	&& -d $_
	&& (-f $self->joinPaths($_, TVHDR) || -f $self->joinPaths($_, RADHDR))
	&&  -f $self->joinPaths($_, TRUNC)) {
	    my $name = $relpath;
	    $name =~ s/\.(tv|rad)wiz$//;
	    $name = join '/', splitdir($name);
	    my $mtime = (stat $_)[9];
	    my ($min,$hour,$mday,$mon,$year) = (localtime($mtime))[1..5];
	    $name .= sprintf ' %s.%d.%d_%d.%d',
				$monNames[$mon], $mday, $year+1900, $hour, $min;
	    push @$indexData,
		    [ $name,
		      $self->joinPaths(
				$base, $relpath
			    )
		    ];
	    $File::Find::prune = 1;
	} elsif(defined($ext) && $ext eq 'wiz' && $self->{extensions}{$ext}
	     && -d $_
	     && -f $self->joinPaths($_, WMMETA)) {
	    my $name = $relpath;
	    $name = join '/', splitdir($name);
	    push @$indexData,
		    [ substr($name, 0, -4),
			$self->joinPaths($base, $relpath) ];
	    $File::Find::prune = 1;
	} elsif(defined($ext) && $self->{extensions}{$ext}
	     && -f $_) {
	    my $name = $relpath;
	    $name = join '/', splitdir($name);
	    push @$indexData,
		[ $name, $self->joinPaths($base, $relpath) ];
	}
    }

    unless(-d $base) {
	warn "Can't find ", $base, ": $!\n";
	return undef;
    }

    find({ wanted => \&process, follow => 0 }, $base);

    return $indexData;
}

sub getRecordingFileChunk($$$$$$$$) {
    my ($self, $rec, $path, $name, $file, $outdir,
        $append, $off, $size, $outOff, $progressBar) = @_;
    $path = $file ne ''
		? $self->joinPaths($path, $file)
		: $path;
    $name = $file ne ''
		? $self->joinPaths($name, $file)
		: $name if(!$rec->join);
    $name = addDir($outdir, $name);

    if(!open FROM, '<', $path) {
	warn "Can't open $path: $!\n";
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
	warn "Seek error on $path: $!\n";
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
    my $rdLen = 64 * 1024;
    while($nread = sysread FROM, $buf, ($size > $rdLen ? $rdLen : $size)) {
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
	warn "Read error on $path: $!\n";
	$status = RC_BAD_REQUEST;
    }
    close TO;
    close FROM;
    return RC_OK;
}

sub getRecordingFile($$$$$$) {
    my ($self, $rec, $path, $name, $file, $outdir, $append) = @_;

    $path = $file ne ''
	? $self->joinPaths($path, $file)
	: $path;
    $name = $file ne ''
		? $self->joinPaths($name, $file)
		: $name if(!$rec->join);
    $name = addDir($outdir, $name);

    if(!open FROM, '<', $path) {
	warn "Can't open $path: $!\n";
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
    my $rdLen = 64 * 1024;
    while($nread = sysread FROM, $buf, $rdLen) {
	if(!defined syswrite TO, $buf, $nread) {
	    warn "Write error on $name: $!\n";
	    $status = RC_BAD_REQUEST;
	    last;
	}
    }
    if(!defined $nread) {
	warn "Read error on $path: $!\n";
	$status = RC_BAD_REQUEST;
    }
    close TO;
    close FROM;
    return RC_OK;
}

sub renameRecording($$$$$) {
    my ($self, $rec, $hdr, $path, $outdir) = @_;

    return RC_NOT_IMPLEMENTED if($rec->join);

    my $name = $rec->getRecordingName($hdr, $path);

    my $dirname = addDir($outdir, $name);

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
    my ($self, $rec, $path, $name, $file) = @_;

    $path = $self->joinPaths($path, $file)
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
