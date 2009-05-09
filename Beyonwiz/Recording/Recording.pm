package Beyonwiz::Recording::Recording;

=head1 NAME

    use Beyonwiz::Recording::Recording;

=head1 SYNOPSIS

Download recordings from the Beyonwiz.

=head1 METHODS

=over 4

=item C<< Beyonwiz::Recording::Recording->new($join, $date, $episode, $resume, $force) >>

Create a new Beyonwiz recording downloader object.
If C<$join> is true, the download will be into
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

=item C<< $r->join([$val]); >>

Returns (sets) the flag indicating whether the recording
should be joined into a single file.

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

=item C<< $r->getRecordingName($hdr, $indexName, $join); >>

C<$hdr> is the recording's header.
C<$indexName> is the index name from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.
C<$join> is a flag to indicate whether a recording folder
or single recording or media file is to be created from
Beyonwiz folder media formats.

=item C<< $r->getRecordingFileChunk($path, $name, $file, $outdir,
        $append, $off, $size, $outOff, $progressBar); >>

Download a chunk of a recording corresponding to a single
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>.

C<$path> is the path name from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.
C<$name> is the name of the recording folder or file
(if C<< $r->join >> is true).
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
combine tham into a single file (if C<< $r->join >> is true
for Beyonwiz folder media formats).
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
It will also fail if C<< $r->join >> is true and it will fail if
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
C<File::Basename>,
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

use Beyonwiz::Recording::Trunc qw(TRUNC WMMETA FULLFILE);
use Beyonwiz::Recording::Header qw(TVHDR RADHDR);
use Beyonwiz::Utils;
use HTTP::Status;
use File::Spec::Functions;
use File::Basename;
use POSIX;

use constant STAT => 'stat';
use constant STATSIZE => 96;

use constant BADCHARS => '\\/:*?"<>|';

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(STAT addDir);

my $accessorsDone;

sub new($$$$$$) {
    my ($class, $accessor, $join, $nameFormat, $dateFormat,
    						$resume, $force) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	accessor	=> $accessor,
	join		=> $join,
	nameFormat	=> $nameFormat,
	dateFormat 	=> $dateFormat,
	resume		=> $resume,
	force		=> $force,
    };
    bless $self, $class;

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return $self;
}

