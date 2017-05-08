#!/usr/bin/perl
use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;
use AnyEvent::Socket;
use AnyEvent::Handle;

tcp_connect "0.0.0.0", 1234,
sub {
	my ($fh) = @_ or die "unable to connect: $!";
	my $handle;
	$handle = new AnyEvent::Handle
		fh     => $fh,
		on_error => sub {
			AE::log error => $_[2];#с логами я ещё не до конца разобрался, но пусть будет)
			$_[0]->destroy;
		},
		on_eof => sub {
			AE::log info => "Done.";
			$handle->destroy;
		};
	
	$handle->push_write ("URL https://github.com/Nikolo/Technosfera-perl/tree/anosov-crawler\n");
	$handle->push_write("GET\n");
	$handle->push_write("HEAD\n");
	#$handle->push_write("FIN\n");
	$handle->push_read (line => sub {
		my ($handle, $line) = @_;
		
		$handle->on_read (sub {
			print $_[0]->rbuf;
			$_[0]->rbuf = "";
		});
	});
};

AE::cv->recv;
