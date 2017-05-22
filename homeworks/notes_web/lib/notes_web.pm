package notes_web;

use Dancer2;
use Dancer2::Plugin::Database;
use Dancer2::Plugin::CSRF;
use HTML::Entities;
use Digest::CRC qw/crc64/;
use DDP;

our $upload_dir = "notes";
our @errors_auth;

hook before => sub {
	redirect '/sign_in' if !session('user_id') and request->path !~ /^\/sign_in$/ and request->path !~ /^\/login$/;
	if ( request->is_post() ) {
		my $csrf_token = param('csrf_token');
		print $csrf_token;
		if ( !$csrf_token || !validate_csrf_token($csrf_token) ) {
			redirect '/';
		}
	}
};

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
	my $title = encode_entities(params->{title}, '<>&"');
	my $text = encode_entities(params->{text}, '<>&"');
	my @friends_id = split /,\s/, encode_entities(params->{users}, '<>&"');
	my $create_time = time;
	my $sth = database->prepare("INSERT INTO notes (title, text, create_time, user_id) VALUES (?, ?, ?, ?)");
	my $sth_1 = database->prepare("SELECT id FROM notes WHERE title = ? AND text = ? AND create_time = ? AND user_id = ?");
	my $sth_2 = database->prepare("INSERT INTO friends (notes_id, user_id) VALUES (?, ?)");
	my $sth_3 = database->prepare("SELECT id FROM users WHERE username = ?");

	$sth->execute($title, $text, $create_time, session("user_id"));
	$sth_1->execute($title, $text, $create_time, session("user_id"));

	my $id = $sth_1->fetchrow_hashref()->{id};
	
	for (@friends_id) {
		$sth_3->execute($_);
		$sth_2->execute($id, $sth_3->fetchrow_arrayref()->[0]);
	}
	database->commit;
	redirect "/note_". $id;
};

get '/note_*' => sub {
	my @errors;
	my $sth_1 = database->prepare('SELECT user_id FROM friends WHERE notes_id = ?');
	my $sth = database->prepare('SELECT create_time, title, text, user_id FROM notes WHERE id = ?');
	my $sel = database->prepare("SELECT username FROM users WHERE id = (?)");

	my ($tmp) = splat;
	$tmp =~ /^(\d+)$/;
	my $id = $1;
	$sth_1->execute($id);
	$sth->execute($id);

	my $sel_res = $sth->fetchrow_hashref();
	my $friends = [];
	while (my $tmp = $sth_1->fetchrow_arrayref()) {
		push @$friends, $tmp->[0]; 
	}
	
	my $friends_name;

	unless ($sel_res) {
		push @errors, "Note doesn't exist";
		return template errors => {errors => \@errors};
	}
	
	my $flag;
	$flag = 1 if session("user_id") == $sel_res->{user_id};
	for (@$friends) {
		$flag = 1 if $_ == session('user_id');
	}
	push @errors, "Permission denied" unless defined $flag;
	return template errors => {errors => \@errors} if @errors;

	for (@$friends) {
		$sel->execute($_);
		push @$friends_name, $sel->fetchrow_arrayref()->[0];
	}
	$sel->execute($sel_res->{user_id});
	my $username_ex = $sel->fetchrow_arrayref()->[0];
	database->commit;
	template note => {text => $sel_res->{text},  create_time => $sel_res->{create_time}, title => $sel_res->{title}, friends => $friends_name, username => $username_ex};
};

get "/last_notes" => sub {
	my $notes_select = database->prepare("SELECT create_time, title, text FROM notes WHERE user_id = ? ORDER BY create_time");
	$notes_select->execute(session("username"));
	my @notes;
	while (my $buff = $notes_select->fetchrow_hashref()) {
		push @notes, $buff;
	}
	database->commit;
	template 'last_notes.tt' => {notes => \@notes, csrf_token => get_csrf_token()};
};

get "/sign_in" => sub {
	template sign_in => { csrf_token => get_csrf_token() };
};

get "/login" => sub {
	template login => { csrf_token => get_csrf_token() };
};

post "/sign_in" => sub {
	my $username = encode_entities(params->{username}, '<>&"');
	my $password = encode_entities(params->{password}, '<>&"');

	my $sel = database->prepare("SELECT id FROM users WHERE username = ? AND password = ?");
	$sel->execute($username, $password);
	my $exist = $sel->fetchrow_hashref();
	database->commit;
	if (defined $exist) {
		session username => $username;
		session user_id => $exist->{id};
		redirect "/main_page";
	} else {
		my @errors;
		push @errors, "Wrong login or password";
		template errors => {errors => \@errors};
	}
};

post "/login" => sub {
	my $username = encode_entities(params->{username}, '<>&"');
	my $password = encode_entities(params->{password}, '<>&"');

	my @errors_auth = ();
	push @errors_auth, "Login or password is null" if (!$username or !$password);
	push @errors_auth, "Login or password is too large" if (length($username) > 255 or length($password) > 255); 
	push @errors_auth, "Login and password can contain only english letters and numbers" if $username =~ /\W/ or $password =~ /\W/;

	my $sel = database->prepare("SELECT id FROM users WHERE username = (?)");
	$sel->execute($username);
	push @errors_auth, "This login alredy exist" if defined $sel->fetchrow_arrayref();
	
	if (@errors_auth) {
		database->commit;
		template errors => {errors => \@errors_auth};
	} else {
		database->prepare("INSERT INTO users (username, password) VALUES ((?),(?))")->execute($username, $password);
		database->commit;
		redirect "/sign_in";	
	}
};

get '/logout' => sub {
    context->destroy_session;
    redirect '/sign_in';
};

true;