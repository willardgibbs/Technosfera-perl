package Local::Source::Text;

use strict;
use warnings;

sub new {
	my ($class, %params) = @_;
	my @arr = split($params{delimiter}//'\n',$params{text});
	$params{text} = \@arr;
	$params{number} = scalar $params{text};
	return bless \%params, $class;
}

sub next {
	my ($self) = shift;
	return undef unless $self->{number};
	$self->{number}--;
	return $self->{text}->[$self->{text} - $self->{number} - 1];
}
1;