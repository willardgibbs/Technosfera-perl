package Local::MusicLib::Artist;

use DBI::ActiveRecord;
use Local::MusicLib::DB::mysql;
use Local::MusicLib::Serializers;

db "Local::MusicLib::DB::mysql";

table 'album';

has_field id => (
    isa => 'Int',
    auto_increment => 1,
    index => 'primary',
);

has_field name => (
    isa => 'Str',
    index => 'common',
    default_limit => 100,
);

has_field country => (
    isa => 'Str',
);

has_field create_time => (
    isa => 'DateTime',
    serializer => \&serializer_date,
    deserializer => \&deserializer_date,
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;