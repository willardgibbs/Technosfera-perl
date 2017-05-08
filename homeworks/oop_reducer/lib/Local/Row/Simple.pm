package Local::Row::Simple;

use strict;
use warnings;
# make get, use it for Reducer
sub new {
	my ($class, %param) = @_;
	my @arr = split(",", $param{str});
	my %hash;
	for (@arr) {
		my @tmp = split(":", $_);
		return undef if (scalar @tmp == 1 or  scalar @tmp > 2);
		$hash{$tmp[0]} = $tmp[1];
	}
	return bless \%hash, $class;
}
1;
