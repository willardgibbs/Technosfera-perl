package Local::MusicLib::Serializers;

use DateTime;

sub serializer_date {
	$_[0]->format_cldr("YYYY-MM-dd HH:mm:ss");
}

sub deserializer_date {
    my $string = shift;
	$string =~ /^(\d+)-(\d+)-(\d+)\s(\d+):(\d+):(\d+)$/;
	return DateTime->new (
		year => $1,
		month => $2,
		day => $3,
		hour => $4,
		minute => $5,
		second => $6,
	);
}

sub serializer_time {
	my $time = shift;
	$time =~ /^(\d+):(\d+):(\d+)$/;
	return $1*3600 + $2*60 + $3;
}

sub deserializer_time {
	my $sec = shift;
	my $h = int($sec / 3600);
	my $m = int(($sec - $h*3600) / 60);
	my $s = $sec - $h*3600 - $m * 60;
	return join ":", $h, $m, $s;
}

@EXPORT_OK = qw(serializer_date deserializer_date serializer_time deserializer_time);