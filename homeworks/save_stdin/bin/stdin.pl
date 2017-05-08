#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;


my $file;
GetOptions("file=s" => \$file);
open(my $fh, ">", $file);

$SIG{STOP} = \&ctrl_d;
$SIG{INT} = \&ctrl_c;

my $flag = 0;

syswrite (STDOUT , "Get ready\n", length "Get ready\n");
while(<>) {	
	syswrite ($fh, $_, length $_);
}

writenow();

sub writenow {
	close($fh);	
	open(my $fh1, "<", $file);
	my $num_symbols = 0;
	my $num_rows = 0;
	my $avg_row = 0;
	while(<$fh1>){
		$num_rows++;
		$num_symbols += (length $_) - 1;
	}
	$avg_row = $num_symbols/$num_rows;
	my $buff = "$num_symbols $num_rows $avg_row";
	syswrite (STDOUT, $buff, length $buff);
	close($fh1);
}

sub ctrl_c {
	if ($flag == 0) {
    	syswrite (STDERR, "Double Ctrl+C for exit", length "Double Ctrl+C for exit");
		$flag = 1;	
	}else {
		writenow();
		exit;		
	}
}

sub ctrl_d {
	writenow();
	print STDERR "lol";
    exit;
}
