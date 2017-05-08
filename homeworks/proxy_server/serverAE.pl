#!/usr/bin/perl
use 5.010;
use strict;
use warnings;
use AnyEvent::HTTP;
use AnyEvent::Socket;
use AnyEvent::Handle;
use DDP;

my $die;

tcp_server "127.0.0.1", 5000, sub {
	my $c = shift;
	my $h; $h = AnyEvent::Handle->new(
		c => $c,
		on_error => sub {
			$h->destroy;
		}
	);
	my $reader; $reader = sub {
		$h->push_read(
			line => sub {
				my (undef, $line) = @_;
				my $url;
				$url = $1 if ($line =~ /URL (.+)\n/);
				if ($line eq "HEAD\n") {
					http_request 
					HEAD => $url,
					timeout => 10,
					sub {
						my ($body, $hdr) = @_;
						$h->push_write("OK\n");
						$h->push_write($hdr);
						print "HEAD OK\n";
					};
				}
				if ($line eq "GET\n") {
					http_request 
						GET => $url,
						timeout => 10,
						sub {
							my ($body, $hdr) = @_;
							print "GET OK\n";
							$h->push_write("OK\n");
							$h->push_write($body);
						};
				}
				if ($line eq "FIN") {
					die;
				}
			}
		);
		$reader->();
	}; $reader->();
};

AE::cv->recv;

