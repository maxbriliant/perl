#/usr/bin/perl

#Tool for Extracting Text from Images
use 5.1.0;
use Image::OCR::Tesseract 'get_ocr';
 
my $image = '/home/mx/Desktop/screenshot1.png';
my $text = get_ocr($image);

print $text;
