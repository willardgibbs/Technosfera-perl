package Local::Reducer::Sum;

use strict;
use warnings;
use Local::Source::Array;
use Local::Row::JSON;
use DDP;

use base qw(Local::Reducer);

sub new {
	my ($class, %params) = @_;
	return bless \%params, $class;
}

sub reduce_n {
	my ($self, $n) = @_;
	my $sum;
	for my $i ( $self->{initial_value} .. $n-1) {
		my $lol = Local::Row::JSON->new( str => $self->{source}->next);
		$sum += $lol->{$self->{field}};
	}
	$self->{initial_value} = $n;
	$self->{sum} = $sum;
	return $self->{sum};
}

1;