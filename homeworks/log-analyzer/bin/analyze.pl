#!/usr/bin/perl

use strict;
use warnings;
use DDP;
use POSIX ();
use Date::Parse;
our $VERSION = 1.0;

my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

sub parse_file {
    my $file = shift;
    my $resarr = [];
    my $fd;
    if ($file =~ /\.bz2$/) {
        open $fd, "-|", "bunzip2 < $file" or die "Can't open '$file' via bunzip2: $!";
    } else {
        open $fd, "<", $file or die "Can't open '$file': $!";
    }
    while (my $log_line = <$fd>) {
        if ($log_line) {
            $log_line =~ /^(\d+\.\d+\.\d+\.\d+)\ \[([^\]]+)\]\ ".+"\ (\d+)\ (\d+)\ \"[^\"]+\"\ \"[^\"]+\"\ \"(.+)\"/;
            my $tmp = {ip => $1, time => int(str2time($2) / 60), status => $3, data => $4/1024, koef => $5};
            $tmp->{koef} = 1 if $tmp->{koef} eq "-";
            push @$resarr, $tmp;
        }
    }
    close $fd;
    @$resarr = sort {$a->{time} <=> $b->{time}} @$resarr;
    return $resarr;
}

sub head {
    my $stat = shift;
    my $headstr = "IP\tcount\tavg\tdata";
    $headstr .= "\t".$_ for (@$stat);
    print "$headstr\n";
}

sub allstatus {
    my $result = shift;
    my $stat= [];
    for my $val (@$result){ 
        my $tmp = $val->{status};
        if (@$stat) {
            push @$stat, $tmp unless (grep {$_ eq $tmp} @$stat); 
        } else {
            push @$stat, $tmp;
        }
    }
    my @sortstat = sort @$stat;
    return \@sortstat;
}

sub total {
    my $reshash = shift;
    my $stat = shift;
    my $totalstr;
    my $totalcount;
    my %totalstatus;
    my $totaldata;
    my $totaltime;
    my $totalcounttime;
    for my $val1 (keys %{$reshash}) {
        $totalcount += $reshash->{$val1}->{count};
        $totaldata += $reshash->{$val1}->{data} if ($reshash->{$val1}->{data});
        $totalcounttime += $_ for @{$reshash->{$val1}->{mincount_arr}};
        $totaltime += $reshash->{$val1}->{min_amount};
        for my $val (@$stat) {
            $totalstatus{$val} += $reshash->{$val1}->{$val};
        }
    }
    my $totalavg = $totalcounttime / $totaltime;
    $totalstr = "total"."\t".$totalcount."\t".sprintf("%.2f", $totalavg)."\t".POSIX::floor($totaldata);
    $totalstr .= "\t".POSIX::floor($totalstatus{$_}) for (@$stat);
    print "$totalstr\n";
}

sub print_result {
    my $reshash = shift;
    my $stat = shift;
    my $n = shift;
    my @mass = sort { $reshash->{$b}->{count} <=> $reshash->{$a}->{count} } keys %{$reshash};
    for my $i (0..($n-1)) {
        my $tmp = 0;
        my $ipstr .= $mass[$i];
        $ipstr .= "\t".$reshash->{$mass[$i]}->{count};
        $tmp += $_ for @{$reshash->{$mass[$i]}->{mincount_arr}};
        $ipstr .= "\t".sprintf("%.2f", ($tmp / $reshash->{$mass[$i]}->{min_amount}));
        $ipstr .= "\t".POSIX::floor($reshash->{$mass[$i]}->{data});
        for my $val (@$stat) {
            $ipstr .= "\t".POSIX::floor($reshash->{$mass[$i]}->{$val});
        } 
        print "$ipstr\n";
    }
}

sub make_result {
    my $result = shift;
    my $stat = shift;
    my $reshash;
    my $tmp_fortime;
    for my $val1 (@$result) {
        $reshash->{$val1->{ip}}->{mincount_arr} = [] unless defined($reshash->{$val1->{ip}}->{mincount_arr});
        $reshash->{$val1->{ip}}->{count} += 1;
        $reshash->{$val1->{ip}}->{data} += $val1->{data}*$val1->{koef} if ($val1->{status} eq "200");
        if (defined($reshash->{$val1->{ip}}->{time})) {
            if ($val1->{time} > $reshash->{$val1->{ip}}->{time} + 1) {
                push @{$reshash->{$val1->{ip}}->{mincount_arr}}, $tmp_fortime;
                $tmp_fortime = 0;
                $reshash->{$val1->{ip}}->{time} = $val1->{time};
                $reshash->{$val1->{ip}}->{min_amount}++;
            } else {
                $tmp_fortime++;
            }
        } else {
            $reshash->{$val1->{ip}}->{time} = $val1->{time};
            $reshash->{$val1->{ip}}->{min_amount}++;
            $tmp_fortime++;
        }
        for my $val (@$stat) {
            $reshash->{$val1->{ip}}->{$val} = 0 unless (defined $reshash->{$val1->{ip}}->{$val});
            $reshash->{$val1->{ip}}->{$val} += $val1->{data} if ($val == $val1->{status});
        }
    }
    return $reshash;
}

sub report {
    my $result = shift;

    my $stat = allstatus($result);
    my $reshash = make_result($result, $stat);
    head($stat);
    total($reshash, $stat);
    print_result($reshash, $stat, 10); #задать кол-во выдаваемых объектов после total
    return;
}