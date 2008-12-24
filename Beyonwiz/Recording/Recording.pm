package Beyonwiz::Recording::Recording;

=head1 SYNOPSIS

    use Beyonwiz::Recording::Recording;


=head1 SYNOPSIS

Download recordings from the Beyonwiz.

=head1 CONSTANTS

=over

=item C<INDEX>

The index url path for the beyonwiz (C<index.txt>).

=back

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Recording->new($base, $ts, $date) >>

Create a new Beyonwiz recording downloader object.
C<$base> is the base URL for the Beyonwiz device.
If C<$ts> is true, the download will be into
a single C<.ts> file, otherwise the recording will
be copied as it is on the Beyonwiz.
If C<$date> is true, the recording date is added to
the recording name.
Useful for downloading series recordings.

=item C<< $r->base([$val]); >>

Returns (sets) the device base URL.
The recording URL path name is set when the recording
is downloaded.
The object is intended to allow a sequence of recordings to be downloaded.

=item C<< $r->ts([$val]); >>

Returns (sets) the single-file TS flag.

=item C<< $r->date([$val]); >>

Returns (sets) the flag controlling whether the recording date
is added to the recording name.

=item C<< $r->get_recording_file_chunk($path, $name, $file, $outdir, $append, $off, $size); >>

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

=item C<< $r->get_recording_file($path, $name, $outdir, $file, $append); >>

Download a complete 0000, 0001, etc. recording file from the
Beyonwiz. Note that more than one
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
may refer to any given file.

C<$path>, C<$name>, C<$outdir>, C<$file> and C<$append> are as
in I<get_recording_file_chunk>.

=item C<< $r->get_recording($hdr, $trunc, $path, $outdir, $show_progress); >>

Download a Beyonwiz recording, either as a direct copy from the Beyonwiz, or
into a single C<.ts> file (if C<< $r->ts >> is true).
C<$hdr> is the recording's header file object,
C<$trunc> is the recording's trunc file object,
and C<$path> is the path name from the recording's
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.
If C<$outdir> is defined and not the empty string, the recording is
placed in that directory, rather than the current directory.
The name of the downloaded recording is derived from the recording title
in the C<$hdr>, with the recording date appended if C<< $r->date >>
is true.
If C<$show_progress> is not C<undef> it is called as a function
with C<bignum> arguments (C<$file_size>, C<$done>), where C<$file_size>
is the size of the transfer, and C<$done> is the amount transferred
already.
Both in bytes.

=back

=head1 PREREQUISITES

Uses packages:
C<LWP::Simple>,
C<URI>,
C<URI::Escape>,
C<HTTP::Status>,
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

use LWP::Simple qw(getstore $ua);
use URI;
use URI::Escape;
use HTTP::Status;
use File::Basename;

use constant STAT => 'stat';

use constant BADCHARS => $^O eq 'MSWin32' || $^O eq 'cygwin'
				? '\\/:*?"<>|'	# Windows or Windows inside
				: '\/';		# For Unix & HFS+ filesystems

sub new() {
    my ($class, $base, $ts, $date) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	base    => $base,
	url     => undef,
	ts	=> $ts,
	date	=> $date,
    };
    bless $self, $class;

    return $self;
}

sub base($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{base};
    $self->{base} = $val if(@_ == 2);
    return $ret;
}

sub ts($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{ts};
    $self->{ts} = $val if(@_ == 2);
    return $ret;
}

sub date($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{date};
    $self->{date} = $val if(@_ == 2);
    return $ret;
}

sub add_dir($$) {
    my ($dir, $name) = @_;
    if($dir) {
	$dir .= '/' if(substr($dir, -1, 1) ne '/');
	$name = $dir . $name;
    }
    return $name;
}

sub get_recording_file_chunk($$$$$$$) {
    my ($self, $path, $name, $file, $outdir, $append, $off, $size) = @_;

    my $data_url = $self->base->clone;

    $data_url->path($path . '/' . uri_escape($file));
    $name .= '/' . $file if(!$self->ts);
    $name = add_dir($outdir, $name);
    $name = '>' . $name if($append);

    my $request = HTTP::Request->new(GET => $data_url);
    $request->header(range => "bytes=$off-" . ($off+$size-1));

    my $response = $ua->request($request, $name);

    my $status = $response->code;

    warn "$name/$file : ", status_message($status), "\n"
	if(!is_success($status));
    return $status;
}

sub get_recording_file($$$$$$) {
    my ($self, $path, $name, $file, $outdir, $append) = @_;

    my $data_url = $self->base->clone;

    $data_url->path($path . '/' . uri_escape($file));
    $name .= '/' . $file if(!$self->ts);
    $name = add_dir($outdir, $name);
    $name = '>' . $name if($append);
    my $status = getstore($data_url, $name);
    warn "$name, $file : ", status_message($status), "\n"
	if(!is_success($status));
    return $status;
}

sub get_recording($$$$$$) {
    my ($self, $hdr, $trunc, $path, $outdir, $show_progress) = @_;
    my $status;

    my $name = uri_unescape(basename($path));
    if(defined($hdr->title) && length($hdr->title) > 0) {
	$name = $hdr->title;
	if($self->date) {
	    my $d = gmtime($hdr->starttime);
	    substr $d, 11, 9, '';
	    $name .= ' ' . $d;
	}
    }
    # Some ugliness to interpolate BADCHARS into the character class
    $name =~ s/[${\(BADCHARS)}]/_/g;
    if($self->ts) {
	$name =~ s/.(tv|rad)wiz$//;
	$name .= '.ts';
    } 

    my $size = $trunc->recording_size + $hdr->size + $trunc->size;

    my $done = 0;
    &$show_progress($size, $done) if($show_progress);

    if(!$self->ts) {
	if(-d $name) {
	    warn "Recording $name already exists\n";
	    return RC_PRECONDITION_FAILED;
	}
	my $dirname = add_dir($outdir, $name);
	if(!mkdir($dirname)) {
	    warn "Can't create $dirname: $!\n";
	    return RC_PRECONDITION_FAILED;
	}
	$status = $self->get_recording_file($path, $name,
					$hdr->headerName, $outdir, 0);
	return $status if(!is_success($status));
	$done += $hdr->size;
	&$show_progress($size, $done) if($show_progress);

	$status = $self->get_recording_file($path, $name, STAT, $outdir, 0);
	return $status if(!is_success($status));

	$status = $self->get_recording_file($path, $name,
					Beyonwiz::Recording::Trunc::TRUNC,
					$outdir, 0);
	return $status if(!is_success($status));
	&$show_progress($size, $done) if($show_progress);
	$done += $trunc->size;

    }

    my $append = 0;
    my $lastfile = -1;

    foreach my $tr (@{$trunc->entries}) {
	my $fn = sprintf "%04d", $tr->fileNum;
	if($self->ts) {
	    $status = $self->get_recording_file_chunk(
				    $path, $name, $fn, $outdir, $append,
				    $tr->offset, $tr->size
				);
	    $append = $self->ts;
	} else {
	    $status = $self->get_recording_file(
				    $path, $name, $fn, $outdir, 0,
				)
		if($lastfile != $tr->fileNum);
	    $lastfile = $tr->fileNum;
	}

	last if(!is_success($status));

	$done += $tr->size;

	&$show_progress($size, $done) if($show_progress);

    }
    return $status;
}

1;
