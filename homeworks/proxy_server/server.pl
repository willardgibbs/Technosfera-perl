#!/usr/bin/perl
use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;
use AnyEvent::Socket;
use AnyEvent::Handle;

my %clients;
tcp_server '0.0.0.0', 1234, sub {
    my $fh = shift;
    my $handle; $handle = new AnyEvent::Handle
        fh => $fh,
        on_error => sub { $handle->destroy; };
    my $reader; 

    my $fin = sub {
        $handle->push_write("OK\n");
        $handle->destroy;
    };

    my $head = sub {
        say "in head";
        unless ( exists $clients{$handle} ) {
            $handle->push_write("Need URL\n");
            return;
        }
        http_request 
            HEAD => $clients{$handle},
            timeout => 5,
            sub {
                my ($body, $hdr) = @_;
                my $headers = '';
                if ($hdr->{Status} == 200) {
                    $handle->push_write("OK\n");
                    while ( my ($key, $value) = each %$hdr ) { $headers .= "$key:\t\t$value\n"; }
                    $handle->push_write("$headers\n");
                }else {
                    print "\nStatus $hdr->{Status} in head $clients{$handle}\n";
                }
                $handle->push_read(line => $reader);
            };
    };

    my $get = sub {
        say "in get";
        unless ( exists $clients{$handle} ) {
            $handle->push_write("Need URL\n");
            return;
        }
        http_request 
            GET => $clients{$handle},
            timeout => 5,
            sub {
                my ($body, $hdr) = @_;
                my $headers = '';
                if ($hdr->{Status} == 200) {
                    $handle->push_write("OK\n");
                    $handle->push_write("$body\n");
                }else {
                    print "\nStatus $hdr->{Status} in get $clients{$handle}\n";
                }
                $handle->push_read(line => $reader);
            };
    };

    $reader = sub {
        shift;
        my $line = shift;
        if ( $line =~ q/^URL (.+)/ ) {#I believe my client would not give me some trash)
            $handle->push_write("OK\n");
            $clients{$handle} = $1;
            $handle->push_read(line => $reader);
        }
        $fin->() if $line =~ q/^FIN$/;
        $head->() if $line =~ q/^HEAD$/;
        $get->() if $line =~ q/^GET$/;        
    };

    $handle->push_read(line => $reader);
};

say "Listening";
AE::cv->recv;
