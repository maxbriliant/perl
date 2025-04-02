#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use PDF::API2;
 
# Create a blank PDF file
my $pdf = PDF::API2->new("images.pdf");
my $page = $pdf->page();
my $gfx = $page->gfx();
my $dir = "/home/max/scripts/17-31-Screenshots";
my @images = glob( $dir .'/*');
@images = sort { -C $b <=> -C $a } @images; 


my $png = $pdf->image_png($images[0]);
$page->mediabox(1920,1080);
 
$pdf->saveas("images.pdf");

my $counter = 1;

foreach ( @images ) {
	$pdf = PDF::API2->open("images.pdf");
	$pdf->preferences(-fit => 1,);
	$page = $pdf->page($counter);
	$page->mediabox(1920,1080);
	$gfx = $page->gfx();
	$png = $pdf->image_png($_);
	$gfx->image($png);
	$counter++;
	say $_;
	$pdf->saveas("images.pdf");
}
