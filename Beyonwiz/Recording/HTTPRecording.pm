package Beyonwiz::Recording::HTTPRecording;

=head1 NAME

    use Beyonwiz::Recording::HTTPRecording;

=head1 SYNOPSIS

Download recordings from the Beyonwiz.

=head1 SUPERCLASS

Inherits from
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Recording>

=head1 METHODS

=over 4

=item C<< Beyonwiz::Recording::HTTPRecording->new($base, $ts, $date, $resume, $force) >>

Create a new Beyonwiz recording downloader object.
C<$base> is the base URL for the Beyonwiz device.
If C<$ts> is true, the download will be into
a single C<.ts> file, otherwise the recording will
be copied as it is on the Beyonwiz.
If C<$date> is true, the recording date is added to
the recording name.
Useful for downloading series recordings.
If C<$resume> is true, allow resumption of recording download
that appear to be incomplete.
If C<$force> is true, allow a download to overwrite an existing download.

=item C<< $r->base([$val]); >>

Returns (sets) the device base URL.
The recording URL path name is set when the recording
is downloaded.
The object is intended to allow a sequence of recordings to be downloaded.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::Recording>|Beyonwiz::Recording::Recording>,
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
C<LWP::Simple>,
C<URI>,
C<URI::Escape>,
C<HTTP::Status>,
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
use LWP::Simple qw(getstore $ua);
use URI;
use URI::Escape;
use HTTP::Status;
use POSIX;

use constant BADCHARS => $^O eq 'MSWin32' || $^O eq 'cygwin'
				? '\\/:*?"<>|'	# Windows or Windows inside
				: '\/';		# For Unix & HFS+ filesystems

our @ISA = qw( Beyonwiz::Recording::Recording );

my $accessorsDone;

sub new() {
    my ($class, $base, $ts, $date, $resume, $force) = @_;
    $class = ref($class) if(ref($class));

    my %fields = (
	base    => $base,
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

sub getRecordingFileChunk($$$$$$$) {
    my ($self, $path, $name, $file, $outdir,
        $append, $off, $size, $outOff, $progressBar) = @_;

    my $data_url = $self->base->clone;

    $data_url->path($path . '/' . uri_escape($file));
    $name .= '/' . $file if(!$self->ts);
    $name = addDir($outdir, $name);

    if(!open TO, ($append ? '+<' : '>'), $name) {
	warn "Can't create $name: $!\n";
	close TO;
	return RC_FORBIDDEN;
    }
    binmode TO;

    if(!sysseek TO, $outOff, SEEK_SET) {
	warn "Seek error on $name: $!\n";
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

    warn "$name/$file: ", status_message($status), "\n"
	if(!is_success($status));
    return $status;
}

sub getRecordingFile($$$$$$) {
    my ($self, $path, $name, $file, $outdir, $append) = @_;

    my $data_url = $self->base->clone;

    $data_url->path($path . '/' . uri_escape($file));
    $name .= '/' . $file if(!$self->ts);
    $name = addDir($outdir, $name);
    $name = '>' . $name if($append);
    my $status = getstore($data_url, $name);
    warn "$name/$file: ", status_message($status), "\n"
	if(!is_success($status));
    return $status;
}

1;
