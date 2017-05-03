use Socket ':all';

socket my $s, AF_INET, SOCK_STREAM, IPPROTO_TCP;

my $host = 'localhost'; my $port = 1234;

my $addr = gethostbyname $host;

my $sa = sockaddr_in($port, $addr);

connect($s, $sa);

send $s, "URL https://mail.ru\n", 0;
send $s, "HEAD\n", 0;
send $s, "GET\n", 0;
send $s, "FIN\n", 0;

while () {
	my $r = recv $s, my $buf, 1024, 0;
	if (defined $r) {
		last unless length $buf;
		print $buf;
	}
}
