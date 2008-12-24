package Beyonwiz::Recording::Header;

use strict;

use File::Basename;
use LWP::Simple qw(get $ua);
use URI;
use URI::Escape;

use constant DAY => 24*60*60; # Seconds in a day
use constant TVHDR => 'header.tvwiz';
use constant RADHDR => 'header.radwiz';

sub new() {
    my ($class, $name, $base, $path) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	base       => $base,
	path       => $path,
	url        => undef,
	name       => $name,
	headerName => undef,
	unknown    => [],
	lock       => undef,
	mediaType  => undef,
	inRec      => undef,
	service    => undef,
	title      => undef,
	mjd        => undef,
	start      => undef,
	last       => undef,
	sec        => undef,
	endOffset  => [],
	offsets    => []
    };

    return bless $self, $class;
}

sub base($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{base};
    $self->{base} = $val if(@_ == 2);
    return $ret;
}

sub path($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{path};
    $self->{path} = $val if(@_ == 2);
    return $ret;
}

sub url($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{url};
    $self->{url} = $val if(@_ == 2);
    return $ret;
}

sub name($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{name};
    $self->{name} = $val if(@_ == 2);
    return $ret;
}

sub headerName($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{headerName};
    $self->{headerName} = $val if(@_ == 2);
    return $ret;
}

sub unknown($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{unknown};
    $self->{unknown} = $val if(@_ == 2);
    return $ret;
}

sub lock($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{lock};
    $self->{lock} = $val if(@_ == 2);
    return $ret;
}

sub mediaType($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{mediaType};
    $self->{mediaType} = $val if(@_ == 2);
    return $ret;
}

sub inRec($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{inRec};
    $self->{inRec} = $val if(@_ == 2);
    return $ret;
}

sub service($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{service};
    $self->{service} = $val if(@_ == 2);
    return $ret;
}

sub title($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{title};
    $self->{title} = $val if(@_ == 2);
    return $ret;
}

sub mjd($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{mjd};
    $self->{mjd} = $val if(@_ == 2);
    return $ret;
}

sub start($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{start};
    $self->{start} = $val if(@_ == 2);
    return $ret;
}

sub last($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{last};
    $self->{last} = $val if(@_ == 2);
    return $ret;
}

sub sec($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{sec};
    $self->{sec} = $val if(@_ == 2);
    return $ret;
}

sub endOffset($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{endOffset};
    $self->{endOffset} = $val if(@_ == 2);
    return $ret;
}

sub offsets($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{offsets};
    $self->{offsets} = $val if(@_ == 2);
    return $ret;
}

sub valid() {
    my ($self) = @_;
    return defined $self->url;
}

sub isTV() {
    my ($self) = @_;
    return defined($self->headerName) && $self->headerName eq TVHDR;
}

sub isRadio() {
    my ($self) = @_;
    return defined($self->headerName) && $self->headerName eq RADHDR;
}

sub playtime() {
    my ($self) = @_;
    # Magic formula from WizFX code
    return $self->last*10 + $self->sec;
}

sub starttime() {
    my ($self) = @_;
    # Unix epoch, 00:00 1 Jan 1970 UTC, is 40587 days after MJD epoch,
    # 00:00 17 Nov 1858.
    return ($self->mjd - 40587) * DAY + $self->start;
}

sub load(;$) {
    my ($self, $full) = @_;
    my $hdr_data;
    foreach my $h (TVHDR, RADHDR) {
	my $url = $self->base->clone;
	$url->path($self->path . '/' . uri_escape($h));

	my $old_max;
	if(!$full) {
	    $old_max = $ua->max_size;
	    $ua->max_size(2048);
	}

	$hdr_data = get($url);

	$ua->max_size($old_max) if(!$full);

	if(defined $hdr_data) {
	    $self->url($url);
	    $self->headerName($h);
	    (
		$self->{unknown}[0],
		$self->{unknown}[1],
		$self->{unknown}[2],
		$self->{unknown}[3],
		$self->{unknown}[4],
		$self->{lock},
		$self->{mediaType},
		$self->{inRec},
		$self->{service},
		$self->{title},
		$self->{mjd},
		$self->{start},
		$self->{last},
		$self->{sec},
	    ) = unpack 'v5 C3 @1024 Z256 Z256 v x2 V v v', $hdr_data;
	    if($full) {
		my @offsets;
		(
		    $self->{endOffset}[0],
		    $self->{endOffset}[1],
		    @offsets,
		) = unpack '@1548 V*', $hdr_data;
		while(my @o = splice(@offsets,0,2)) {
		    push @{$self->offsets}, [ @o ];
		    printf "0x%08x%08x\n", $o[1], $o[0] if($o[0] || $o[1]);
		}
	    }
	    return;
	}
    }

    $self->url(undef);
    @{$self->unknown} = ();

    foreach my $f (qw(url lock mediaType inRec service
			title mjd start last sec)) {
	$_->{$f} = undef;
    }

    warn "Can't get header for ", $self->name, "\n";
}

1;
