#!/usr/bin/perl
use warnings;
use WWW::Mechanize::Chrome;
use Log::Log4perl qw(:easy);
use feature 'say';
use Data::Dumper;

#system('export CHROME_BIN=/usr/bin/google-chrome-stable');

my $mech = WWW::Mechanize::Chrome->new();
my %open_tabs = $mech->list_tabs()->get;

say Dumper \%open_tabs;


#say $mech->history(23);

#my @n = (0..400);

#for($n){
#	my $link = $mech->history($n);
#	if ($link =~ m//ogs){
#		say $link; 
#	}
#}