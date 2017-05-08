package Local::MusicLib::DB::mysql;
use Mouse;
extends 'DBI::ActiveRecord::DB::mysql';

sub _build_connection_params {
    my ($self) = @_;
    return [
        'dbi:mysql:dbname=/tmp/muslib.db',
        'willardgibbs',
        'm5vkhee',
        {
			"RaiseError" => 1, 
			"AutoCommit" => 0, 
			"mysql_enable_utf8" => 1,
        }
    ];
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;