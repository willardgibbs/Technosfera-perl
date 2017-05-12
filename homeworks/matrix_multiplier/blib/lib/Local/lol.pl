package Local::MatrixMultiplier;

use strict;
use warnings;
use POSIX qw(sys_wait_h);
use DDP;

my $n = 1;

my $pid = [];
push @$pid, fork();
for my $i (0 .. $n-1) {
    if ($pid->[0]) {
        push @$pid, fork();
    }
    unless ($pid->[$i+1]) {
        print "$i\n" for 1 .. 100;
        exit;
    }
}

waitpid($_, 0) for @$pid;
1;
