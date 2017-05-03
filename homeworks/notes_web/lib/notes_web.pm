package notes_web;
use Dancer2;

our $VERSION = '0.1';

get '/' => sub {
    template 'index' => { 'title' => 'notes_web' };
};

get '/auth' => sub {
	my $username;
	my $password;
	  
};

true;
