package Local::Reducer::Sum;

use Local::Row::Simple;
use Local::Row::JSON;
use DDP;
use strict;
use warnings;

sub new {
	my ($class, %params) = @_;
	return bless \%params, $class;
}

sub reduce_n {
	my ($self, $n) = @_;
	my $sum;
	for my $i ( $self->{initial_value} .. ($n-1)) {
		my $tmp = $self->{row_class}->new( str => $self->{source}->next);
		$sum += $tmp->get($self->{field}) if defined($self->{field}) and defined($tmp);
	}
	$self->{initial_value} = $n;
	$self->{sum} = $sum;
	return $self->{sum};
}

sub reduce_all {
	my ($self) = @_;
	for my $i ( $self->{initial_value} .. @{$self->{source}->{array}} - 1) {
		my $tmp = $self->{row_class}->new( str => $self->{source}->next);
		$self->{sum} += $tmp->get($self->{field}) if defined($self->{field}) and defined($tmp) and $tmp->get($self->{field}) =~ m/^\d+$/;
	}
	$self->{initial_value} = @{$self->{source}->{array}} - 1;
	return $self->{sum};
}

sub reduced {
	my ($self) = @_;
	return $self->{sum};
}

1;