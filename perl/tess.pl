#/usr/bin/perl
use 5.1.0;
use Image::OCR::Tesseract 'get_ocr';
 
my $image = '/home/jack/Desktop/screenshot1.png';
my $text = get_ocr($image);

print $text;
