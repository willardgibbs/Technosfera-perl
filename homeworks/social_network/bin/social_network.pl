use strict;
use warnings;

use DDP;
use Archive::Zip;
use Getopt::Long;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Local::DB;
use Local::User;
use Local::Relation;
use Local::SocialNetwork

our $VERSION = '1.00';

# Написать программу `bin/social_network.pl`, позволяющую получить следующую информацию:
#  * Общий список друзей для двух заданных пользователей
#  * Список пользователей, у которых нет друзей
#  * Количество рукопожатий между двумя заданными пользователями. 
#  Более формально: требуется найти длину кратчайшего пути 
#  между заданными двумя пользователями на графе дружбы социльной сети. 

my @flag_friends;
my $flag_no_friends = "";
my @flag_handshakes;

GetOptions ("friends=i{2}"   => \@flag_friends,
			"no_friends"   => \$flag_no_friends,
			"handshakes=i{2}"   => \@flag_handshakes) or die("Error in command line arguments\n");

my $db_name = 'SocialNetwork';
my $user_name = 'willardgibbs';
my $password = 'm5vikhee';

my $dbh = Local::DB->connect_to_mysql($db_name, $user_name, $password);

if (@flag_friends) {
	my $friends = Local::SocialNetwork::friends($dbh, $flag_friends[0], $flag_friends[1]);
	p $friends;
}

if ($flag_no_friends) {
	my $no_friends = Local::SocialNetwork::no_friends($dbh);
	if (@$no_friends) {
		p $no_friends;
	} else {
		print "Everybody have friend!\n";
	}
	
}

if (@flag_handshakes) {
	my $number_handshakes = Local::SocialNetwork::number_handshakes($dbh, $flag_handshakes[0], $flag_handshakes[1]);
	p $number_handshakes;
}