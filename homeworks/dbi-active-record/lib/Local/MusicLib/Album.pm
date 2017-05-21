package Local::MusicLib::Album;

use strict;
use warnings;

use DBI::ActiveRecord;
use Local::MusicLib::DB::mysql;

use Local::MusicLib::Serializers qw(serializer_date deserializer_date serializer_time deserializer_time);
use Mouse::Util::TypeConstraints;

enum 'TypeEnum' => qw(single soundtrack compilation regular);

no Mouse::Util::TypeConstraints;

db "Local::MusicLib::DB::mysql";

table 'albums';

has_field id => (
    isa => 'Int',
    auto_increment => 1,
    index => 'primary'
);

has_field name => (
    isa => 'Str',
    index => 'common',
    default_limit => 100
);

has_field create_time => (
    isa => 'DateTime',
    serializer => \&serializer_date,
    deserializer => \&deserializer_date
);

has_field artist_id => (
    isa => 'Int',
    index => 'common',
    default_limit => 100
);

has_field type => (
    isa => 'Str',
    index => 'common',
    default_limit => 100,
    isa => 'TypeEnum'
);

has_field year => (
    isa => 'Int'
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;