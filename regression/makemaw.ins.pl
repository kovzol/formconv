#!/usr/bin/perl
# Explodes input functions from stdin and forwards them to stdout.
# Written by Z. Kovacs as his very first real PERL script. ;-)
# A tribute to Gyorgy Pasztor, my friend and tutor in Linux tweaking.

use strict;
use URI::Escape;

our $line;
our $formula;

while ($line=<STDIN>) {
    if (($formula)=($line =~ /funkce=(\S+)&formconv/)) {
	print STDOUT "echo \"".uri_unescape($formula)."\"";
	print STDOUT " | \$F -x aa,.. -x bb,\$ -l simple -I intuitive -O latex -r\n";
	}
    }
