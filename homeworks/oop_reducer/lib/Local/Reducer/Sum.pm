package Local::Reducer::Sum;

use strict;
use warnings;
use DDP;

use base qw(Local::Reducer);

sub new {
	my ($class, %params) = @_;
	return bless \%params, $class;
}

1;