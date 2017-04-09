package Local::Reducer;

use strict;
use warnings;
use Local::Source::Array;

=encoding utf8

=head1 NAME

Local::Reducer - base abstract reducer

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

sub reduce_n {
	my ($self, $n) = @_;
	my $sum;
	for my $i ( $self->{initial_value} .. $n) {
		$sum += $self->{source}->next;
	}
	$self->{initial_value} = $n + 1;
	$self->{sum} = $sum;
	return $self->{sum};
}

sub reduce_all {
	my ($self) = @_;
	for my $i ( $self->{initial_value} .. scalar($self->{source}) - 1) {
		$self->{sum} += $self->{source}->[$i];
	}
	$self->{initial_value} = scalar($self->{source}) - 1;
	return $self->{sum};
}

sub reduced {
	my ($self) = @_;
	return $self->{sum};
}


1;
