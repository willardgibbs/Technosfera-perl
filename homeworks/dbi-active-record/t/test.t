use strict;
use warnings;
use Test::Simple tests => 3;

#Написать скрипт для тестирования музыкально библиотеки. Скрипт должен проверить для каждого объекта (трек, альбом, артист) операции вставки, выборки, обновления и удаления. Возмножно вас ждет сюрприз.

use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::MusicLib::Track;
use Local::MusicLib::Album;
use Local::MusicLib::Artist;

my $date = DateTime->new (
	year       => 2017,
	month      => 5,
	day        => 1,
	hour       => 13,
	minute     => 15,
	second     => 17,
);
my $track = Local::MusicLib::Track->new (
	album_id => 1,
	name => 'Layla',
	extension => '00:07:11',
	create_time => $date
);
my $album = Local::MusicLib::Album->new (
	artist_id => 1,
	name => 'Layla and Other Assorted Love Songs',
	year => 1970,
	type => 'soundtrack',
	create_time => $date
);
my $artist = Local::MusicLib::Artist->new (
	name => 'Eric Clapton',
	country => 'en',
	create_time => $date
);

$artist->insert;
$album->insert;
$track->insert;

$sel_track = Local::MusicLib::Track->select_by_id($track->id);
$sel_album = Local::MusicLib::Album->select_by_id($album->id);
$sel_artist = Local::MusicLib::Artist->select_by_id($artist->id);

p $sel_track;
p $sel_album;
p $sel_artist;

$track->extension('00:05:04');
$track->name("What'd I Say");

$album->type('single');
$album->name("What'd I Say");

$artist->name("Ray Charles");

$track->update;
$album->update;
$artist->update;

$sel_changed_track = Local::MusicLib::Track->select_by_id($track->id);
$sel_changed_album = Local::MusicLib::Album->select_by_id($album->id);
$sel_changed_artist = Local::MusicLib::Artist->select_by_id($artist->id);

p $selected_track;
p $selected_album;
p $selected_artist;

ok($track->delete, "delete track");
ok($album->delete, "delete album");
ok($artist->delete, "delete artist");



1;