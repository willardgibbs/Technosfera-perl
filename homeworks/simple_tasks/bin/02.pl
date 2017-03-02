#!/usr/bin/perl

use strict;
use warnings;

=encoding UTF8
=head1 SYNOPSYS

Вычисление простых чисел

=head1 run ($x, $y)

Функция вычисления простых чисел в диапазоне [$x, $y].
Пачатает все положительные простые числа в формате "$value\n"
Если простых чисел в указанном диапазоне нет - ничего не печатает.

Примеры: 

run(0, 1) - ничего не печатает.

run(1, 4) - печатает "2\n" и "3\n"

=cut

sub run {
    my ($x, $y) = @_;
    my $i = undef;
    my $j = undef;
    my $fl = undef;
    for $i ($x .. $y) {
        $fl = 0;
        if ($i <= 1) {
            $fl = 1;
        } else {
    	   for $j (2 .. ($i-1)) {
    	       if ($i % $j == 0 ) {
    	   	       $fl = 1;
               }
            }
        } 
        if ($fl == 0) {
            print "$i\n";
        }
    }
}

1;
