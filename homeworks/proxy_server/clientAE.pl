#!/usr/bin/perl
use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;
use AnyEvent::Socket;
use AnyEvent::Handle;

tcp_connect "0.0.0.0", 1234, sub {
	my ($fh) = @_ or die "unable to connect: $!";
	my $handle;
	$handle = AnyEvent::Handle->new(
		fh     => $fh,
		on_error => sub {
			$_[0]->destroy;
		},
		on_eof => sub {
			$handle->destroy;
		}
	);
	$handle->push_write ("URL https://mail.ru\n");
	$handle->push_write("GET\n");
	$handle->push_write("HEAD\n");
	$handle->push_write("FIN\n");

	$handle->push_read (line => sub {
		my ($handle, $line) = @_;
		$handle->on_read (sub {
			print $_[0]->rbuf;
			$_[0]->rbuf = "";
		});
	});
};

AE::cv->recv;
