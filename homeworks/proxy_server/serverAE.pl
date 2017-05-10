#!/usr/bin/perl
use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;
use AnyEvent::Socket;
use AnyEvent::Handle;

my $urls;
tcp_server '0.0.0.0', 1234, sub {
    my $fh = shift;
    my $handle; $handle = new AnyEvent::Handle
        fh => $fh,
        on_error => sub { $handle->destroy; };
    my $reader; $reader = sub {
        (undef, my $line) = @_;
        if ( $line =~ q/^URL (.+)/ ) {
            $handle->push_write("OK\n");
            $urls->{$handle} = $1;
            $handle->push_read(line => $reader);
        }
        if ($line =~ q/^FIN$/) {        
            $handle->push_write("Destroy connection\n");
            close($fh);
            $handle->destroy;
        }
        if ($line =~ q/^HEAD$/) {
            http_request 
                HEAD => $urls->{$handle},
                sub {
                    my ($body, $hdr) = @_;
                    my $headers = '';
                    if ($hdr->{Status} == 200) {
                        $handle->push_write("OK\n");
                        while ( my ($key, $value) = each %$hdr ) { 
                            $handle->push_write("$key: $value\n"); 
                        }
                    } else {
                        print "\nSorry, $hdr->{Status} in your head request $urls->{$handle}\n";
                    }
                    $handle->push_read(line => $reader);
                };
        }
        if ($line =~ q/^GET$/) {
            http_request 
                GET => $urls->{$handle},
                sub {
                    my ($body, $hdr) = @_;
                    my $headers = '';
                    if ($hdr->{Status} == 200) {
                        $handle->push_write("OK\n");
                        $handle->push_write("$body\n");
                    }else {
                        print "\nSorry, $hdr->{Status} in you get request $urls->{$handle}\n";
                    }
                    $handle->push_read(line => $reader);
                };
        }
    };
    $handle->push_read(line => $reader);
};

AE::cv->recv;
