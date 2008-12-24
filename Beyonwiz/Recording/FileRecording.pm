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

=item C<< Beyonwiz::Recording::FileRecording->new($path, $ts, $date, $resume, $force) >>

Create a new Beyonwiz recording downloader object.
C<$path> is the base path for local Beyonwiz recordings.
If C<$ts> is true, the download will be into
a single C<.ts> file, otherwise the recording will
be copied as it is on the Beyonwiz.
If C<$date> is true, the recording date is added to
the recording name.
Useful for downloading series recordings.
If C<$resume> is true, allow resumption of recording download
that appear to be incomplete.
If C<$force> is true, allow a download to overwrite an existing download.

=item C<< $r->path([$val]); >>

Returns (sets) recording path name.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::Recording>|Beyonwiz::Recording::Recording>,
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>,
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
C<LWP::Simple>,
C<URI>,
C<URI::Escape>,
C<HTTP::Status>,
C<File::Basename>,
C<File::Spec::Functions>,
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
use LWP::Simple qw(getstore $ua);
use URI;
use URI::Escape;
use HTTP::Status;
use File::Basename;
use File::Spec::Functions qw(!path);
use POSIX;

use constant BADCHARS => $^O eq 'MSWin32' || $^O eq 'cygwin'
				? '\\/:*?"<>|'	# Windows or Windows inside
				: '\/';		# For Unix & HFS+ filesystems

our @ISA = qw( Beyonwiz::Recording::Recording );

my $accessorsDone;

sub new($$$$$$) {
    my ($class, $path, $ts, $date, $resume, $force) = @_;
    $class = ref($class) if(ref($class));

    my %fields = (
	path    => $path,
    );

    my $self = Beyonwiz::Recording::Recording->new($ts, $date, $resume, $force);

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
	return RC_BAD_REQUEST;
    }

    if(!sysseek TO, $outOff, SEEK_SET) {
	warn "Seek error on $name: $!\n";
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

1;
