package Local::Row::JSON;

use strict;
use warnings;
use DDP;

sub new {
	my ($class, %param) = @_;
	$param{str} =~ /\{(.*)\}/;
	my $str = $1;
	return undef unless defined $str;
	my @arr = split(",", $str);
	my %hash;
	for (@arr) {
		my @tmp = split(":", $_);
		return undef if (scalar @tmp == 1 or  scalar @tmp > 2);
		$tmp[0] =~ /"(\w+)"/;
		$tmp[0] = $1;
		$tmp[1] =~ /"?(\w+)"?/;
		$tmp[1] = $1;
		$hash{$tmp[0]} = $tmp[1];
	}
	return bless \%hash, $class;

}
1;