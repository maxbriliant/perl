#!/usr/bin/perl
use USB::LibUSB;
use File::Fetch;
use 5.10.0;

no warnings;

my $ctx = USB::LibUSB->init();
my @devices = $ctx->get_device_list();

my @output;
my $url = 'http://www.linux-usb.org/usb.ids';
my $filename = split(/\//, $url);

my $fileFetch = File::Fetch->new(uri=>'http://www.linux-usb.org/usb.ids');
my $where = $fileFetch->fetch() or die $fileFetch->error;

#hash
my %idTable;
my @names;

my @allProducts;
my @allVendors;
state @sortedList;

#statics
state $name_product ="";
state $idVendor;
state $idProduct;

my $usbList = $fileFetch->file;
my $usbVendors;
my @usbArray;
my @idVendors;
my @idProducts;
my @idKeys;
my @idValues;

open(my $fileHandler, $usbList);

my $counter = 0;
for my $line(<$fileHandler>) {@usbArray[$counter] = $line; $counter+=1;}
#for my $line(@usbArray) { print $line;}

for my $dev(@devices) {
	my $bus_number=$dev->get_bus_number();
	my $device_adress = $dev->get_device_address();
	my $desc = $dev->get_device_descriptor();
	
	$idProduct = sprintf("%04x", $desc->{idProduct});
	push(@idProducts, $idProduct);

	$idVendor = sprintf("%04x", $desc->{idVendor});
	push(@idVendors, $idVendor);
	
	$idTable{$idProduct} = $idVendor;

	#### extracting Products matching my connections #####
	for my $line (@usbArray) {
		if(index($line, $idProduct) != -1) { 
			push(@allProducts, $line);
		}
	}

	#### extracting Vendors matching my connections #####
	for my $line (@usbArray) {
		if(index($line, $idVendor) != -1) { 
			push(@allVendors, $line);
		}
	}

	
	push (@output, sprintf("Bus %03d Device %03d: ID %4s:%4s Vendor Name: %s, ", 
		   $bus_number, $device_adress, $idVendor, $idProduct, %idTable{$idVendor}));
}

#print(grep(/$idVendor/, @usbArray));
	
	
	for my $match(@idVendors){
		for my $build(@names)    {
			for my $line(@usbArray)  {

				$build = sprintf("%s",(grep /$idTable{$match}/, $line));
			}
			#$idTable{$idVendor} .= $line; 
		}
	}



#foreach(@usbArray){print $_};

for my $line(@output){
	for my $build(@names){
		$line = $line.$build;
		print $line;
	}
}

#### hash key value unique method 

my %hash = map {$_ => 1} @allVendors;
my @uniqueVendors = keys %hash;


######### Cleanup space leading elements

for my $line(@uniqueVendors){
#	if (substr($line,0,1) != " "){
	$line =~ s/^\s+|\s+$//g;
#	}
#	else {$line = substr($line,1)}; 
#
}	

state @vendorSubstring;
for my $vendor (@uniqueVendors){
	push(@vendorSubstring, substr($vendor, 0, ((length $vendor)-1)));
}


####
#TODO CONCAT each Line of OUTPUT with vendorString
####



######## eq way of removing doubles not working here? 
#my $i = 0;
#@sortedList = sort(@allVendors);
#$uniqueVendors[0] = $sortedList[0];
#
#foreach my $line(@sortedList){
#	unless($line eq $uniqueVendors[$i]) {
#		push(@uniqueVendors,@sortedList);
#	}
#}
########

#foreach(@output){print $_}; ### APPEND the names (more than one argument) into each element of output
#foreach(@uniqueVendors){print $_};

my @temp;
my $bool = 0;
## match the strings
for my $y (@uniqueVendors){
	for my $i (@output){
		
		#printf("%s\n",substr((substr($i, -6),0,4)));
		
		if(index($y, substr((substr($i, -6),0,4))) != -1) {
				push(@temp, sprintf("$i %s\n",$y));
		}
		elsif((index($i, "25a7") != -1)) { 
				push(@temp,sprintf("$i 25a7  Unknown \n"));
		}

	}
}


#### SPLIT OUTPUT ON NEWLINE -- NOT WORKING yet 

#foreach(@temp) {
#	@temp = split /^/m, $_;
#}

#### hash key value unique method 

my %temp_hash = map {$_ => 1} @temp;
my @uniqueTemp = keys %temp_hash;


print("Possible additions due to over-detailed database-file \n listing with multiple usage of the same Vendor ID's\n\n");

#foreach(@uniqueTemp) {print "$_ + f"};
print @uniqueTemp;


#" Product Name: %04x \n"


#	for my $match(@output) 
#		if ($_[0]