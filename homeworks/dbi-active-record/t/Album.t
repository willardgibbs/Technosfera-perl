use strict;
use warnings;

#Написать скрипт для тестирования музыкально библиотеки. Скрипт должен проверить для каждого объекта (трек, альбом, артист) операции вставки, выборки, обновления и удаления. Возмножно вас ждет сюрприз.

use Local::MusicLib::Album;

my $date = DateTime->new (
	year       => 2017,
	month      => 5,
	day        => 1,
	hour       => 13,
	minute     => 15,
	second     => 17,
);

my $track = Local::MusicLib::Artist->new(
	name => 'Eric Clapton',
	country => 'en',
	create_time => $date,
);

sub insert_test {

}

sub update_test {

}

sub select_test {

}

sub delete_test {
	
}