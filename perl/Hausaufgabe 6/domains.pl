#!/usr/bin/env perl
use strict;
use warnings;
use feature qw(say);


my $list_file_path = "./mails.txt";

open(FH, '<', $list_file_path) or die $!;

while (<FH>){
	say $_ =~ /@(\w*.\w*)/;
}
