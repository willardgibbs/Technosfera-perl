package myconst;

use 5.010; 
use strict;
use warnings;
use Scalar::Util 'looks_like_number';
use DDP;

sub import {
	no strict 'refs';
	our $str = {};
	my $flag = 1;
	my @mass = @_;
	my $caller = caller;
	for my $i (1 .. (@mass-1)) {
		if ($flag == 1) { # по четности $i
			invalid($mass[$i], 0);
			die "invalid args checked" unless $mass[$i];
			invalid($mass[$i + 1], 1);
			if (ref($mass[$i + 1]) eq "HASH") {
				for my $val (keys %{$mass[$i + 1]}) {
					*{$caller."::".$val} = sub () {$mass[$i + 1]->{$val}};
				}
			} else  {
				*{$caller."::".$mass[$i]} = sub () {$mass[$i + 1]}; 
			}
			$flag = 0;
		} else {
			$flag = 1;
		}
	}
}
sub invalid {
	my $inval = shift;
	my $flag = shift;
	if ($flag == 0) {
		if (ref($inval) eq "HASH") {
			die "invalid args checked";  
		} elsif (ref($inval) eq "ARRAY") {
			die "invalid args checked";
		} elsif (defined $inval) {
			die "invalid args checked" unless $inval =~ /^\w+$/ and (not ($inval =~ /^[^a-zA-Z]+$/));
		}
	} else {
		if (ref($inval) eq "HASH") {
			die "invalid args checked" unless %{$inval};
			for (keys %$inval) {
				die "invalid args checked" unless $_ =~ /^\w+$/ and not $_ =~ /^[^a-zA-Z]+$/;
				die "invalid args checked" if ref($inval->{$_}) eq "HASH" or ref($inval->{$_}) eq "ARRAY";
			} 
		} elsif (ref($inval) eq "ARRAY") {
			die "invalid args checked";
		}
	}
}

1;
