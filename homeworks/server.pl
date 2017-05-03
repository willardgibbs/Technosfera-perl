use Socket ':all';
use AnyEvent::HTTP;
use DDP;

socket my $s, AF_INET, SOCK_STREAM, IPPROTO_TCP;

my $port = 1234;

my $url;

bind $s, sockaddr_in($port, INADDR_ANY);

listen $s, SOMAXCONN;

while (my $peer = accept my $c, $s) {
	$c->autoflush(1);
	while (<$c>) {
		$url = $1 if ($_ =~ /URL (.+)\n/);
		if ($_ eq "HEAD\n") {
			http_request 
				HEAD => $url,
				timeout => 10,
				sub {
					my ($body, $hdr) = @_;
					p $hdr;
					if ($hdr->{Status} == 200) {
						print {$c} "OK\n";
					} else {
						print {$c} $hdr->{Status}, "\n";
					}
				};
		}
		print {$c} "OK GET\n" if $_ eq "GET\n";
		die if $_ eq "FIN";
	}
}