package Local::Source::Array;

use strict;
use warnings;

sub new {
	my ($class, %params) = @_;
	$params{number} = scalar @{$params{array}};
	return bless \%params, $class;
}

sub next {
	my ($self) = shift;
	return undef unless $self->{number};
	$self->{number}--;
	return $self->{array}->[@{$self->{array}} - 1 - $self->{number}];
}
1;