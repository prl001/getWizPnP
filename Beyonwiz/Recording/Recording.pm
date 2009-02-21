package Beyonwiz::Recording::Recording;

=head1 NAME

    use Beyonwiz::Recording::Recording;

=head1 SYNOPSIS

Download recordings from the Beyonwiz.

=head1 METHODS

=over 4

=item C<< Beyonwiz::Recording::Recording->new($ts, $date, $episode, $resume, $force) >>

Create a new Beyonwiz recording downloader object.
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

=item C<< $r->ts([$val]); >>

Returns (sets) the single-file TS flag.

=item C<< $r->date([$val]); >>

Returns (sets) the flag controlling whether the recording date
is added to the recording name.

=item C<< $r->resume([$val]); >>

Returns (sets) the flag controlling whether a recording resume is permitted.

=item C<< $r->force([$val]); >>

Returns (sets) the flag controlling whether a recording forced overwrite
is permitted.

=item C<addDir($dir, $name);>

If C<$dir> is defined and not empty, return C<$dir> prepended to C<$name>,
otherwise return C<$name>.

=item C<< $r->getRecordingName($hdr, $path, $ts); >>

C<$hdr> is the recording's header.
C<$path> is the path name from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.
C<$ts> is a flag to indicate whether a recording folde
or single recording TS file is to be created.

=item C<< $r->getRecordingFileChunk($path, $name, $file, $outdir,
        $append, $off, $size, $outOff, $progressBar); >>

Download a chunk of a recording corresponding to a single
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>.

C<$path> is the path name from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.
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

Unimplemented in C<Beyonwiz::Recording::Recording>, over-ride in
derived classes.

=item C<< $r->getRecordingFile($path, $name, $outdir, $file, $append); >>

Download a complete 0000, 0001, etc. recording file or header file from the
Beyonwiz. Note that more than one
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
may refer to any given file.

C<$path>, C<$name>, C<$outdir>, C<$file> and C<$append> are as
in I<getRecordingFileChunk>.

Unimplemented in C<Beyonwiz::Recording::Recording>, over-ride in
derived classes.

=item C<< $r->getRecording($hdr, $trunc, $path, $outdir, $showProgress); >>

Download a Beyonwiz recording, either as a direct copy from the Beyonwiz, or
into a single C<.ts> file (if C<< $r->ts >> is true).
C<$hdr> is the recording's header file object,
C<$trunc> is the recording's trunc file object,
and C<$path> is the path name from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.
If C<$outdir> is defined and not the empty string, the recording is
placed in that directory, rather than the current directory.
The name of the downloaded recording is derived from the recording title
in the C<$hdr>, with the episode name appended if C<< $r->episode >>
is true, and there are any non-whitespace characters in the episode name
and with the recording date appended if C<< $r->date >> is true.
If C<$showProgress> is not C<undef> it must be an object in a class
implementing the methods C<< $showProgress->total([$val]) >> and
C<< $showProgress->done([$val]) >>. C<total> registers the total
number of bytes to transfer, and C<done> updates the number of
bytes transferred in the progress bar.


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
or C<RC_INTERNAL_SERVER_ERROR>;

Returns C<RC_NOT_IMPLEMENTED>, must be overridden in any
derived class that can provide this function.

=item C<< $r->deleteRecording($hdr, $trunc, $path) >>

Delete a recording.
C<$hdr> is the recording's header file object,
C<$trunc> is the recording's trunc file object,
and C<$path> is the path name from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>,
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
C<HTTP::Status>,
C<File::Spec::Functions>,
C<File::Basename>.

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

use Beyonwiz::Recording::Trunc qw(TRUNC);
use Beyonwiz::Recording::Header qw(TVHDR RADHDR);
use Beyonwiz::Utils;
use HTTP::Status;
use File::Spec::Functions;
use File::Basename;

use constant STAT => 'stat';
use constant STATSIZE => 96;

