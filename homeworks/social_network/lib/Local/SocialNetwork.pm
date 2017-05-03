package Local::SocialNetwork;

use strict;
use warnings;
use DDP;
use DBD::mysql;
use Data::Dumper;
use JSON::XS;
use Archive::Zip;

our $VERSION = '1.00';

sub read_zip {
	my $file = shift;
	my @arr = Archive::Zip->new($file)->members();
	return $arr[0]->contents();
}

sub select10 {
	my ($dbh1, $name)  = @_;
	if ($name eq "user") {
		my $tmp = $dbh1->prepare("select first_name, last_name from user limit 10");
		$tmp->execute();
		while (my ($first_name, $last_name) = $tmp->fetchrow_array()) {
			print "$first_name, $last_name\n";
		}
	} else {
		my $tmp = $dbh1->prepare("select user_id, friend_id from user_relation limit 10");
		$tmp->execute();
		while (my ($user_id, $friend_id) = $tmp->fetchrow_array()) {
			print "$user_id, $friend_id\n";
		}
	}
}

sub add_in_table {
	my ($dbh1, $name, $text) = @_;
	if ($name eq "user") {
		my $counter;
		my $tmp1 = "insert into user (first_name, last_name) values (";
		my $tmp = $tmp1;
		while ($text =~ /\d+\s(\D+)\s(\D+)\s/g) {
			$tmp .= "'$1', '$2'), (";
			$counter++;
			if ($counter % 50000 == 0) {
				substr($tmp, (length($tmp) - 3), 3, "");
				$dbh1->prepare($tmp)->execute();
				$dbh1->commit();
				$tmp = $tmp1;
				$counter = 0;
			}
		}
		unless ($tmp eq $tmp1) {
			substr($tmp, (length($tmp) - 3), 3, "");
			$dbh1->prepare($tmp)->execute();
			$dbh1->commit();
		}
	} else {
		my $counter;
		my $tmp1 = "insert into user_relation (user_id, friend_id) values (";
		my $tmp = $tmp1;
		while ($text =~ /(\d+)\s(\d+)\s/g) {
			$tmp .= "'$1', '$2'), (";
			$counter++;
			if ($counter == 50000) {
				substr($tmp, (length($tmp) - 3), 3, "");
				$dbh1->prepare($tmp)->execute();
				$tmp = $tmp1;
				$dbh1->commit();
				$counter = 0;
			} 
		}
		unless ($tmp eq $tmp1) {
			substr($tmp, (length($tmp) - 3), 3, "");
			$dbh1->prepare($tmp)->execute();
			$dbh1->commit();
		}
	}
}

sub create_table {
	my ($dbh1, $name)  = @_;
	if ($name eq "user") {
		$dbh1->prepare("create table user (id serial, first_name character varying(255), last_name character varying(255)) charset utf8")->execute;
	} else {
		$dbh1->prepare("create table user_relation (id serial, user_id integer, friend_id integer) charset utf8")->execute;
	}
	$dbh1->commit();
}

sub drop_table {
	my ($dbh1, $name)  = @_;
	if ($name eq "user") {
		$dbh1->prepare("drop table user")->execute;
	} else {
		$dbh1->prepare("drop table user_relation")->execute;
	}
	$dbh1->commit();
}


my $db_name = 'SocialNetwork';
my $user_name = 'willardgibbs';
my $password = 'm5vikhee';

my $dbh = DBI->connect("dbi:mysql:dbname=$db_name", $user_name, $password, {AutoCommit => 0, RaiseError => 1});

drop_table($dbh, "user");
create_table($dbh, "user");

drop_table($dbh, "user_relation");
create_table($dbh, "user_relation");

add_in_table($dbh, "user", read_zip("etc/user.zip"));
#select10($dbh, "user");
print "The Database user are created\n";

add_in_table($dbh, "user_relation", read_zip("etc/user_relation.zip"));
#select10($dbh, "user_relation");
print "The Database user_relation are created\n";

1;