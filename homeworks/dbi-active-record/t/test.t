use strict;
use warnings;
use Test::Simple tests => 9;

#Написать скрипт для тестирования музыкально библиотеки. Скрипт должен проверить для каждого объекта (трек, альбом, артист) операции вставки, выборки, обновления и удаления. Возмножно вас ждет сюрприз.

use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::MusicLib::Track;
use Local::MusicLib::Album;
use Local::MusicLib::Artist;

use DDP;

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

my $sel_track = Local::MusicLib::Track->select_by_id($track->id);
my $sel_album = Local::MusicLib::Album->select_by_id($album->id);
my $sel_artist = Local::MusicLib::Artist->select_by_id($artist->id);


ok($sel_track->album_id == 1 && $sel_track->name eq 'Layla' && $sel_track->extension eq "0:7:11", "new, insert, select for tracks");
ok($sel_album->artist_id == 1 && $sel_album->name eq 'Layla and Other Assorted Love Songs' && $sel_album->year == 1970 && $sel_album->type eq 'soundtrack', "new, insert, select for album");
ok($sel_artist->name eq 'Eric Clapton' && $sel_artist->country eq "en", "new, insert, select for artist");

$track->extension('00:05:04');
$track->name("What'd I Say");

$album->type('single');
$album->name("What'd I Say");

$artist->name("Ray Charles");

$track->update;
$album->update;
$artist->update;

my $sel_changed_track = Local::MusicLib::Track->select_by_id($track->id);
my $sel_changed_album = Local::MusicLib::Album->select_by_id($album->id);
my $sel_changed_artist = Local::MusicLib::Artist->select_by_id($artist->id);

ok($sel_changed_track->album_id == 1 && $sel_changed_track->name eq "What'd I Say" && $sel_changed_track->extension eq "0:5:4", "change track");
ok($sel_changed_album->artist_id == 1 && $sel_changed_album->name eq "What'd I Say" && $sel_changed_album->year == 1970 && $sel_changed_album->type eq 'single', "change for album");
ok($sel_changed_artist->name eq 'Ray Charles' && $sel_changed_artist->country eq "en", "change for artist");


ok($track->delete, "delete track");
ok($album->delete, "delete album");
ok($artist->delete, "delete artist");



1;