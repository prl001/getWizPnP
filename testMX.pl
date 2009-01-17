#!/usr/bin/perl

use strict;
use warnings;

use Beyonwiz::WizPnP;
use Time::HiRes;

package Beyonwiz::DummyWizPnP;

our @ISA = qw( Beyonwiz::WizPnP );

sub new() {
    my ($class, $name, $path) = @_;
    $class = ref($class) if(ref($class));

    my $self = Beyonwiz::WizPnP->new($name, $path);

    return bless $self, $class;
}

# A dummy version of process() that doesn't fetch
# the device descriptor, and just uses the device nickname
# to make a dummy entry in the device lookup table.

sub process($$) {
    my ($self, $data) = @_;

    my $resp = HTTP::Response->parse($data);

    if(!$resp->is_success) {
	warn 'Bad WizPnP response: ', $resp->status_line, "\n"
	    unless($self->_quietLocation && !defined $resp->code);
	return undef;
    }

    my $name = $resp->header('NICKNAME');
    if(!defined $name || $name eq '') {
	warn "Bad WizPnP response: No device NICKNAME\n";
	return undef;
    }
    $name = lc $name;
    $self->devices->{$name} = undef;
    return undef;
}


package main;

$| = 1;

die "Usage: $0 delay repeats [maxdevs [wizpnpTimeout [wizpnpPoll]]\n"
    if(@ARGV < 2 || @ARGV > 5);

my ($delay, $repeats, $maxdevs, $wizpnpTimeout, $wizpnpPoll) = @ARGV;

my ($tott, $nsamp) = (0, 0);

$maxdevs = 1 if(!defined $maxdevs);

foreach my $n (1..$repeats) {
    sleep($delay);
    my $pnp = Beyonwiz::DummyWizPnP->new;
    #Beyonwiz::WizPnP::debug(1);

    $pnp->maxDevs($maxdevs);
    $pnp->wizpnpTimeout($wizpnpTimeout) if(defined $wizpnpTimeout);
    $pnp->wizpnpPoll($wizpnpPoll) if(defined $wizpnpPoll);

    my $startt = Time::HiRes::time;
    $pnp->search;
    if($maxdevs == 0 && $pnp->ndevices != 0
    || $maxdevs != 0 && $pnp->ndevices >= $maxdevs) {
	my $dt = Time::HiRes::time - $startt;
	printf "%4d %3d %6.3f\n", $n, $pnp->ndevices, $dt;
	$tott += $dt;
	$nsamp++;
    } else {
	print "Search $n found ", $pnp->ndevices, " of $maxdevs devices\n";
    }
}

printf "%.4f sec average delay\n", $tott/$nsamp if($nsamp > 0);
