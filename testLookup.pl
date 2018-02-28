#!/usr/bin/perl

my $Copyright = 'Copyright 2008-2018 Peter Lamb.
See accompanying LICENSE file for redistribution conditions.';

use strict;
use warnings;

use Beyonwiz::WizPnP;

$| = 1;

die "Usage: $0 script|direct delay repeats [maxdevs [expectdevs [wizpnpTimeout [wizpnpPoll]]]]\n"
    if(@ARGV < 3 || @ARGV > 7 || $ARGV[0] ne 'script' && $ARGV[0] ne 'direct');

my ($how, $delay, $repeats, $maxdevs, $expectdevs, $wizpnpTimeout, $wizpnpPoll) = @ARGV;

$maxdevs = 1 if(!defined $maxdevs);
$expectdevs = $maxdevs if(!defined $expectdevs);

foreach my $n (1..$repeats) {
    sleep($delay);
    print ($n % 50 == 0 ? "$n\n" : '.');
    if($how eq 'script') {
	my @args = ($n, $maxdevs, $expectdevs);
	push @args, $wizpnpTimeout if(defined $wizpnpTimeout);
	push @args, $wizpnpPoll if(defined $wizpnpPoll);
	system './doLookup.pl', @args;
    } else {
	my $pnp = Beyonwiz::WizPnP->new;
	#Beyonwiz::WizPnP::debug(1);

	$pnp->maxDevs($maxdevs);
	$pnp->wizpnpTimeout($wizpnpTimeout) if(defined $wizpnpTimeout);
	$pnp->wizpnpPoll($wizpnpPoll) if(defined $wizpnpPoll);

	$pnp->search;
	print "\nSearch $n found ", $pnp->ndevices, " of $expectdevs devices\n"
	    if($expectdevs == 0 && $pnp->ndevices == 0
	    || $expectdevs != 0 && $pnp->ndevices < $expectdevs);
    }
}
print "$repeats\n" if($repeats % 50 != 0);
