#!/bin/perl
use warnings;
use File::Basename;

my $username = $ENV{LOGNAME}; # || $ENV{USER} || getpwuid($<);

open(DATA, ">>", "textFile", );
while(<DATA>) {print "$_";}


my $pathText = "/home/".$username."/prog/perl/textFile";

print $pathText."\n";

my $basename = basename($pathText);
my $dirname  = dirname($pathText);

print $dirname."\n";
print $basename."\n";

