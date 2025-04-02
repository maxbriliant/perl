#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';
use Data::Dumper;

my @data_in;

open(my $fh, '<', 'text.txt') or die "Konnte Datei nicht einlesen!";
open(my $fh2, '>', 'newText.txt') or die "Konnte Datei nicht Schreiben!";

while (my $line <$fh>){
	push @data_in, $line; 
}

foreach my $element (@data_in) { print $element};