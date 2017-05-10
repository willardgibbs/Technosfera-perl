use strict;
use warnings;

#Написать скрипт для тестирования музыкально библиотеки. Скрипт должен проверить для каждого объекта (трек, альбом, артист) операции вставки, выборки, обновления и удаления. Возмножно вас ждет сюрприз.

use Local::MusicLib::Track;

my $date = DateTime->new (
	year       => 2017,
	month      => 5,
	day        => 1,
	hour       => 13,
	minute     => 15,
	second     => 17,
);

my $track = Local::MusicLib::Album->new(
	artist_id => 1,
	name => 'Layla and Other Assorted Love Songs',
	type => 'compilation',
	create_time => $date,
	year => 1970,
);

sub select_test {
	
}

sub insert_test {

}

sub update_test {

}

sub delete_test {

}