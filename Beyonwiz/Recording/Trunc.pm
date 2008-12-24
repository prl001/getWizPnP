package Beyonwiz::Recording::Trunc;

use strict;

use File::Basename;
use LWP::Simple;
use URI;
use URI::Escape;
use Beyonwiz::Recording::TruncEntry;

use constant TRUNC => 'trunc';

sub new() {
    my ($class, $name, $base, $path) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	base      => $base,
	path      => $path,
	url       => undef,
	name      => $name,
	entries   => [],
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

sub entries($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{entries};
    $self->{entries} = $val if(@_ == 2);
    return $ret;
}

sub nentries() {
    my ($self) = @_;
    return scalar @{$self->entries};
}

sub valid() {
    my ($self) = @_;
    return defined $self->url;
}

sub load() {
    my ($self) = @_;
    my $hdr_data;
    
    @{$self->entries} = ();

    my $url = $self->base->clone;

    $url->path($self->path . '/' . uri_escape(TRUNC));

    $hdr_data = get($url);

    if(defined $hdr_data) {
	$self->url($url);
	my @trunc = unpack '(V2 v v V2 V)*', $hdr_data;
	while(my @t = splice(@trunc,0,7)) {
	    push @{$self->entries}, Beyonwiz::Recording::TruncEntry->new(
		    [ $t[0], $t[1] ],
		    $t[2],
		    $t[3],
		    [ $t[4], $t[5] ],
		    $t[6]);
	}
	return;
    }

    $self->url(undef);

    warn "Can't get file index for ", $self->name, "\n";
}

1;

