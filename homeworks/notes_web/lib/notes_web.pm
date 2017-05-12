package notes_web;

use Dancer2;
use Dancer2::Plugin::Database;
use Dancer2::Plugin::CSRF;
use Digest::CRC qw/crc64/;
use DDP;

our $VERSION = "0.1";


our $upload_dir = "notes";

get "/" => sub {
    redirect("/main_page");
};

get "/main_page" => sub {
	template "main_page" => { title => "notes_web" };
};

get "/make_notes" => sub {
    template "make_notes" => { title => "notes_web", csrf_token => get_csrf_token()};
};

post "/make_notes" => sub {
	my $title = params->{title};
	my $text = params->{text};
	my @friends_id = split / /, params->{users};
	my $create_time = time;
	my $sth = database->prepare("INSERT INTO notes (title, text, create_time, user_id) VALUES (?, ?, ?, ?)");
	$sth->execute($title, $text, $create_time, session("user"));
	my $sth_1 = database->prepare("SELECT id FROM notes WHERE title = ? AND text = ? AND create_time = ? AND user_id = ?");
	$sth_1->execute($title, $text, $create_time, session("user"));
	my $id = $sth_1->fetchrow_hashref()->{id};
	my $sth_2 = database->prepare("INSERT INTO friends (notes_id, user_id) VALUES (?, ?)");
	$sth_2->execute($id, $_) for @friends_id;
	redirect "/notes_". $id;
};

get qr{/note_(\d+)$} => sub { #что-то не так
	my $id = splat;
	my $sth_1 = database->prepare('SELECT user_id FROM friends WHERE notes_id = ?');
	$sth_1->execute($id);
	my $sth = database->prepare('SELECT create_time, title, text, user_id FROM notes WHERE id = ?');
	$sth->execute($id);
	my $sel_res = $sth->fetchrow_hashref();
	my $flag;
	$flag = 1 if (session("user") == $sel_res->{user_id});
	unless ($flag) {
		while (my $tmp = $sth_1->fetchrow_arrayref()) {
			$flag = 1 if $tmp == session('user');
		}
	}
	return template 'note' => {error => "Permission denied"} unless $flag; 
	return template 'note' => {text => $sel_res->{text},  create_time => $sel_res->{create_time}, title => $sel_res->{title}};
};

get "/last_notes" => sub {
	my $notes_select = database->prepare("SELECT create_time, title, text FROM notes WHERE user_id = ? ORDER BY create_time");
	$notes_select->execute(session("user"));
	my @notes;
	while (my $buff = $notes_select->fetchrow_hashref()) {
		# $buf->{create_time};
		push @notes, $buff;
	}
	return template 'last_notes.tt' => {notes => \@notes, csrf_token => get_csrf_token()};
};

get "/sign_in" => sub {
	template sign_in => { csrf_token => get_csrf_token() };
};

post "/sign_in" => sub {
	my $username = params->{username};
	my $password = params->{password};
	my $sel = database->prepare("SELECT id FROM users WHERE username = ? AND password = ?");
	$sel->execute($username, $password);
	my $exist = $sel->fetchrow_arrayref();
	if (defined $exist) {
		session user => $exist->[0];
		redirect "/main_page";
	} else {
		template sign_in => {errors => "Wrong login or password"};
	}
};

get "/login" => sub {
	set layout => "main";
	template login => { csrf_token => get_csrf_token() };
};

post "/login" => sub {
	my $username = params->{username};
	my $password = params->{password};
	my @errors_auth = ();
	push @errors_auth, "Login or password is null" if (!$username or !$password);
	push @errors_auth, "Login or password is too large" if (length($username) > 255 or length($password) > 255); 
	push @errors_auth, "Login and password can contain only english letters and numbers" if $username =~ /\W/ or $password =~ /\W/;
	my $sel = database->prepare("SELECT id FROM users WHERE username = (?)");
	$sel->execute($username);
	my $exist = $sel->fetchrow_arrayref();
	if (defined $exist) {
		push @errors_auth, "This login alredy exist";
	} else {
		database->prepare("INSERT INTO users (username, password) VALUES ((?),(?))")->execute($username, $password);
		$sel->execute($username);
		session user => $exist->[0];
	}
	return template login => {errors_auth => \@errors_auth} if (@errors_auth);
	redirect "/main_page";
};

hook before => sub {
	redirect '/sign_in' if !session('user') and request->path !~ /^\/sign_in$/ and request->path !~ /^\/login$/;
	if ( request->is_post() ) {
		my $csrf_token = param('csrf_token');
		print $csrf_token;
		if ( !$csrf_token || !validate_csrf_token($csrf_token) ) {
			redirect '/';
		}
	}

};

true;