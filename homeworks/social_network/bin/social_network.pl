#!/usr/bin/env perl

use strict;
use warnings;
use DDP;
use DBD::mysql;
use Data::Dumper;
use JSON::XS;

# Написать программу `bin/social_network.pl`, позволяющую получить следующую информацию:
#  * Общий список друзей для двух заданных пользователей
#  * Список пользователей, у которых нет друзей
#  * Количество рукопожатий между двумя заданными пользователями. 
#  Более формально: требуется найти длину кратчайшего пути 
#  между заданными двумя пользователями на графе дружбы социльной сети. 

my $db_name = 'SocialNetwork';
my $user_name = 'willardgibbs';
my $password = 'm5vikhee';

my $user_id_1 = 22;
my $user_id_2 = 13;

my $dbh = DBI->connect("dbi:mysql:dbname=$db_name", $user_name, $password, {AutoCommit => 0, RaiseError => 1});

my $friends = $dbh->prepare("SELECT user.first_name, user.last_name FROM user INNER JOIN (SELECT user_relation.friend_id FROM user_relation WHERE user_relation.user_id = $user_id_1) lol ON user.id = lol.friend_id INNER JOIN (SELECT user_relation.friend_id FROM user_relation WHERE user_relation.user_id = $user_id_2) kek ON user.id = kek.friend_id");
$friends->execute;
while (my ($lol, $kek) = $friends->fetchrow_array()) {
	print "$lol $kek\n";
}

my $no_friends = $dbh->prepare("SELECT user.first_name, user.last_name FROM user LEFT OUTER JOIN user_relation ON user.id = user_relation.friend_id");
$no_friends->execute;

while (my ($lol, $kek) = $no_friends->fetchrow_array()) {
	print "$lol $kek\n";
}


# SELECT
# 	first_name, last_name
# FROM 
# 	user 
# INNER JOIN 
# 	SELECT friend_id 
# 	FROM user_relation 
# 	WHERE user_id = $user_id_1
# ON user.id = friend_id
# INNER JOIN 
# 	SELECT friend_id 
# 	FROM user_relation 
# 	WHERE user_id = $user_id_2
# ON user.id = friend_id