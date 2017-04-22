package Local::Reducer::MaxDiff;

use strict;
use warnings;
use DDP;

use base qw(Local::Reducer);

sub new {
	my ($class, %params) = @_;
	return bless \%params, $class;
}

sub reduce_n {
	my ($self, $n) = @_;
	my $sum;
	for my $i ( $self->{initial_value} .. ($n-1)) {
		my $lol = $self->{row_class}->new( str => $self->{source}->next);
		$sum += $lol->{$self->{field}} if defined($lol->{$self->{field}});
	}
	$self->{initial_value} = $n;
	$self->{sum} = $sum;
	return $self->{sum};
}

sub reduce_all {
	my ($self) = @_;
	for my $i ( $self->{initial_value} .. @{$self->{source}->{array}} - 1) {
		my $tmp = $self->{row_class}->new( str => $self->{source}->next);
		$self->{sum} += $tmp->{$self->{field}} if defined($tmp->{$self->{field}}) and $tmp->{$self->{field}} =~ m/^\d+$/;
	}
	$self->{initial_value} = @{$self->{source}->{array}} - 1;
	return $self->{sum};
}

sub reduced {
	my ($self) = @_;
	return $self->{sum};
}

1;