use constant BADCHARS => '\\/:*?"<>|';

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(STAT addDir);

my $accessorsDone;

sub new($$$$$$) {
    my ($class, $ts, $date, $episode, $resume, $force) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	ts	=> $ts,
	date	=> $date,
	episode => $episode,
	resume	=> $resume,
	force	=> $force,
    };
    bless $self, $class;

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return $self;
}

sub getRecordingFileChunk($$$$$$$) {
    my ($self, $path, $name, $file, $outdir,
        $append, $off, $size, $outOff, $progressBar) = @_;

    die __PACKAGE__
	. "::getRecordingFileChunk should not be called directly\n"
}

sub getRecordingFile($$$$$$) {
    my ($self, $path, $name, $file, $outdir, $append) = @_;

    die __PACKAGE__
	. "::getRecordingFile should not be called directly\n"
}

sub _deleteRecordingFiles($) {
    my ($dir) = @_;
    opendir DIR, $dir or die "Can't find ", $dir, ": $!\n";
    foreach my $ent (readdir(DIR)) {
	if($ent eq TVHDR || $ent eq RADHDR || $ent eq TRUNC || $ent eq STAT
	|| $ent =~ /\d\d\d\d/) {
	    unlink catfile $dir, $ent
		or warn "Can't delete $ent in $dir: $!\n";
	}
    }
    closedir DIR;
}

sub addDir($$) {
    my ($dir, $name) = @_;
    return $dir ? catfile($dir, $name) : $name;
}

sub getRecordingName($$$$) {
    my ($self, $hdr, $path, $ts) = @_;
    my $name = basename($path);
    if(defined($hdr->title) && length($hdr->title) > 0) {
	$name = $hdr->longTitle($self->episode, ' - ');
	if($self->date) {
	    my $d = gmtime($hdr->starttime);
	    substr $d, 11, 9, '';
	    $name .= ' - ' . $d;
	}
    }
    # Strip the leading '*' from the name if there is one, and it's not
    # the only character
    $name =~ s/^\*(.)/$1/;
    # Some ugliness to interpolate BADCHARS into the character class
    $name =~ s/[${\(BADCHARS)}]/_/g;
    if($ts) {
	$name =~ s/.(tv|rad)wiz$//;
	$name .= '.ts';
    } else {
	$name .= $hdr->isRadio ? '.radwiz' : '.tvwiz';
    }
    return $name;
}

