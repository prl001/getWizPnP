package Beyonwiz::Recording::Check;

=head1 NAME

    use Beyonwiz::Recording::Check;

=head1 SYNOPSIS

Perform consistency checks on collections of Beyonwiz recordings
and media files.

=head1 CONSTANTS

=over

=item C<STAT>

The stat url path component for the Beyonwiz (C<stat>).

=back

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Check->new($accessor, $name, $path) >>

Create a new Beyonwiz recording file index object.
C<$accessor> is a reference to a
L<C<Beyonwiz::Recording::Accessor>|Beyonwiz::Recording::Accessor>
used to carry out the media file access functions in
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>.
C<$name> is the default name of the recording (usually
the name in the Beyonwiz recording index, see
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.
C<$path> is the path to the source recording folder in C<$name>, and can be a
file system path or a URL depending on the type of C<$accessor>.

=item C<< $c->accessor([$val]); >>

Returns (sets) the media file accessor object reference.

=item C<< $c->name([$val]); >>

Returns (sets) the default recording/media file name.

=item C<< $c->path([$val]); >>

Returns (sets) the source recording/media folder name.

=item C<< $c->path([$val]); >>

Returns (sets) the source recording/media folder name.

=item C<< $c->showHeader([$val]); >>

Returns (sets) flag to display recording name headers
in C<< $c->warning(@mess) >>.
Set to true at object creation time.

=item C<< $c->warning(@mess); >>

Prints the warning messages in C<@mess>, after printing the recording
name if C<< $c->showHeader >> is true.
Then sets C<< $c->showHeader >> to false.

=item C<< $c->checkHeader($hdr); >>

Checks that the main header file exists (if one is expected)
and that it is the correct size.

Cannot distinguish between a completely missing recording folder
and a folder that is missing its header file.

=item C<< $c->checkTrunc($trunc); >>

Checks that the I<trunc> header file exists (if one is expected)
and that it is a valid size, and whether it is present
but under a known incorrect name.

=item C<< $c->checkStat($stat); >>

Checks that the I<stat> header file exists (if one is expected)
and that it is the correct size, and whether it is present
but under a known incorrect name.

=item C<< $c->checkTruncEntries($trunc); >>

Check that the data file indicated by each I<trunc> file entry is
large enough to contain tha span of data indicated in the enrty.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>,
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>,
L<C<Beyonwiz::Recording::Stat>|Beyonwiz::Recording::Stat>.

=head1 BUGS

C<< $c->checkHeader($hdr) >> cannot distinguish between a completely
missing recording folder
and a folder that is missing its header file.

Uses C<bignum> for 64-bit integers, even when the underlying
Perl integers are 64 bits.

=cut

use warnings;
use strict;
use bignum;

use Beyonwiz::Recording::Header qw(TVHDR RADHDR HDR_SIZE);
use Beyonwiz::Recording::Trunc qw(TRUNC WMMETA WMMETA_SIZE TRUNC_SIZE_MULT);
use Beyonwiz::Recording::Stat qw(STAT STAT_SIZE);

my $accessorsDone;

sub new() {
    my ($class, $fileHandle, $name, $allHeaders) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	fileHandle	=> $fileHandle,
	name		=> $name,
	showHeader	=> 1,
    };
    bless $self, $class;

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    $self->warning if($allHeaders);

    return $self;
}

sub warning($@) {
    my ($self, @mess) = @_;
    print { $self->fileHandle } $self->name, ":\n" if($self->showHeader);
    $self->showHeader(0);
    print { $self->fileHandle } @mess;
}

sub checkHeader($$) {
    my ($self, $hdr) = @_;

    $hdr->loadMain;

    if(!$hdr->validMain) {
	$self->warning('    Main header file, recording/media folder,',
			    " or media file not found\n"
			);
    } else {
	if(defined $hdr->headerName) {
	    my ($len, $time) = $hdr->fileLenTime;
	    if(defined $len) {
		if($hdr->headerName eq WMMETA) {
		    if($len != WMMETA_SIZE) {
			$self->warning('    ', $hdr->headerName,
			     ' header file incorrect length',
			     ' expected ', WMMETA_SIZE,
			     ' got ', $len,
			     "\n");
		    }
		} elsif($hdr->headerName eq '') {
		    # Singleton media file, no real header
		    if($len == 0) {
			$self->warning('    ', $hdr->headerName,
			     ' media file empty',
			     "\n");
		    }
		} else {
		    if($len != HDR_SIZE) {
			$self->warning('    ', $hdr->headerName,
			     ' header file incorrect length',
			     ' expected ', HDR_SIZE,
			     ' got ', $len,
			     "\n");
		    }
		}
	    }
	}
    }
}

