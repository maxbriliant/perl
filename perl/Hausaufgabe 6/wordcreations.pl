#!/usr/bin/env perl
use strict;
use warnings;
use feature qw(say);



my $list_file_path = "./creative_text.txt";
my $text;
my @words;

open(FH, '<', $list_file_path) or die $!;

while (<FH>){
	 $text = $_;
}
@words = split / / , $text;
foreach my $word (@words){
	if ($word !~ /^[AEIOUaeiou]/i && $word =~ /[aeiouäöü]{2,}/i && $word !~ /[aeiou]$/){
		print $word." ";
	}  
}

