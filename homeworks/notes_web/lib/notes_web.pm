package notes_web;
use Dancer2;
use Dancer2::Plugin::Database;
use Dancer2::Plugin::CSRF;
use Digest::CRC qw/crc64/;
use DDP;
our $VERSION = '0.1';


our $upload_dir = "notes";

sub get_upload_dir {
	return config->{appdir} . "/" . $upload_dir . "/";
}

sub make_id {
	my $name = shift;
	my $str .= $_ for @_;
	# my $sth;
	# if ($name eq "notes") {
	#  	$sth = database->prepare("INSERT INTO $name (id, title, text) VALUES (cast(? as signed), ?, ?)"); # whoseeit
	# } else {
	# 	$sth = database->prepare("INSERT INTO $name (id, title, text) VALUES (cast(? as signed), ?, ?)");
	# }
	my $id = "";
	my $try_count = 10;
	while (!$id) {
		database->do("DELETE FROM $notes WHERE id = cast(& as signed)", (), [$id]) if $id;
		unless (--$try_count) {
			$id = undef;
			last;
		}
		$id = crc64($str.$id);
		# $id = undef unless $sth->execute($str.$id); #, $friends
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
	session('user') or redirect('/login');
    redirect('/main_page');
};

get '/main_page' => sub {
	session('user') or redirect('/login');
	template 'make_page' => { 'title' => 'notes_web' };
};

get '/make_notes' => sub {
	session('user') or redirect('/login');
    template 'make_notes' => { 'title' => 'notes_web' };
};

post '/make_notes' => sub {
	session('user') or redirect('/login');
	my $title = params->{title};
	my $text = params->{text};
	my $friends = params->{users};

	my $sth = database->prepare("INSERT INTO $name (id, title, text) VALUES (cast(? as signed), ?, ?)"); # whoseeit
	my $id = make_id($title, $text);
	$sth->execute($id, $title, $text);
	print_in_file("/notes/", $id, $title, $text, $friends);
	redirect "/". unpack 'H*', pack 'Q', $id;
};

get '/last_notes' => sub {
	session('user') or redirect('/login');
	template 'last_notes' => { 'title' => 'last_notes' };
};

get '/login' => sub {
	set layout => 'main';
	template login => { csrf_token => get_csrf_token() };
};


post '/login' => sub {
	my $username = params->{username};
	my $password = params->{password};
	# my @err = ();
	# push @err, 'Login or password is empty' if (!$username or !$password);
	# push @err, 'Login or password is too large' if (length($username) > 255 or length($password) > 255); 
	# push @err, 'Login and password can contain only english letters and numbers' if $username =~ /\W/ or $password =~ /\W/;		
	my $sel = database->prepare('SELECT cast(id as unsigned) as id, username, password FROM users where username = (?)');
	my $ins = database->prepare('INSERT INTO users (username, password) VALUES ((?),(?))');
	$sel->execute($username);
	my $sel_res = $sel->fetchrow_hashref();
	unless (exists $sel_res->{id}) {
		$ins->execute($username, $password);
		$sel->execute($username);
		$sel_res = $sel->fetchrow_hashref();
		session user => $sel_res->{id};
		print STDERR "\n\nd1=$sel_res->{'cast(id as unsigned)'}\t$sel_res->{username}\ts1=",session('user'),"\n\n";
		redirect '/main_page';
	} else {
		push @err, 'Wrong password' if $password ne $sel_res->{password};
	}
	return template login => {err => \@err} if (@err);
	session user => $sel_res->{id};
	print STDERR "\n\nd2=$sel_res->{id}\ts2=",session('user'),"\n\n";
	redirect '/main_page'; 
};

hook before => sub {
	warn "\n\n".param('csrf_token')."\n\n";
	if ( request->is_post() ) {
		my $csrf_token = param('csrf_token');
		print $csrf_token;
		if ( !$csrf_token || !validate_csrf_token($csrf_token) ) {
			redirect '/';
		}
	}

};

true;