sub checkTrunc($$) {
    my ($self, $trunc) = @_;

    $trunc->load;

    if(defined $trunc->fileName && defined $trunc->beyonwizFileName) {
	if($trunc->fileName ne $trunc->beyonwizFileName) {
		    $self->warning('    header file ',
			 $trunc->fileName,
			 ' found named ',
			 $trunc->beyonwizFileName,
			 "\n");
	}

	my $len = $trunc->size;

	if(defined $len) {
	    if($trunc->fileName eq WMMETA) {
		if($len != WMMETA_SIZE) {
		    $self->warning('    ', $trunc->fileName,
			 ' header file incorrect length:',
			 ' expected ', WMMETA_SIZE,
			 ' got ', $len,
			 "\n");
		}
	    } elsif($trunc->fileName eq '') {
		# Singleton media file, no real trunc
	    } else {
		if($len == 0) {
		    $self->warning('    ', $trunc->fileName,
			 ' header file is empty',
			 ' expected a non-zero multiple of ',
			 TRUNC_SIZE_MULT,
			 "\n");
		}
		if(($len % TRUNC_SIZE_MULT) != 0) {
		    $self->warning('    ', $trunc->fileName,
			 ' header file incorrect length:',
			 ' expected a multiple of ', TRUNC_SIZE_MULT,
			 ' got ', $len,
			 "\n");
		}
	    }
	} else {
	    $self->warning('    ', $trunc->fileName,
		 ' header file missing ',
		 "\n");
	}
    }
}

sub checkStat($$) {
    my ($self, $stat, $trunc) = @_;

    $stat->load;

    if(defined($stat->fileName) && defined($stat->beyonwizFileName)
    && $stat->fileName ne $stat->beyonwizFileName) {
		$self->warning('    header file ',
		     $stat->fileName,
		     ' found named ',
		     $stat->beyonwizFileName,
		     "\n");
    }
    if(defined $stat->fileName && defined $stat->beyonwizFileName
    && defined $trunc->fileName
    && $trunc->fileName eq TRUNC) {
	my $len = $stat->size;
	if(defined $len) {
	    if($len != STAT_SIZE) {
		$self->warning('    ', $stat->fileName,
		     ' header file incorrect length:',
		     ' expected ', STAT_SIZE,
		     ' got ', $len,
		     "\n");
	    }
	} else {
	    $self->warning('    ', $stat->fileName,
		 ' header file missing ',
		 "\n");
	}
    }
}

sub checkTruncEntries($$) {
    my ($self, $trunc) = @_;

    if($trunc->valid) {
	my $prevTr = undef;
	my ($len, $time);
	foreach my $i (0..$trunc->nentries-1) {
	    my $tr = $trunc->entries->[$i];
	    my $fn = $tr->fileName;

	    if(!defined($prevTr) || $fn ne $prevTr->fileName) {
		($len, $time) = $tr->fileLenTime;
	    }

	    if(defined($prevTr)) {
		if($prevTr->wizOffset + $prevTr->size != $tr->wizOffset) {
		    $self->warning('    trunc file entry ', $i,
			 ' has an inconsistent offset: (',
			 $prevTr->wizOffset, ' + ', $prevTr->size,
			 ' = ', $prevTr->wizOffset + $prevTr->size,
			 ') != ', $tr->wizOffset, "\n");
		}
	    }

	    if(!defined $len) {
		$self->warning('    data file ',
		     $fn, ($fn eq '' ? '' : ' '),
		     'missing',
		     "\n");
	    } else {
		if(($tr->offset + $tr->size) > $len) {
		    $self->warning('    data file ',
			 $fn, ($fn eq '' ? '' : ' '),
			 'too short: expected at least ',
			 $tr->offset + $tr->size,
			 ' got ',
			 $len,
			 "\n");
		 }
	    }
	    $prevTr = $tr;
	}
    }
}

1;

