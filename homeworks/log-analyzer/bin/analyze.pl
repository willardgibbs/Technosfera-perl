#!/usr/bin/perl

use strict;
use warnings;
use DDP;
#use DateTime;
our $VERSION = 1.0;



my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

sub parse_file {
    my $file = shift;
    #my $log_line = '68.51.111.236 [03/Mar/2017:18:28:38 +0300] "GET /music/artists/Pink%20Floyd HTTP/1.1" 200 66477 "-" "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)" "6.51"';
    my @resarr;
    my $result;
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
    while (my $log_line = <$fd>) {
        if ($log_line) {
            $log_line =~ /(\d+\.\d+\.\d+\.\d+)\s\[([^\]]+)\]\s\"[^\"]+\"\s(\d+)\s(\d+)\s\"[^\"]+\"\s\"[^\"]+\"\s\"(.+)\"/;
            push @resarr, {ip => $1, time => $2, status => $3, data => $4, koef => $5} if (defined($1) and defined($2) and defined($3) and defined($4));
            #my $kek = {ip => $1, time => $2, status => $3, data => $4, koef => $5};
        }
    }
    for (@resarr) {
        $_->{time} =~ /\d+\/\w+\/\d+\:(\d+)\:(\d+)\:\d+\s\+\d+/;
        $_->{time} = $1*60 + $2;
        my $kek = $_->{time};
        p $kek;
    }
    close $fd;
    $result = \@resarr;
    return $result;
}

sub report {
    my $result = shift;
    my %reshash;
    my @stat;
    
    for my $val (@$result){ 
        my $tmp = $val->{status}; # не читается для некоторых
        if (@stat) {
            push @stat, $tmp unless (grep {$_ eq $tmp} @stat); #sort?
        } else {
            push @stat, $tmp;
        }
    }
    @stat = sort @stat;
    for my $val1 (@$result) {
        $reshash{$val1->{ip}}->{count} += 1;
        if ($val1->{status} eq "200") {
            if ($val1->{koef} ne "-") {
                $reshash{$val1->{ip}}->{data} += $val1->{data}*$val1->{koef};
            } else {
                $reshash{$val1->{ip}}->{data} += $val1->{data};
            }
        }

        if ($val1->{time} eq $reshash{$val1->{ip}}->{date}) {
            $reshash{$val1->{ip}}->{mincount} += 1;
        } else {
            $reshash{$val1->{ip}}->{date} = $val1->{time};
            $reshash{$val1->{ip}}->{summincount} = $reshash{$val1->{ip}}->{mincount};
            $reshash{$val1->{ip}}->{mincount} = 1;
        }
        for my $val (@stat) {
            $reshash{$val1->{ip}}->{$val} += 1 if ($val == $val1->{status});
        }
    }
    my $head = "IP\tcount\tavg\tdata\t";
    $head = $head."\t".$_ for (@stat);
    print "$head\n";

    my $total;
    my $totalcount;
    my %totalstatus;
    my $totaldata;
    my $totaltime;
    for (keys %reshash) {
        $totalcount += $reshash{$_}->{count};
        $totaldata += $reshash{$_}->{data};
        $totaltime += $reshash{$_}->{summincount};
        for my $val (@stat) {
            $totalstatus{$val} += $reshash{$_}->{$val};
        }
    }
    my $totalavg = $totaltime / $totalcount;
    $total = "total"."\t".$totalcount."\t".$totalavg;
    $total .= "\t".$totalstatus{$_} for (@stat);
    print "$total\n";
    my @mass = sort { $reshash{$a}->{count} <=> $reshash{$b}->{count} } keys %reshash;
    for my $i (0..9) {
        my $ipstr .= $mass[$i];
        $ipstr .= "\t".$reshash{$mass[$i]}->{count};
        $ipstr .= "\t".($reshash{$mass[$i]}->{sumtime} / $reshash{$mass[$i]}->{count});
        $ipstr .= "\t".$reshash{$mass[$i]}->{data};
        for my $val (@stat) {
            $ipstr .= "\t".$reshash{$mass[$i]}->{$val};
        } 
        print "$ipstr\n";
    }
    return;
}