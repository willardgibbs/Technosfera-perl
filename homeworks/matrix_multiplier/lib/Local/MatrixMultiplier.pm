package Local::MatrixMultiplier;

use strict;
use warnings;

sub mult {
    my ($mat_a, $mat_b, $max_child) = @_;
    my $res = [];
    my $res1 = [];
    my $res2 = [];
    for (@{$mat_a}) {
    	die unless (@{$_} == @{$mat_a});
    }
    for (@{$mat_b}) {
    	die unless (@{$_} == @{$mat_a});
    }
    my $pid = fork();
    if ($pid) {
    	my $first = 0;
    	my $second = @{$mat_a}/2-1;
    	for my $i ($first .. $second){
    		for my $j (0 .. @{$mat_a}-1) {
    			for my $k (0 .. @{$mat_a}-1) {
    				$res1->[$i][$j] += $mat_a->[$i][$k] * $mat_b->[$k][$j];
    			}
    		}
    	}
    	waitpid($pid, 0);
    } else {
    	my $first = @{$mat_a}/2;
    	my $second = @{$mat_a}-1;
    	for my $i ($first .. $second){
    		for my $j (0 .. @{$mat_a}-1) {
    			for my $k (0 .. @{$mat_a}-1) {
    				$res2->[$i][$j] += $mat_a->[$i][$k] * $mat_b->[$k][$j];
    			}
    		}
    	}
    	exit;
    }
    my @lol = (@$res1, @$res2);
    return \@lol;
}

1;