sub getRecording($$$$$$) {
    my ($self, $hdr, $trunc, $path, $outdir, $progressBar) = @_;
    my $status;

    my $name = $self->getRecordingName($hdr, $path, $self->ts);

    my $size = $trunc->recordingSize;

    my $done = 0;
    my $startTrunc = 0;
    my $startOff = 0;

    if($self->ts) {
	my $fullname = addDir($outdir, $name);
	if(-f $fullname) {
	    my $recSize = (stat $fullname)[7];
	    if(!defined $recSize) {
		warn "Can't get file size of $name: $!\n";
		return RC_FORBIDDEN;
	    }
	    if($recSize < $size) {
		if($self->resume) {
		    $startTrunc = $trunc->completeTruncs($recSize);
		    $startOff = $trunc->recordingSize($startTrunc);
		    $size -= $startOff;
		} else {
		    warn "Recording $name already exists, but is incomplete\n";
		    warn "Use --resume to resume fetching it\n";
		    return RC_FORBIDDEN;
		}
	    } else {
		if(!$self->force) {
		    warn "Recording $name already exists\n";
		    warn "Use --force to overwrite it\n";
		    return RC_FORBIDDEN;
		}
	    }
	}

	if($progressBar) {
	    $progressBar->total($size);
	    $progressBar->done($done);
	}

    } else {
	$trunc = $trunc->makeFileTrunc;
	$size = $trunc->recordingSize;
	my $dirname = addDir($outdir, $name);
	if(-d $dirname) {
	    if(   -f catfile($dirname, TVHDR)
		|| -f catfile($dirname, RADHDR)
	    && -f catfile($dirname, TRUNC)) {
		my $fileTrunc =
			Beyonwiz::Recording::FileTrunc->new($name, $dirname);
		$fileTrunc->load;
		if($fileTrunc->valid) {
		    $fileTrunc = $fileTrunc->fileTruncFromDir;
		    my $recSize = $fileTrunc->recordingSize;
		    if($recSize < $size) {
			if($self->resume) {
			    $startTrunc = $fileTrunc->completeTruncs($recSize);
			    $size -= $trunc->recordingSize($startTrunc);
			} else {
			    warn "Recording $name already exists,",
				" but is incomplete\n";
			    warn "Use --resume to resume fetching it\n";
			    return RC_FORBIDDEN;
			}
		    } else {
			if($self->force) {
			    _deleteRecordingFiles($dirname);
			} else {
			    warn "Recording $name already exists\n";
			    warn "Use --force to overwrite it\n";
			    return RC_FORBIDDEN;
			}
		    }
		} else {
		    warn "Can't load trunc file for $name\n";
		    return RC_PRECONDITION_FAILED;
		}
	    }
	} else {
	    if(!mkdir($dirname)) {
		warn "Can't create $dirname: $!\n";
		return RC_FORBIDDEN;
	    }
	}
	$size += $hdr->size + $trunc->size + STATSIZE;

	if($progressBar) {
	    $progressBar->total($size);
	    $progressBar->done($done);
	}

	$status = $self->getRecordingFile($path, $name,
					$hdr->headerName, $outdir, 0);
	return $status if(!is_success($status));
	$done += $hdr->size;
	$progressBar->done($done) if($progressBar);

	$status = $self->getRecordingFile($path, $name, STAT, $outdir, 0);
	if(is_success($status)) {
	    $done += STATSIZE;
	    $progressBar->done($done) if($progressBar);
	} else {
	    warn "Stat file not found for $name: ",
		    status_message($status),
		    " - recording may not be playable\n"
	}

	$status = $self->getRecordingFile($path, $name,
					TRUNC,
					$outdir, 0);
	return $status if(!is_success($status));
	$done += $trunc->size;
	$progressBar->done($done) if($progressBar);

    }

    my $append = $self->ts && $startOff > 0 ? 1 : 0;

    foreach my $tr (@{$trunc->entries}[$startTrunc..$trunc->nentries-1]) {
	my $fn = sprintf "%04d", $tr->fileNum;

	$status = $self->getRecordingFileChunk(
				$path, $name, $fn, $outdir, $append,
				$tr->offset, $tr->size,
				$startOff, $progressBar
			    );
	last if(!is_success($status));

	if($self->ts) {
	    $append = 1;
	    $startOff += $tr->size;
	}

	$done += $tr->size;

	$progressBar->done($done) if($progressBar);

    }
    return $status;
}

sub renameRecording($$$$$$) {
    my ($self, $hdr, $path, $outdir) = @_;

    return RC_NOT_IMPLEMENTED;
}

sub deleteRecording($$$$$$) {
    my ($self, $hdr, $trunc, $path) = @_;
    my $status;

    my $name = $self->getRecordingName($hdr, $path, 0);

    $status = $self->deleteRecordingFile($path, $name, $hdr->headerName);
    return $status if(!is_success($status));

    $status = $self->deleteRecordingFile($path, $name, TRUNC);
    return $status if(!is_success($status));

    $status = $self->deleteRecordingFile($path, $name, STAT);
    return $status if(!is_success($status));

    foreach my $tr (@{$trunc->entries}[0..$trunc->nentries-1]) {
	my $fn = sprintf "%04d", $tr->fileNum;

        $status = $self->deleteRecordingFile($path, $name, $fn);
    }

    $status = $self->deleteRecordingFile($path, $name, undef);
    return $status if(!is_success($status));

    return $status;
}

1;
