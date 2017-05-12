package Local::MatrixMultiplier;

use strict;
use warnings;
use POSIX qw(sys_wait_h);


sub mult {
    my ($mat_a, $mat_b, $max_child) = @_; 
	my $res = [];

	check($mat_a, $mat_b);

	my $childs;
	my $start;
	my $end;
	my $last_row = @{$mat_a}-1;
	my $interval = int(@{$mat_a}/$max_child);	
	for my $i(0..$max_child-1){
		my ($r, $w);
		pipe ($r, $w);
		my $pid = fork();
		if($pid) {
			close $w;
			#reading		
#			waitpid($pid, WNOHANG);
			my ($s,$j) = ($i * $interval - 1, 0);		
			while (<$r>) {
				$s++ if $j == 0;
				$res->[$s][$j] = 0 + $_;
				$j = ($j + 1)%($last_row + 1);
			}
			close $r;
		}else {
			close $r;			
			#definition of frames of the task for each slave, master does obviously nothing
			if ($i == $max_child-1) {
				$start = $interval*$i;
				$end = $last_row;
			}else {
				$start = $i*$interval;
				$end = ($i + 1)*$interval - 1;
			}

			calc($res, $mat_a, $mat_b, $start, $end, $last_row);

			write_part($w, $res, $start, $end);

			close $w;	
			exit;		
		}
	}
    return $res;
}

sub calc {
	my ($res, $mat_a, $mat_b, $start, $end, $last_row) = @_;
	for my $s ($start..$end) {
		for my $j (0..$last_row) {
			$res->[$s][$j] = 0;	
			for my $k (0..$last_row) {
				$res->[$s][$j] += $mat_a->[$s][$k] * $mat_b->[$k][$j];	
			}	
		}	
	}	
}

sub write_part {
	my ($w, $res, $start, $end) = @_;
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