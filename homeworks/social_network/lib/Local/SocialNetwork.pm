package Local::SocialNetwork;

use strict;
use warnings;
#!usr/bin/perl
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
		while (my ($lol, $kek) = $tmp->fetchrow_array()) {
			print "$lol, $kek\n";
		}
	} else {
		my $tmp = $dbh1->prepare("select user_id, friend_id from user_relation limit 10");
		$tmp->execute();
		while (my ($lol, $kek) = $tmp->fetchrow_array()) {
			print "$lol, $kek\n";
		}
	}
}

sub add_in_table {
	my ($dbh1, $name, $text) = @_;
	if ($name eq "user") {
		my $arrref = [];
		while ($text =~ /\d+\s(\D+)\s(\D+)\s/g) {
			push @$arrref, "'$1', '$2'";
		}
		my $tmp = join("), (", @$arrref);
		$dbh1->prepare("insert into user (first_name, last_name) values (".$tmp.")")->execute();
	} else {
		#my $arrref = [];
		while ($text =~ /(\d+)\s(\d+)\s/g) {
			#$dbh1->prepare("insert into user_relation (user_id, friend_id) values (?, ?)")->execute($1, $2);
			push @$arrref, "$1, $2";
		}
		my $tmp = join("), (", @$arrref);
		$dbh1->prepare("insert into user_relation (user_id, friend_id) values (".$tmp.")")->execute();
	}
}

sub create_table {
	my ($dbh1, $name)  = @_;
	if ($name eq "user") {
		$dbh1->prepare("create table user (id serial, first_name character varying(255), last_name character varying(255))")->execute;
	} else {
		$dbh1->prepare("create table user_relation (id serial, user_id integer, friend_id integer)")->execute;
	}
}

sub drop_table {
	my ($dbh1, $name)  = @_;
	if ($name eq "user") {
		$dbh1->prepare("drop table user")->execute;
	} else {
		$dbh1->prepare("drop table user_relation")->execute;
	}
}


my $db_name = 'SocialNetwork';
my $user_name = 'willardgibbs';
my $password = 'm5vikhee';

my $dbh = DBI->connect("dbi:mysql:dbname=$db_name", $user_name, $password, {AutoCommit => 0, RaiseError => 1});

drop_table($dbh, "user");
create_table($dbh, "user");

drop_table($dbh, "user_relation");
create_table($dbh, "user_relation");

# my $user_text = read_zip("etc/user.zip");
add_in_table($dbh, "user", read_zip("etc/user.zip"));
#select10($dbh, "user");
print "The Database user are created\n";

# my $user_relation_text = read_zip("etc/user_relation.zip");
add_in_table($dbh, "user_relation", read_zip("etc/user_relation.zip"));
#select10($dbh, "user_relation");
print "The Database user_relation are created\n";

$dbh->commit();

1;