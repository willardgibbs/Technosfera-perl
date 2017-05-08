package Local::Reducer::MaxDiff;

use strict;
use warnings;
#use DDP;
# use get from Row
use base qw(Local::Reducer);

sub new {
	my ($class, %params) = @_;
	return bless \%params, $class;
}

sub reduce_n {
	my ($self, $n) = @_;
	$self->{max_diff} = 0 unless defined($self->{max_diff});
	for my $i ($self->{initial_value} .. ($n-1)) {
		my $lol = $self->{row_class}->new( str => $self->{source}->next);
		if (defined($lol->{$self->{top}}) and defined($lol->{$self->{bottom}})) {
			$self->{max_diff} = $lol->{$self->{top}} - $lol->{$self->{bottom}} if $lol->{$self->{top}} =~ /\d+/ and $lol->{$self->{bottom}} =~ /\d+/ and $self->{max_diff} <= $lol->{$self->{top}} - $lol->{$self->{bottom}};
		}
	}
	$self->{initial_value} = $n;
	return $self->{max_diff};
}

sub reduce_all {
	my $self = shift;
	$self->{max_diff} = 0 unless defined($self->{max_diff});
	for my $i ( $self->{initial_value} .. @{$self->{source}->{text}} - 1) {
		my $lol = $self->{row_class}->new( str => $self->{source}->next);
		if (defined($lol->{$self->{top}}) and defined($lol->{$self->{bottom}})) {
			$self->{max_diff} = $lol->{$self->{top}} - $lol->{$self->{bottom}} if $lol->{$self->{top}} =~ /\d+/ and $lol->{$self->{bottom}} =~ /\d+/ and $self->{max_diff} <= $lol->{$self->{top}} - $lol->{$self->{bottom}};
		}
	}
	$self->{initial_value} = 0;
	return $self->{max_diff};
}

sub reduced {
	my ($self) = @_;
	return $self->{max_diff};
}

1;