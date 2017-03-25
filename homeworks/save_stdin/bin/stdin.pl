#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $file;
GetOptions("file=s" => \$file);

open(my $fh, ">", $file);

print "Get ready\n";
while(my $input = <>){
	print {$fh} "$input";
}
close($fh);

