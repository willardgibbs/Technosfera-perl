package myconst;
use warnings;
use Scalar::Util 'looks_like_number';
use DDP;
use 5.010;

our $VERSION = '1.00';

my @constants;

sub valid {
	@arr = @_;
	for my $i (0..$#arr) {
		if ($i%2 == 0) {
			if(ref $arr[$i] eq 'HASH' or ref $arr[$i] eq 'ARRAY') {
				return 0;
			}elsif (defined $arr[$i]) {
				return 0 unless $arr[$i]=~/^\w+$/ and not $arr[$i] =~ /^[^a-zA-Z]+$/;	
			}else {
				return 0;
			}
		}else {
			if (ref $arr[$i] eq 'HASH') {
				return 0 unless %{$arr[$i]};
				for (keys %{$arr[$i]}) {
					return 0 if ref $arr[$i]->{$_} eq 'HASH' or ref $arr[$i]->{$_} eq 'ARRAY';
					return 0 unless $_=~/^\w+$/ and not $_ =~ /^[^a-zA-Z]+$/;
				}
			}elsif (ref $arr[$i] eq 'ARRAY') {
				return 0;
			}
		}
	}
	return 1;
}

sub import{
	shift;
	die unless valid(@_);
	my %hash = @_;
	my $caller = caller;
	while (my ($key, $var) = each %hash){
		if (ref $var eq 'HASH'){
			push @constants, {
				value => $var->{$_},
				name => $_,
				group => $key
			} for (keys %{$var});
		}elsif (ref $var eq ''){
			push @constants, {value => $var,
			name => $key,
			group => 'all'};
		}else {
			die;
		}
	}
	for my $iter (@constants){
		no warnings;#or you will see redefined
		eval 'sub '.$caller.'::'.$iter->{name}.'(){ return $iter->{value};}';
	}
	eval 'sub '.$caller.'::import{
		shift;
		@imp = @_;
		no warnings;#the same
		my $caller = caller;
		if (not @imp){
			eval \'\';
		}else {
			for my $get_str (@imp){
				if($get_str =~ /^:all/){
					for my $var (@constants){
						eval \'sub \'.$caller.\'::\'.$var->{name}.\'(){return $var->{value};} \';
					}
				}elsif ($get_str =~ /^:/) {
					my @group_var = grep {":"."$_->{group}" eq $get_str} @constants;
					for my $var (@group_var) {
							eval \'sub \'.$caller.\'::\'.$var->{name}.\'(){return $var->{value};} \';
					}
				}else{
					for my $var (@constants){
						if ($var->{name} eq $get_str){
							eval \'sub \'.$caller.\'::\'.$var->{name}.\'(){return $var->{value};} \';
						}
					}
				}
			}
		}
	}';
}

1;