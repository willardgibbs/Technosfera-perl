package Local::SocialNetwork;

use strict;
use warnings;

use DDP;
use DBD::mysql;
use Data::Dumper;
use JSON::XS;
use Archive::Zip;
use Exporter 'import';

use FindBin;
use lib "$FindBin::Bin/../lib";

use Local::DB;
use Local::User;
use Local::Relation;

our $VERSION = '1.00';

sub friends {
	my ($dbh, $first_id, $second_id) = @_;
	my $friendsarr = [];
	my $sth = $dbh->prepare("SELECT friend_id FROM user_relation WHERE user_id IN (?, ?)");
	$sth->execute($first_id, $second_id);
	my $tmp = $sth->fetchall_arrayref();
	my $tmphash = {};
	$tmphash->{$_->[0]} = Local::DB::select_id($dbh, $_->[0]) for (@$tmp);
	push @$friendsarr, $tmphash->{$_} for keys %$tmphash;
	return $friendsarr;
}

sub no_friends {
	my ($dbh) = @_;
	my $no_friend_users = [];
	my $sth = $dbh->prepare("SELECT * FROM user WHERE id NOT IN (SELECT user_id FROM user_relation)");
	$sth->execute();
	while (my $tmp = $sth->fetchrow_hashref()) {
		push @$no_friend_users, Local::User->new($tmp->{id}, $tmp->{first_name}, $tmp->{last_name});
	}
	return $no_friend_users;
}

sub number_handshakes {
	my ($dbh, $first_id, $second_id) = @_;
	my $handshakes;
	my $request = "SELECT friend_id FROM user_relation WHERE user_id IN (";
	my $request1 = $request;
	my $flag = 1;
	my %friends;
	$friends{$first_id} = 1;
	while ($flag) {
		my $tmp;
		$request .= "'$_', " for keys %friends;
		substr($request, (length($request) - 2), 2, "");
		$request .= ")";
		my $sth = $dbh->prepare($request);
		$sth->execute();
		while (my $var = $sth->fetchrow_hashref()) {
			$tmp->{$var->{friend_id}} = 1;
			$flag = 0 if $var->{friend_id} == $second_id;
		}
		%friends = %$tmp;
		$request = $request1;
		$handshakes++;
	}
	return $handshakes;
}

our @EXPORT_OK = qw(friends no_friend number_handshakes);

1;