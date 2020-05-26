#!/usr/bin/perl
use 5.20.0;
use Image::Magick;

###
#extracting text from images or screenshots
#including mashine learned algorithms
###

my $mashine;
my @images;
my @formats = ["jpg","jpeg","svg","png"];

my $magick = Image::Magick->new;

state %files; 		## filled by openImage($filePath1,$filePath2 ...)
my @fileNames;  ## filled by openImage($filePath1,$filePath2 ...)
my @fileObjects;

sub mashine {
	
	my @args;
	my $i = 0;
	foreach my $arg (@_) {
		push(@args, $arg);
		$i +=1;
	}

	### Arguments List
	foreach my $item(@_) { printf("$item\n") };
	###

}

my $count = 0; 
sub openImage {
	foreach my $filePath(@_){
		$count += 1;
		if (index($filePath, "/") != -1 ){
			my $fileName =substr($filePath, rindex($filePath, "/")+1);
			
			my $fileObject = $magick->Read($filePath);
			print("$filePath - was opened with Magick - now to find in "."img$count"." in \%files\n");
			$files{"img$count"} =  $fileObject;
		}
		#elsif (substr($filePath,  ) != -1) {
	}
	return %files;
}

my $img1 = "/home/jack/Pictures/google/1579814197610.png";


my $a=0;
my $b=3;
my $c=5;

#mashine($a,$b,$c);
openImage($img1);

foreach my $key (keys %files)
{
	my $path = $files{$key};
	print "$path - for $key\n";
}




