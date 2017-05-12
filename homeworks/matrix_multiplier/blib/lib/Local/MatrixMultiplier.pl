package Local::MatrixMultiplier;

use strict;
use warnings;
use POSIX qw(sys_wait_h);

sub mult {
    my ($mat_a, $mat_b, $max_child) = @_; 
    my $res = [];

    check($mat_a, $mat_b);

    my $start;
    my $end;
    my $interval = int(@{$mat_a}/$max_child);
    my $pids = [];
    my $r = [];
    my $w = [];

    for my $i (0..$max_child-1){
        pipe ($r->[$i], $w->[$i]);
        my $pid = fork();
        if($pid) {
            push @$pids, $pid;
            close $w->[$i];
            my ($s,$j) = ($i * $interval - 1, 0); 
            my $fh = $r->[$i];     
            while (< $fh >) {
                $s++ if $j == 0;
                $res->[$s][$j] = 0 + $_;
                $j = ($j + 1) % scalar @{$mat_a};
            }
            close $r->[$i];
        } else {
            close $r->[$i];
            if ($i == $max_child-1) {
                $start = $interval*$i;
                $end = @{$mat_a}-1;
            }else {
                $start = $i*$interval;
                $end = ($i + 1)*$interval - 1;
            }

            calc($res, $mat_a, $mat_b, $start, $end);

            write_part($w->[$i], $res, $start, $end, @{$mat_a}-1);

            close $w->[$i];   
            exit;       
        }
    }
    
    waitpid($_,0) for @$pids;
    
    return $res;
}

sub calc {
    my ($res, $mat_a, $mat_b, $start, $end) = @_;
    for my $s ($start..$end) {
        for my $i (0..@{$mat_a}-1) {
            $res->[$i][$j] = 0; 
            for my $k (0..@{$mat_a}-1) {
                $res->[$i][$j] += $mat_a->[$i][$k] * $mat_b->[$k][$j];  
            }   
        }   
    }   
}

sub write_part {
    my ($w, $res, $start, $end, $last_row) = @_;
    for my $j ($start..$end) {
        for my $k (0..$last_row) {
            print $w "$res->[$j][$k]\n";
        }
    }
}

sub check {
    my ($mat_a, $mat_b) = @_;
    my $param = scalar @{$mat_a};
    die if $param == 0;
    for my $element (@{$mat_a}) {
        die if $param != @{$element};   
    }    
    for my $element (@{$mat_b}) {
        die if $param != @{$element};   
    }
}

1;