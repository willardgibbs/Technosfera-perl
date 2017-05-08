package VFS;

use strict;
use warnings;
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
use DDP;
use Encode qw(decode encode);

no warnings 'experimental::smartmatch';

sub mode2s { 
	my $mode = shift;
	my $ref;
	my $i = 1;
	my @right1 = ("other", "group", "user");
	my @right2 = ("execute", "write", "read");
	for my $val1 (@right1) {
		for my $val2 (@right2) {
			if ($mode & $i) {
				$ref->{$val1}->{$val2} = JSON::XS::true;
			} else {
				$ref->{$val1}->{$val2} = JSON::XS::false;
			}
			$i *= 2;
		}
	}
	return $ref;
}

sub D_parse {
	my $buf = shift;
	my $href = {};
	($href->{name}, $href->{mode}, $buf) = unpack "n/A* n A*", $buf;
	$href->{name} = decode('utf-8', $href->{name});
	$href->{type} = "directory";
	$href->{mode} = mode2s($href->{mode});
	return $buf, $href;
}

sub F_parse {
	my $buf = shift;
	my $href = {};
	($href->{name}, $href->{mode}, $href->{size}, $href->{hash}, $buf) = unpack "n/A* n N A20 A*", $buf;
	$href->{hash} = unpack "H*", $href->{hash};
	$href->{name} = decode('utf-8', $href->{name});
	$href->{type} = "file";
	$href->{mode} = mode2s($href->{mode});
	return $buf, $href;
}

sub file_sys {
	my $buf = shift;
	my $fs;
	while ($buf) {
		my $tmp = unpack "A", $buf;
		$buf = substr $buf, 1;
		if ($tmp eq 'D'){
			($buf, my $href_D) = D_parse($buf);
			push @$fs, $href_D;
		} elsif ($tmp eq 'F') {
			($buf, my $href_F) = F_parse($buf);
			push @$fs, $href_F;
		} elsif ($tmp eq 'I') {
			$fs->[-1]->{list} = file_sys($buf);
		} elsif ($tmp eq 'U') {
			return $fs;
		} elsif ($tmp eq 'Z') {
			die("Garbage ae the end of the buffer") if ($buf);
			return $fs;
		}
	}
}

sub parse {
	my $buf = shift;
	my $arref = [];

	my $first = unpack "A", $buf;
	if ($first eq "Z") {		
		return {};
	} elsif ($first ne 'D') {
		die "The blob should start from 'D' or 'Z'";
	}
	$arref = file_sys($buf);
	p $arref->[0];
	return $arref->[0];
}

1;