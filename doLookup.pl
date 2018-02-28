#!/usr/bin/perl

my $Copyright = 'Copyright 2008-2018 Peter Lamb.
See accompanying LICENSE file for redistribution conditions.';

use strict;
use warnings;

use Beyonwiz::WizPnP;

die "Usage: $0 testnum [maxdevs [expectdevs [wizpnpTimeout [wizpnpPoll]]]]\n"
    if(@ARGV < 1 || @ARGV > 5);

my ($n, $maxdevs, $expectdevs, $wizpnpTimeout, $wizpnpPoll) = @ARGV;

$maxdevs = 1 if(!defined $maxdevs);
$expectdevs = $maxdevs if(!defined $expectdevs);

my $pnp = Beyonwiz::WizPnP->new;
#Beyonwiz::WizPnP::debug(1);

$pnp->maxDevs($maxdevs);
$pnp->wizpnpTimeout($wizpnpTimeout)  if(defined $wizpnpTimeout);
$pnp->wizpnpPoll($wizpnpPoll) if(defined $wizpnpPoll);

$pnp->search;

print "\nSearch $n found ", $pnp->ndevices, " of $expectdevs devices\n"
    if($expectdevs == 0 && $pnp->ndevices == 0
    || $expectdevs != 0 && $pnp->ndevices < $expectdevs);
