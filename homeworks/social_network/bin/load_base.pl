use strict;
use warnings;

use DDP;
use DBD::mysql;
use Data::Dumper;
use JSON::XS;
use Archive::Zip;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Local::DB;
use Local::User;
use Local::Relation;
use Local::SocialNetwork;

our $VERSION = '1.00';

sub read_zip {
	my $file = shift;
	my @arr = Archive::Zip->new($file)->members();
	return $arr[0]->contents();
}

my $db_name = 'SocialNetwork';
my $user_name = 'willardgibbs';
my $password = 'm5vikhee';

my $dbh = Local::DB->connect_to_mysql($db_name, $user_name, $password);

Local::DB::drop_table($dbh, "user");
Local::DB::create_table($dbh, "user");

Local::DB::drop_table($dbh, "user_relation");
Local::DB::create_table($dbh, "user_relation");

Local::DB::add_in_table_users($dbh, read_zip("etc/user.zip"));
print "The Database user are created\n";

Local::DB::add_in_table_relations($dbh, read_zip("etc/user_relation.zip"));
print "The Database user_relation are created\n";
