package Beyonwiz::Recording::Index;

use LWP::Simple;
use URI;
use URI::Escape;
use File::Basename;
use Beyonwiz::Recording::IndexEntry;

use constant INDEX => 'index.txt';

sub new() {
    my ($class, $base, $path) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	base    => $base,
	path    => $path,
	url     => undef,
	entries => [],
    };
    bless $self, $class;

    $self->url($self->base->clone);
    $self->url->path(uri_escape(INDEX));

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

sub entries($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{entries};
    $self->{entries} = $val if(@_ == 2);
    return $ret;
}

sub nentries() {
    my ($self, $val) = @_;
    return scalar(@{$self->entries});
}

sub valid() {
    my ($self) = @_;
    return defined $self->url;
}

sub uri_path_escape($) {
    my ($path) = @_;
    return uri_escape($path, "^A-Za-z0-9\-_.!~*'()/");
}

sub load($) {
    my ($self) = @_;

    @{$self->entries} = ();

    my $recs = get($self->url) or die "Fetch of ", $self->url, " failed\n";

    foreach my $rec (split /\n/, $recs) {
	my @parts = split /\|/, $rec;
	if(@parts == 2) {
	    push @{$self->entries},
		Beyonwiz::Recording::IndexEntry->new(
			$parts[0], uri_path_escape(dirname $parts[1]));

	} else {
	    warn "Unrecognised index entry: $rec\n";
	}
    }
    return $self->nentries;
}

1;
