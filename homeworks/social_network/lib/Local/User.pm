package Local::User;

use FindBin;
use lib "$FindBin::Bin/../lib";

use strict;
use warnings;
use DDP;

use Exporter 'import';

sub new {
	my ($class, $id, $first_name, $last_name) = @_;
	my %params = (
		first_name => $first_name,
		last_name => $last_name,
		id => $id	
	);
	return bless \%params, $class;
}

our @EXPORT_OK = qw(new);
1;