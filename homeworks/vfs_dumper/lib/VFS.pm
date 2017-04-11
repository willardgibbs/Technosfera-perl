package VFS;
use utf8;
use strict;
use warnings;
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
use DDP;

no warnings 'experimental::smartmatch';

sub mode2s {

}
sub D_parse {
	my $buf = shift;
	my $href = shift;
	my @first = unpack("An", $buf);
	my @sec = unpack("An(A)$first[1]n", $buf);
	substr $buf, 0, scalar @sec, "";
	$href->{"type"} = "directory";
	for my $i (2 .. $sec[1]+1) {
		$href->{"name"} .= $sec[$i];
	}
	$href->{"mode"} = $sec[$sec[1]+2];
	return $href;
}
sub F_parse {
	my $buf = shift;
	my $href = shift;
	my @first = unpack("An", $buf);
	my @sec = unpack("An(A)$first[1]nN(A)20", $buf);
	substr $buf, 0, scalar @sec, "";
	$href->{"type"} = "file";
	for my $i (2 .. $sec[1]+1) {
		$href->{"name"} .= $sec[$i];
	}
	$href->{"mode"} = $sec[$sec[1]+2];
	$href->{"size"} = $sec[$sec[1]+3];
	for my $i ($sec[$sec[1]+4] .. $sec[1]+24) {
		$href->{"hash"} .= $sec[$i];
	}
	return $href;
}
sub parse {
	my $buf = shift;
	my $str = "The blob should start from 'D' or 'Z'";
	my $href = {};
	my $buf = D_parse($buf, $href);

	
	# if (@first eq "Z") {
	# 	return $list;
	# }
	# unless ($first eq "D") {
	# 	die $str;
	# }
	# my $second = unpack("A", $buf);
	# p $second;
	# if ($second eq "DI") {
	# 	say "wow";
	# }
	# my $lol = unpack();

	# if ($first eq "D") {
	# 	my ($type, $name) = unpack("nU", $buf);
	# 	$list->{type} = "directory";
	# 	$list->{name} = $name;
	# }
	# if ($first eq "F") {
	# 	my ($type, $name) = unpack("nU", $buf);
	# 	$list->{type} = "file";
	# 	$list->{name} = $name;
	# }

}
1;
