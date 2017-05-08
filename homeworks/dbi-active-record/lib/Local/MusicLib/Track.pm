package Local::MusicLib::Track;

use DBI::ActiveRecord;
use Local::MusicLib::DB::mysql;

use DateTime;

db "Local::MusicLib::DB::mysql";

table 'tracks';

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

has_field extension => (
    isa => 'Str',
    serializer => \&serializer_time,
    deserializer => \&deserializer_time,
);

has_field create_time => (
    isa => 'DateTime',
    serializer => \&serializer_date,
    deserializer => \&deserializer_date,
);

has_field album_id => (
    isa => 'Int',
    index => 'common',
    default_limit => 100,
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;