sub _deleteRecordingFiles($) {
    my ($dir) = @_;
    opendir DIR, $dir or die "Can't find ", $dir, ": $!\n";
    foreach my $ent (readdir(DIR)) {
	if($ent eq TVHDR || $ent eq RADHDR
	|| $ent eq TRUNC || $ent eq WMMETA
	|| $ent eq STAT
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

sub doFormatStr($$$) {
    my ($self, $str, $sep) = @_;
    my $val ='';
    if(defined $str and $str ne '') {
	$val .= " $sep " if(defined $sep);
	$val .= $str;
    }
    return $val;
}

sub doFormatDate($$$) {
    my ($self, $date, $sep) = @_;
    my $val = '';
    if(defined $date) {
	$val .= " $sep " if(defined $sep);
	$val .= POSIX::strftime $self->dateFormat, gmtime $date;
    }
    return $val;
}

sub doFormat($$$) {
    my ($self, $hdr, $indexName, $code) = @_;
    my $sep;
    my $type;
    my $val;
    if(length($code) == 4) {
	$sep = substr $code, 2, 1;
	$type = substr $code, 3, 1;
    } elsif(length($code) == 3) {
	$type = substr $code, 2, 1;
    }
    if(defined $type) {
	if($type eq 'T') {
	    my $title = $hdr->title;
	    $title = basename($indexName)
		if(!defined $hdr->title or $hdr->title eq '');
	    $val = $self->doFormatStr($title, $sep);
	}
	$val = $self->doFormatStr($hdr->episode, $sep) if($type eq 'E');
	$val = $self->doFormatDate($hdr->starttime, $sep) if($type eq 'D');
	$val = $self->doFormatStr($hdr->service, $sep) if($type eq 'S');
    }
    $val = '%' . $code if(!defined $val);
    return $val;
}

sub getRecordingName($$$$) {
    my ($self, $hdr, $indexName, $join) = @_;
    $join = 1 if($hdr->isMediaFile);
    my $name = $hdr->isRadio || $hdr->isTV
    		    ? $self->nameFormat
		    : '%=T';
    $name =~ s{
		    (%=[^[:alnum:]%+]?[TEDS])
	      }{
		    $self->doFormat($hdr, $indexName, $1)
	      }gex;
    $name = POSIX::strftime $name, gmtime($hdr->starttime);
    # Strip the leading '*' from the name if there is one, and it's not
    # the only character
    $name =~ s/^\*(.)/$1/;
    # Some ugliness to interpolate BADCHARS into the character class
    $name =~ s/[${\(BADCHARS)}]/-/g;
    $name .= $hdr->isRadio
		    ? ($join ? '.ts' : '.radwiz')
	   : $hdr->isTV
		    ? ($join ? '.ts' : '.tvwiz')
	   : $hdr->isMediaFolder
		    ? ($join ? ''    : '.wiz')
		    : '';
    return $name;
}

sub getRecording($$$$$$$) {
    my ($self, $hdr, $trunc, $indexName, $path,
					$outdir, $progressBar) = @_;
    my $status;

    my $name = $self->getRecordingName($hdr, $path, $self->join);

    my $size = $trunc->recordingSize;

    my $done = 0;
    my ($startTrunc, $inStartOff) = (0, 0);
    my $outStartOff = 0;
    $self->join(1) if($hdr->isMediaFile);

    if($self->join) {
	my $fullname = addDir($outdir, $name);
	if(-f $fullname) {
	    my $recSize = (stat $fullname)[7];
	    if(!defined $recSize) {
		warn "Can't get file size of $name: $!\n";
		return RC_FORBIDDEN;
	    }
	    if($recSize < $size) {
		if($self->resume) {
		    ($startTrunc, $inStartOff) = $trunc->truncStart($recSize);
		    $outStartOff = $trunc->recordingSize($startTrunc)
					+ $inStartOff;
		    $size -= $outStartOff;
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
	    if(    (   -f catfile($dirname, TVHDR)
		    || -f catfile($dirname, RADHDR))
	        && -f catfile($dirname, TRUNC)
	    ||     -f catfile($dirname, WMMETA)) {
		my $fileAccessor =
			Beyonwiz::Recording::FileAccessor->new($outdir);
		my $fileTrunc =
			Beyonwiz::Recording::Trunc->new($fileAccessor, $name, $name);
		$fileTrunc->load;
		if($fileTrunc->valid) {
		    $fileTrunc = $fileTrunc->fileTruncFromDir;
		    my $recSize = $fileTrunc->recordingSize;
		    if($recSize < $size) {
			if($self->resume) {
			    ($startTrunc, $inStartOff) =
					$fileTrunc->truncStart($recSize);
			    $size -= $trunc->recordingSize($startTrunc);
			    $size -= $inStartOff;
			    $outStartOff = $inStartOff;
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

	if($hdr->isRadio || $hdr->isTV) {
	    $status = $self->accessor->getRecordingFile($self, $path, $name,
					    $hdr->headerName, $outdir, 0);
	    return $status if(!is_success($status));
	    $done += $hdr->size;
	    $progressBar->done($done) if($progressBar);

	    $status = $self->accessor->getRecordingFile($self, $path, $name,
					    STAT, $outdir, 0);
	    if(is_success($status)) {
		$done += STATSIZE;
		$progressBar->done($done) if($progressBar);
	    } else {
		warn "Stat file not found for $name: ",
			status_message($status),
			" - recording may not be playable\n"
	    }
	}
	$status = $self->accessor->getRecordingFile($self, $path, $name,
					$trunc->fileName,
					$outdir, 0);
	return $status if(!is_success($status));
	$done += $trunc->size;
	$progressBar->done($done) if($progressBar);

    }

    my $append = $outStartOff > 0;

    foreach my $i ($startTrunc..$trunc->nentries-1) {
	my $tr = $trunc->entries->[$i];
	my $fn = ($tr->flags & FULLFILE) ? '' : sprintf("%04d", $tr->fileNum);

	my $offset = $tr->offset;
	my $size   = $tr->size;
	if($i == $startTrunc) {
	    $offset = $inStartOff;
	    $size  -= $inStartOff;
	}
	$status = $self->accessor->getRecordingFileChunk(
				$self, $path, $name, $fn, $outdir, $append,
				$offset, $size,
				$outStartOff, $progressBar
			    );
	last if(!is_success($status));

	if($self->join) {
	    $append = 1;
	    $outStartOff += $size;
	} else {
	    $append = 0;
	    $outStartOff = 0;
	}

	$done += $size;

	$progressBar->done($done) if($progressBar);
    }
    return $status;
}

sub renameRecording($$$$) {
    my ($self, $hdr, $path, $outdir) = @_;
    return $self->accessor->renameRecording($self, $hdr, $path, $outdir);
}

sub deleteRecording($$$$$$) {
    my ($self, $hdr, $trunc, $indexName, $path) = @_;
    my $status;

    my $name = $self->getRecordingName($hdr, $indexName, 0);

    foreach my $tr (@{$trunc->entries}[0..$trunc->nentries-1]) {
	my $fn = sprintf "%04d", $tr->fileNum;

        $status = $self->accessor->deleteRecordingFile(
				$self, $path, $name, $fn
			    );
    }

    $status = $self->accessor->deleteRecordingFile($self, $path, $name, $hdr->headerName);
    return $status if(!is_success($status));

    $status = $self->accessor->deleteRecordingFile($self, $path, $name, TRUNC);
    return $status if(!is_success($status));

    $status = $self->accessor->deleteRecordingFile($self, $path, $name, STAT);
    return $status if(!is_success($status));

    $status = $self->accessor->deleteRecordingFile($self, $path, $name, undef);
    return $status if(!is_success($status));

    return $status;
}

1;
