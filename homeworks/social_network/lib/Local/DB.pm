package Local::DB;

use FindBin;
use lib "$FindBin::Bin/../lib";

use DBD::mysql;
use Exporter 'import';
use Local::User;
use Local::Relation;


sub connect_to_mysql {
	my ($self, $db_name, $user_name, $password) = @_;
	return DBI->connect("dbi:mysql:dbname=$db_name", $user_name, $password, {AutoCommit => 1, RaiseError => 1});
}

sub insert_users {
	my ($dbh, $users) = @_;
	my $request = "insert into user (id, first_name, last_name) values (";
	$request .= "'$_->{id}', '$_->{first_name}', '$_->{last_name}'), (" for @$users; 
	substr($request, (length($request) - 3), 3, "");
	$dbh->prepare($request)->execute();
}

sub insert_relations {
	my ($dbh, $relations) = @_;
	my $request = "insert into user_relation (user_id, friend_id) values (";
	$request .= "'$_->{user_id}', '$_->{friend_id}'), (" for (@$relations);
	substr($request, (length($request) - 3), 3, "");
	$dbh->prepare($request)->execute();
}

sub create_table {
	my ($dbh, $name)  = @_;
	if ($name eq "user") {
		$dbh->prepare("create table user (id serial, first_name character varying(255), last_name character varying(255)) charset utf8")->execute();
	} elsif ($name eq "user_relation") {
		$dbh->prepare("create table user_relation (id serial, user_id integer, friend_id integer) charset utf8")->execute();
	}
}

sub drop_table {
	my ($dbh, $name)  = @_;
	$dbh->prepare("drop table $name")->execute();
}

sub select_id {
	my ($dbh, $id)  = @_;
	my $sth = $dbh->prepare("SELECT id, first_name, last_name FROM user WHERE id = (?)");
	$sth->execute($id);
	my $result = $sth->fetchrow_hashref();
	my $user = Local::User->new($result->{id}, $result->{first_name}, $result->{last_name});
	return $user;
}

# sub select_friends {
# 	my ($dbh, $ids) = @_;

# 	my @result;
# 	while (my $tmp = $sth->fetchrow_hashref()) {
# 		push @result, $tmp->{friend_id};
# 	}
# 	return \@result;
# }

sub add_in_table_users {
	my ($dbh, $text) = @_;
	my $users = [];
	while ($text =~ /(\d+)\s(\D+)\s(\D+)\s/g) {
		push @$users, Local::User->new($1, $2, $3);
		if (@$users % 50000 == 0) {
			insert_users($dbh, $users);
			$users = [];
		}
	}
 	insert_users($dbh, $users) if (@$users);
} 
sub add_in_table_relations {
	my ($dbh, $text) = @_;
	my $relations = [];
	while ($text =~ /(\d+)\s(\d+)\s/g) {
		push @$relations, Local::Relation->new($1, $2);
		if (@$relations % 50000 == 0) {
			insert_relations($dbh, $relations);
			$relations = [];
		}
	}
 	insert_relations($dbh, $relations) if (@$relations);
}

our @EXPORT_OK = qw(connect_to_mysql insert_users insert_relations create_table select_id add_in_table_relations add_in_table_users);

1;