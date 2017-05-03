use AnyEvent::HTTP;
use AnyEvent::Socket;
use DDP;

my $die;

tcp_server "127.0.0.1", 1234, sub {
	my $c = shift;
	$c->autoflush(1);
	while (<$c>) {
		$url = $1 if ($_ =~ /URL (.+)\n/);
		if ($_ eq "HEAD\n") {
			http_request 
				HEAD => $url,
				timeout => 10,
				sub {
					my ($body, $hdr) = @_;
					print "HEAD OK\n";
					p $hdr;
				};
		}
		if ($_ eq "GET\n") {
			http_request 
				GET => $url,
				timeout => 10,
				sub {
					my ($body, $hdr) = @_;
					print "GET OK\n";
					p $body;
				};
		}
		if ($_ eq "FIN") {
			$die = 1;
		}
	}
};

AE::cv->recv;
