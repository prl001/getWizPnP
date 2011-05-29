package Beyonwiz::Recording::Recording;

=head1 NAME

    use Beyonwiz::Recording::Recording;

=head1 SYNOPSIS

Download recordings from the Beyonwiz.

=head1 METHODS

=over 4

=item C<< Beyonwiz::Recording::Recording->new($class, $accessor, $join, $nameFormat, $dateFormat, $resume, $force) >>

Create a new Beyonwiz recording downloader object.
C<$accessor> is a
L<C<Beyonwiz::Recording::Accessor>|Beyonwiz::Recording::Accessor>
object used to handle data operations on the source recording.
If C<$join> is true, the download will be into
a single C<.ts> file, otherwise the recording will
be copied as it is on the Beyonwiz.
C<$nameFormat> and C<$dateFormat> are the destination recording
name format and date format strings (for dates in the name format string).
If C<$resume> is true, allow resumption of recording download
that appear to be incomplete.
If C<$force> is true, allow a download to overwrite an existing download.

=item C<< $r->accessor([$val]); >>

Returns (sets) the media file accessor object reference.

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

=item C<< $r->putFile($name, $file, $outdir, $append, $data) >>

Write the data C<$data> to C<$file> in directory
C<$outdir>.
Append rather than overwrite if C<$append> is true.

=item C<< $r->getRecording($hdr, $trunc, $stat, $indexName, $path,
					$outdir, $progressBar) = @_; >>

Download a Beyonwiz recording, either as a direct copy from the Beyonwiz, or
combine tham into a single file (if C<< $r->join >> is true
for Beyonwiz folder media formats).
C<$hdr> is the recording's main header file object,
C<$trunc> is the recording's I<trunc> file object
and
C<$stat> is the recording object's Istat> file object.
I<$indexName> is the recording's name, 
and C<$path> its path name from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.
If C<$outdir> is defined and not the empty string, the recording is
placed in that directory, rather than the current directory.
The name of the downloaded recording is derived from the recording title
in the C<$hdr>, with the episode name appended if C<< $r->episode >>
is true, and there are any non-whitespace characters in the episode name
and with the recording date appended if C<< $r->date >> is true.
If C<$progressBar> is not C<undef> it must be an object in a class
implementing the methods C<< $progressBar->total([$val]) >> and
C<< $progressBar->done([$val]) >>. C<total> registers the total
number of bytes to transfer, and C<done> updates the number of
bytes transferred in the progress bar.

If C<< $obj->reconstructed >> is true,
for any of C<$hdr>, C<$trunc> or C<$stat>,
then the header files for the respective objects are written from the
objects instead of being copied from the source recording.

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

use Beyonwiz::Recording::Trunc qw(TRUNC WMMETA);
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

