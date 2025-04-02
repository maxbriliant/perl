#!/usr/bin/perl
use Data::Dumper;
use strict;
use warnings;
use File::Slurp;

#open kriegt 3 Argumente: Variable, Mode, Dateiname/Pfad
open(my $file, '<', 'text.txt') or die "Konnte Datei nicht finden: $!";

print "\nNach Welchem Wort möchtest du Suchen?\n";
my $word = lc(<STDIN>) ;
chomp $word;


my @words_file;
my @sentences_file;

# Iterator
while(my $line = <$file>) {
	 push(@words_file, split(' ', $line));
}

#print Dumper(\@words_file);

#Gibt die Anzahl des Gesuchten Wortes aus
sub wordcounter{
	my ($wordArrayRef, $searchWord) = @_;

	my $counter = 0;
	foreach my $word (@$wordArrayRef) {
		#print $word;
		$counter++ if $word =~ /$searchWord/i;
		
	}
    print "\n" . $counter . " Mal im Text\n";
}



#Suchfunktion Sucht nach Wort oder Wortabschnitt
#Gibt dann den jeweiligen SATZ aus, in dem es vorkommt.
#Definiere Satz: Text zwischen zwei Punkten, egal ob Zeilenumbruch
#Jedoch, Text muss mehr als 1 Wort enthalten.



seek($file, 0, 0); 
# Zurücksetzen des Dateizeigers auf den Anfang der Datei

my $slurp = read_file('text.txt');
@sentences_file = split(/\./, $slurp);



sub sentenceFinder{
	my ($sentences_array_ref, $searchWord) = @_;
	my @sentencesArray = @$sentences_array_ref;
	my $iter_count = 0;
	
	#Dumper print \@sentencesArray;

	print "\nVorkommende Sätze mit \"$searchWord\": \n";

	foreach my $sentence (@sentencesArray){
		++$iter_count;
		
	$sentence =~ s/(?<!\w)\n+//;

	my $find = $sentence =~ /$searchWord/i ? $iter_count.". Satz: ".$sentence.".\n": '';
	#chomp $find;
	print $find;

	}
	print "\n";
}

wordcounter(\@words_file, $word);
sentenceFinder(\@sentences_file, $word);