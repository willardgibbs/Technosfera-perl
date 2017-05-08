package Local::MusicLib::Album;

use DBI::ActiveRecord;
use Local::MusicLib::DB::mysql;

use Local::MusicLib::DB::Serializers;

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

has_field create_time => (
    isa => 'DateTime',
    serializer => \&serializer_date,
    deserializer => \&deserializer_date,
);

has_field artist_id => (
    isa => 'Int',
    index => 'common',
    default_limit => 100,
);

enum 'TypeEnum' => qw(single soundtrack compilation regular album);

has_field type => (
    #isa => 'Str',
    index => 'common',
    default_limit => 100,
    isa => 'TypeEnum',
);

has_field year => (
    isa => 'Int',
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;