package VFS;
use utf8;
use strict;
use warnings;
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
no warnings 'experimental::smartmatch';

sub mode2s {

}

sub parse {
	my $buf = shift;
	my $lol = "The blob should start from 'D' or 'Z'";
	my $list = {};
	my $first = unpack("A", $buf);
	my $args;
	if ($first eq "Z") {
		return $list;
	} elsif (not $first eq 'D') {
		die "The blob should start from 'D' or 'Z'";
	}



	# if ($first eq "D") {
	# 	my ($type, $name) = unpack("nU", $buf);
	# 	$list->{type} = "directory";
	# 	$list->{name} = $name;
	# };
	# if ($first eq "F") {
	# 	my ($type, $name) = unpack("nU", $buf);
	# 	$list->{type} = "file";
	# 	$list->{name} = $name;
	# };

}
1;
