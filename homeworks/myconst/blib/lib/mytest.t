#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 1;

use mylol PI => 3.14;

my $val;

$val = eval { PI() };
is($val, 3.14, "PI is correct");
is(prototype("PI"), '', "PI prototype is empty");