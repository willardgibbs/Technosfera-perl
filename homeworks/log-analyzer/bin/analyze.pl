#!/usr/bin/perl

use strict;
use warnings;
<<<<<<< HEAD
use DDP;
use DateTime;
=======
our $VERSION = 1.0;
>>>>>>> ff902bc9658f2f6589dc37b01b5cae841cd911b0


my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

sub parse_file {
    my $file = shift;
    my @resarr;
    my $result;
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
    while (my $log_line = <$fd>) {
        p $log_line;
        $log_line =~ /(\d+\.\d+\.\d+\.\d+)\s\[([^\]]+)\]\s\"[^\"]+\"\s(\d+)\s(\d+)\s\"[^\"]+\"\s\"[^\"]+\"\s\"(\d+\.?\d*)\"/;
        push @resarr, {ip => $1, time => $2, status => $3, data => $4, koef => $5};
    }
    my $parser = DateTime::Format::Strptime->new(
        pattern => '%B %d, %Y %I:%M %p %Z',
        on_error => 'croak',
    );
    my $dt = $parser->parse_datetime($_->{time});
    for @resarr {
        $_->{time} =~ /(\d+)\/(\w+)\/(\d+)\:(\d+)\:(\d+)\:(\d+)\s\+(\d{2})00/;
    }
    close $fd;
    $result = \@resarr;
    return $result;
}

sub report {
    my $result = shift;
    my %reshash;
    my @stat;
    
    for (@$result){ 
        my $tmp = $_->{status};
        push @stat, $tmp unless (grep {$_ eq $tmp} @stat);
    }
    
    for my $val1 (@$result) {
        $reshash{$val1->{ip}}->{count} += 1;
        $reshash{$val1->{ip}}->{data} += $val1->{data}*$val1->{koef} if ($val1->{status} eq "200");
        $reshash{$val1->{ip}}->{sumtime} = $reshash{$val1->{ip}}->{avg} + $val1->{time};
        for my $val (@stat) {
            $reshash{$val->{ip}}->{$val} += 1 if ($val == $val1->{status});
        }
    }    

    my $head = "IP\tcount\tavg\tdata";
    $head = $head."\t".$_ for (@stat);
    say $head;


    my $total;
    my $totalcount;
    my %totalstatus;
    my $totaldata;
    my $totaltime;
    for (keys %reshash) {
        $totalcount += $reshash{$_}->{count};
        $totaldata += $reshash{$_}->{data};
        $totaltime += $reshash{$_}->{sumtime}; #найти минимум,вычесть из всех его и поделить на count 
        for my $val (@stat) {
            $totalstatus{$val} += $reshash{$_}->{$val};
        }
    }
    my $totalavg = $totaltime / $totalcount;
    $total = "total"."\t".$totalcount."\t".$totalavg;
    $total .= "\t".$totalstatus{$_} for (@stat);

    for (keys %reshash) { #выводим все и не упорядоченно
        my $ipstr .= $_;
        $ipstr .= "\t".$reshash{$_}->{count};
        $ipstr .= "\t".($reshash{$_}->{sumtime} / $reshash{$_}->{count});
        $ipstr .= "\t".$reshash{$_}->{data};
        for my $val (@stat) {
            $ipstr .= "\t".$reshash{$_}->{$val};
        } 
        say $ipstr;
    }
    return;
}

exit;