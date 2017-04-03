#!/usr/bin/perl

use strict;
use warnings;
use DDP;
use POSIX ();
our $VERSION = 1.0;



my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

sub parse_file {
    my $file = shift;
<<<<<<< HEAD
    my $resarr;
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
=======

    # you can put your code here

    my $fd;
    if ($file =~ /\.bz2$/) {
        open $fd, "-|", "bunzip2 < $file" or die "Can't open '$file' via bunzip2: $!";
    } else {
        open $fd, "<", $file or die "Can't open '$file': $!";
    }

    my $result;
>>>>>>> 1aa0d32ce2da91b118709427adcf836e0956046e
    while (my $log_line = <$fd>) {
        if ($log_line) {
            $log_line =~ /^(\d+\.\d+\.\d+\.\d+)\ \[([^\]]+)\]\ ".+"\ (\d+)\ (\d+)\ \"[^\"]+\"\ \"[^\"]+\"\ \"(.+)\"\n/;
            push @$resarr, {ip => $1, time => $2, status => $3, data => $4/1024, koef => $5};
        }
    }
    for (@$resarr) {
        $_->{time} =~ /\d+\/\w+\/\d+\:(\d+)\:(\d+)\:\d+\s\+\d+/;
        $_->{time} = $1*60 + $2;
        $_->{koef} = 1 if ($_->{koef} eq "-");
    }
    close $fd;
    return $resarr;
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
        $totalcounttime += $reshash->{$val1}->{sum_min_count};
        $totaltime += $reshash->{$val1}->{mincount};
        for my $val (@$stat) {
            $totalstatus{$val} += $reshash->{$val1}->{$val};
        }
    }
    my $totalavg = $totalcounttime / $totaltime;
    $totalstr = "total"."\t".$totalcount."\t".sprintf("%.2f", $totalavg)."\t".POSIX::floor($totaldata);
    $totalstr .= "\t".POSIX::floor($totalstatus{$_}) for (@$stat);
    print "$totalstr\n";
}

sub head {
    my $stat = shift;
    my $headstr = "IP\tcount\tavg\tdata";
    $headstr .= "\t".$_ for (@$stat);
    print "$headstr\n";
}

sub print_result {
    my $reshash = shift;
    my $stat = shift;
    my @mass = sort { $reshash->{$b}->{count} <=> $reshash->{$a}->{count} } keys %$reshash;
    for my $i (0..9) {
        my $ipstr .= $mass[$i];
        $ipstr .= "\t".$reshash->{$mass[$i]}->{count};
        $ipstr .= "\t".sprintf("%.2f", ($reshash->{$mass[$i]}->{sum_min_count} / $reshash->{$mass[$i]}->{mincount}));
        $ipstr .= "\t".POSIX::floor($reshash->{$mass[$i]}->{data});
        for my $val (@$stat) {
            $ipstr .= "\t".POSIX::floor($reshash->{$mass[$i]}->{$val});
        } 
        print "$ipstr\n";
    }
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

sub make_result {
    my $result = shift;
    my $stat = shift;
    my $reshash;
    for my $val1 (@$result) {
        $reshash->{$val1->{ip}}->{count} += 1;
        $reshash->{$val1->{ip}}->{data} += $val1->{data}*$val1->{koef} if ($val1->{status} eq "200");
        $reshash->{$val1->{ip}}->{date} = $val1->{time} unless (defined $reshash->{$val1->{ip}}->{date});

        if ($val1->{time} eq $reshash->{$val1->{ip}}->{date}) {
            $reshash->{$val1->{ip}}->{formin} += 1;
        } else {
            $reshash->{$val1->{ip}}->{date} = $val1->{time};
            $reshash->{$val1->{ip}}->{mincount} +=1; 
            $reshash->{$val1->{ip}}->{sum_min_count} += $reshash->{$val1->{ip}}->{formin};
            $reshash->{$val1->{ip}}->{formin} = 1;
        }

        for my $val (@$stat) {
            $reshash->{$val1->{ip}}->{$val} = 0 unless (defined $reshash->{$val1->{ip}}->{$val});
            $reshash->{$val1->{ip}}->{$val} += $val1->{data} if ($val == $val1->{status});
        }
    }
    for (keys %$reshash) {
        $reshash->{$_}->{sum_min_count} += $reshash->{$_}->{formin} unless (defined $reshash->{$_}->{sum_min_count});
        $reshash->{$_}->{mincount} = 1 unless (defined $reshash->{$_}->{mincount});
    }
    return $reshash;
}

sub report {
    my $result = shift;

    my $stat = allstatus($result);
    my $reshash = make_result($result, $stat);
    head($stat);
    total($reshash, $stat);
    print_result($reshash, $stat);
    return;
}