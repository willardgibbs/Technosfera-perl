use AnyEvent::Socket;

tcp_connect "127.0.0.1", 1234, sub {
	if (my $fh = shift) {
		my $hdr;
		syswrite $fh, "URL https://mail.ru\n";
		syswrite $fh, "HEAD\n";
		syswrite $fh, "GET\n";
		syswrite $fh, "FIN\n";
	} else {
		warn "Connect failed: $!";
	}
};
AE::cv->recv;