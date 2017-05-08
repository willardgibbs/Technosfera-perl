package notes_web;
use Dancer2;
use Dancer2::Plugin::Database;
use Digest::CRC qw/crc64/;
our $VERSION = '0.1';


our $upload_dir = "notes";

sub get_upload_dir {
	return config->{appdir} . "/" . $upload_dir . "/";
}

sub make_id {
	my $str .= $_ for @_;
	my $id = "";
	my $try_count = 10;
	while (!$id) {
		database->do("DELETE FROM notes WHERE id = cast(& as signed)", (), [$id]) if $id;
		unless (--$try_count) {
			$id = undef;
			last;
		}
		$id = crc64($str.$id);
		$id = undef unless $sth->execute($str.$id); #, $friends
	}
	die "Try latter" unless $id;
	return $id;
}

sub print_in_file {
	my $dir = shift;
	my $id = shift;
	my $fh;
	die "Interna error:".$! unless open($fh, '>', get_upload_dir.$dir.$id);
	print $fh join(" ", @_);
	close($fh);
}

get '/' => sub {
    template 'index' => { 'title' => 'notes_web' };
};

post '/' => sub {
	my $title = params->{title};
	my $text = params->{text};
	my $friends = params->{users};
	my $sth = database->prepare("INSERT INTO notes (id, title, text) VALUES (cast(? as signed), ?, ?)"); # whoseeit
	
	my $id = make_id($title, $text);
	print_in_file("/notes/", $id, $title, $text, $friends);
	redirect "/". unpack 'H*', pack 'Q', $id;
};

post '/auth' => sub {
	my $username = params->{username};
	my $password = params->{password};
	my $sth = database->prepare("INSERT INTO users (id, username, password) VALUES (cast(? as signed), ?, ?)");
	my $id = make_id($username, $password);
	print_in_file("/users/", $id, $username, $password);
	redirect "/". unpack 'H*', pack 'Q', $id;  
};

true;