sub putFile($$$$$$) {
    my ($self, $name, $file, $outdir, $append, $data) = @_;
    $name = addDir($outdir, $name);
    $name = addDir($name, $file);

    if(!open TO, ($append ? '>>' : '>'), $name) {
	warn "Can't create $name: $!\n";
	return RC_FORBIDDEN;
    }
    if(!defined syswrite TO, $data, length $data) {
	warn "Write error on $name: $!\n";
	return RC_BAD_REQUEST;
    }
    close TO;
    return RC_OK;
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

sub getRecording($$$$$$$$) {
    my ($self, $hdr, $trunc, $stat, $indexName, $path,
					$outdir, $progressBar) = @_;
    my $status;

    my $name = $self->getRecordingName($hdr, $path, $self->join);

    my $done = 0;
    my ($startTrunc, $inStartOff, $resume) = (0, 0, 0);
    my $outStartOff = 0;
    $self->join(1) if($hdr->isMediaFile);

    my $size = $trunc->recordingSize;

    if($self->join) {
	my $fullname = addDir($outdir, $name);
	$size = $hdr->endOffset - $hdr->startOffset
	    if($hdr->endOffset - $hdr->startOffset < $size);
	if(-f $fullname) {
	    my $recSize = (stat $fullname)[7];
	    if(!defined $recSize) {
		warn "Can't get file size of $name: $!\n";
		return RC_FORBIDDEN;
	    }
	    if($recSize < $size) {
		if($self->resume) {
		    $resume = 1;
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

	my $dirname = addDir($outdir, $name);
	if(-d $dirname) {
	    if(    (   -f catfile($dirname, TVHDR)
		    || -f catfile($dirname, RADHDR))
	        && -f catfile($dirname, TRUNC)
	    ||     -f catfile($dirname, WMMETA)) {
		my $fileAccessor =
			Beyonwiz::Recording::FileAccessor->new($outdir);
		my $fileTrunc =
			Beyonwiz::Recording::Trunc->new($fileAccessor, $name, $dirname);
		$fileTrunc->load;
		if($fileTrunc->valid) {
		    $fileTrunc = $fileTrunc->fileTruncFromDir;
		    my $recSize = $fileTrunc->recordingSize;
		    if($recSize < $size) {
			if($self->resume) {
			    $resume = 1;
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
	$size = $hdr->size + $trunc->size + STATSIZE + $trunc->recordingSize;
	if($progressBar) {
	    $progressBar->total($size);
	    $progressBar->done($done);
	}

	if($hdr->isRadio || $hdr->isTV) {
	    if(!$hdr->reconstructed) {
		$status = $self->accessor->getRecordingFile($path, $name,
						$hdr->headerName, $outdir,
						$hdr->headerName,
						$progressBar, 0);
	    } else {
		$status = $self->putFile($name, $hdr->headerName,
				    $outdir, 0, $hdr->encodeHeader);
	    }
	    return $status if(!is_success($status));
	    $done += $hdr->size;
	    $progressBar->done($done) if($progressBar);

	    $status = $self->accessor->getRecordingFile($path, $name,
					    $stat->beyonwizFileName,
					    $outdir, $stat->fileName,
					    $progressBar,
					    $stat->reconstructed);
	    if($stat->reconstructed && (!is_success($status) || $self->force)) {
		$status = $self->putFile($name, $stat->fileName,
					$outdir, 0, $stat->encodeStat);
	    }
	    if(is_success($status)) {
		$done += STATSIZE;
		$progressBar->done($done) if($progressBar);
	    } else {
		warn "Stat file not found for $name: ",
			status_message($status),
			" - recording may not be playable\n"
	    }
	}
	$status = $self->accessor->getRecordingFile($path, $name,
					$trunc->beyonwizFileName,
					$outdir, $trunc->fileName,
					$progressBar,
					$trunc->reconstructed);
	if($trunc->reconstructed && (!is_success($status) || $self->force)) {
	    $status = $self->putFile($name, $trunc->fileName,
				$outdir, 0, $trunc->encodeTrunc);
	    return $status if(!is_success($status));
	    $status = $self->putFile($name, $hdr->headerName,
				$outdir, 0, $hdr->encodeHeader);
	}
	return $status if(!is_success($status));
	$done += $trunc->size;
	$progressBar->done($done) if($progressBar);

    }

    my $append = $outStartOff > 0;

    $self->accessor->closeRecordingFileOut;

    foreach my $i ($startTrunc..$trunc->nentries-1) {
	my $tr = $trunc->entries->[$i];
	my $fn = $tr->fileName;

	if(!$self->accessor->outFileHandle) {
	    $status = $self->accessor->openRecordingFileOut(
			    $self, $name, $fn, $outdir, $append, $progressBar
			);
	    return $status if(!is_success($status));
	}

	my $offset = $tr->offset;
	my $size   = $tr->size;
	if($i == $startTrunc && $resume) {
	    $offset = $inStartOff;
	    $size  -= $inStartOff;
	}
	my $trimSize = $self->join && $tr->wizOffset + $size > $hdr->endOffset;
	if($trimSize) {
	    $size = $hdr->endOffset - $tr->wizOffset;
	}
	$status = $self->accessor->getRecordingFileChunk(
				$self, $path, $fn,
				$offset, $size, $outStartOff, $progressBar, 0
			    );
	last if(!is_success($status) || $trimSize);

	if($self->join) {
	    $append = 1;
	    $outStartOff += $size;
	} else {
	    $append = 0;
	    $outStartOff = 0;
	}

	$done += $size;

	$progressBar->done($done) if($progressBar);
	$self->accessor->closeRecordingFileOut if(!$self->join);
    }

    $self->accessor->closeRecordingFileOut;

    return $status;
}

sub renameRecording($$$$) {
    my ($self, $hdr, $path, $outdir) = @_;
    return $self->accessor->renameRecording($self, $hdr, $path, $outdir);
}

sub deleteRecording($$$$$$) {
    my ($self, $hdr, $trunc, $stat, $indexName, $path) = @_;
    my $status;

    my $name = $self->getRecordingName($hdr, $indexName, 0);

    foreach my $tr (@{$trunc->entries}[0..$trunc->nentries-1]) {
	my $fn = $tr->fileName;

        $status = $self->accessor->deleteRecordingFile(
			    $path, $name, $hdr->isMediaFile ? undef : $fn
			);
	return $status if($hdr->isMediaFile || !is_success($status));
    }

    $status = $self->accessor->deleteRecordingFile($path, $name,
						   $hdr->headerName);
    return $status if(!is_success($status));

    if(!$hdr->isMediaFolder) {
	$status = $self->accessor->deleteRecordingFile(
				$path, $name, $trunc->beyonwizFileName
			    );
	return $status if(!is_success($status));

	$status = $self->accessor->deleteRecordingFile(
				$path, $name, $stat->beyonwizFileName
			    );
	return $status if(!is_success($status));
    }

    $status = $self->accessor->deleteRecordingFile($path, $name, undef);

    return $status if(!is_success($status));

    return $status;
}

1;
