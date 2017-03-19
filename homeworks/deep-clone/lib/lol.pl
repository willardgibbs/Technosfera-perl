	if (ref($orig) eq 'HASH'){
		$cloned = {%{$orig}};
		my $cycle = 0;
		while (my ($key, $val) = each(%$orig)){
			$cycle = 1 if ($val eq $orig);
		}
		unless ($cycle) {
			while (my ($key, $val) = each(%$orig)) {
				$cloned->{$key} = clone($val);
			}
		}		
	} elsif (ref($orig) eq 'ARRAY') {
		$cloned = [@{$orig}];
		my $cycle = 0;
		for (@$cloned) {
			$cycle = 1 if ($_ eq $orig); 
		}
		unless ($cycle) {
			$_ = clone($_) for (@$cloned);
		}
	} elsif (defined $orig) {
		if ( ($orig =~ /^\w+$/) or ($orig =~ /^\d+$/)) {
			$cloned = $orig;
		}
	} else {
		$cloned = $orig;
	}
	return $lol;


	if (defined $cloned) {
		if (($cloned =~ /^\w+$/) or ($cloned =~ /^\d+$/)) {
			$cloned = $orig;
		} else {
			if (ref($orig) eq 'HASH'){
				$cloned = {%{$orig}};
				my $cycle = 0;
				while (my ($key, $val) = each(%$orig)){
					$cycle = 1 if ($val eq $orig);
				}
				unless ($cycle) {
					while (my ($key, $val) = each(%$orig)) {
						$cloned->{$key} = clone($val);
					}
				}		
			} elsif (ref($orig) eq 'ARRAY') {
				$cloned = [@{$orig}];
				my $cycle = 0;
				for (@$cloned) {
					$cycle = 1 if ($_ eq $orig); 
				}
				unless ($cycle) {
					$_ = clone($_) for (@$cloned);
				}
			}
		}
	} else {
		$cloned = undef;
	}
	return $cloned;