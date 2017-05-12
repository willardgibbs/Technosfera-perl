package VFS;
use utf8;
use strict;
use warnings;
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
no warnings 'experimental::smartmatch';
no warnings 'qw';
use DDP;
use Switch;

my $json_str = "";

sub make_rights {
	my $dec = shift;
	my $buff_str = scalar reverse sprintf("%b",$dec);
	my @rights = split //, $buff_str;
	for my $val (@rights) {
		if ($val == 1) {
			$val = "true";
		}else {
			$val = "false";
		}
	}
	my $str .= qw/{"other":{"execute":/.$rights[0].qw/,"write":/.$rights[1].qw/,"read":/.$rights[2];
	$str .= qw/},"group":{"execute":/.$rights[3].qw/,"write":/.$rights[4].qw/,"read":/.$rights[5];
	$str .= qw/},"user":{"execute":/.$rights[6].qw/,"write":/.$rights[7].qw/,"read":/.$rights[8];
	$str .= qw/}}/;
	return $str;
}

sub make_D {
	my $buff = shift;
	my $length = unpack("n", substr $buff,0,2,"");
	my ($name,$right) = unpack("A$length n", substr $buff,0,$length + 2,"");
	$json_str .= "," if "}" eq substr $json_str,-1,1;
	$json_str .= qw/{"type":"directory","name":"/.$name.qw/","mode":/.make_rights($right);
	return $buff;
}

sub make_F {
	my $buff = shift;
	my $length = unpack("n", substr $buff,0,2,"");
	my ($name,$right,$size) = unpack("A$length n N", substr $buff,0,$length + 6,"");
	$json_str .= "," if "}" eq substr $json_str,-1,1;
	$json_str .= qw/{"type":"file","name":"/.$name.qw/","mode":/.make_rights($right).qw/,"size":"/.$size;
	my $hash = unpack("H*", substr $buff,0,20,"");
	$json_str .= qw/","hash":"/.$hash.qw/"}/;
	return $buff;
}

sub parse {
	my $buff = shift;
	my $hash_ref = {};
	my $first_byte = unpack("A", substr $buff,0,1);
	if ($first_byte eq "Z") {		
		return $hash_ref;
	}elsif ($first_byte ne 'D') {
		die "The blob should start from 'D' or 'Z'";
	}
	while ($buff ne "") {
		switch (unpack("A", substr $buff,0,1,"")){
			case "D" 
				{
					$buff = make_D($buff);
					my $byte = unpack("A", substr $buff,0,1,"");
					die "Expected I instead of $byte" if $byte ne "I";
					$json_str .= qw/,"list":[/; 
				}
			 case "F" 
			 	{
			 		$buff = make_F($buff);
			 	}
			case "U" { $json_str .= qw/]}/; }
			case "Z" 
				{	
					die "Garbage ae the end of the buffer" if $buff ne "";
					$hash_ref = JSON::XS::decode_json($json_str);
					$json_str = "";#it is very exciting
					return $hash_ref;
				}
		}
	}
	return $hash_ref;
}

1;
