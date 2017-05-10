package Local::Row::JSON;

use strict;
use warnings;
#use DDP;
# make get, use it for Reducer
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

sub get {
	my ($self, $name, $default) = @_;
	if ($name) {
		return $self->{$name};
	} else {
		return $default;
	}
}
1;