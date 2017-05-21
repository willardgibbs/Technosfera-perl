package Local::Relation;

use FindBin;
use lib "$FindBin::Bin/../lib";

use strict;
use warnings;
use DDP;

use Exporter 'import';

sub new {
	my ($class, $user_id, $friend_id) = @_;
	my %params = (
		user_id => $user_id,
		friend_id => $friend_id,
	);
	return bless \%params, $class;
}
our @EXPORT_OK = qw(new);
1;