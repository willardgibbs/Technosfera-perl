package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;

sub calculate {
    my @members = @_;
    my @res;
    my $randmem;
    my %memhash;
    my %forbhash;

    for (@members) {
        if (ref $_ eq "ARRAY") {
            $memhash{$_->[0]} = $_->[1];
            $forbhash{$_} = "1";
            $memhash{$_->[1]} = $_->[0];
            $forbhash{$_} = "1";
        } else {
            $memhash{$_} = "x";
            $forbhash{$_} = "1";
        }
    }

    my @keys = keys %memhash;
    my @newkeys = @keys;

    for my $lol (@keys) {
        if ($memhash{$lol} eq 'x') {
            @newkeys = grep { ($_ ne $lol) && ($lol ne $forbhash{$_})} @keys;
        } else {
            @newkeys = grep { ($_ ne $lol) && ($lol ne $forbhash{$_}) && ($_ ne $memhash{$lol})} @keys;
        }
        $randmem = @newkeys[rand @newkeys];
        last if (!(defined $randmem));
        push @res,[ $lol, $randmem];
        $forbhash{$lol} = $randmem;
    }

    return @res;
}
1;