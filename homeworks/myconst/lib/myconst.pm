package myconst;

use strict;
use warnings;
use Scalar::Util 'looks_like_number';

no strict 'refs';
sub import {
	for (@_) {
		my ($key, $val) = $_;
		$$key = sub { $val };
	}
}

1;
