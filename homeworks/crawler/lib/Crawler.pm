package Crawler;

use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;
use Web::Query;
use URI;
use DDP;
use Encode;
=encoding UTF8

=head1 NAME

Crawler

=head1 SYNOPSIS

Web Crawler

=head1 run($start_page, $parallel_factor)

Сбор с сайта всех ссылок на уникальные страницы

Входные данные:

$start_page - Ссылка с которой надо начать обход сайта

$parallel_factor - Значение фактора паралельности

Выходные данные:

$total_size - суммарный размер собранных ссылок в байтах

@top10_list - top-10 страниц отсортированный по размеру.

=cut
my $hash = {};
sub run {
    my ($start_page, $parallel_factor) = @_;
    $start_page or die "You must setup url parameter";
    $parallel_factor or die "You must setup parallel factor > 0";
    my $total_size = 0;
    my @top10_list;
    STDOUT->autoflush;
	my $exit_wait = AnyEvent->condvar;
	my $exit_wait1 = AnyEvent->condvar;
	open(my $fh, ">", "logs.txt");
	my $flag;
	my $handle = http_request
		HEAD => $start_page,
		timeout => 1,
		sub {
			my ($body, $hdr) = @_;
			if ($hdr->{Status} == 200) {
				$flag = $hdr->{"content-type"} =~ /text\/html/;
			} else {
				print {$fh} "Fail: @$hdr{qw(Status Reason)}";
			}
			$exit_wait->send;
		};
	$exit_wait->recv;
	return unless $flag;
	my @lol;
	my $handle1 = http_request
		GET => $start_page,
		timeout => 1,
		sub {
			my ($body, $hdr) = @_;
			if ($hdr->{Status} == 200) {
				$hash->{$start_page} = length(Encode::encode_utf8($body));
				@lol = $body =~ /href="([^#"][^"]+)"/g;
			} else {
				print {$fh} "Fail: @$hdr{qw(Status Reason)}";
			}
			$exit_wait1->send;
		};
	$exit_wait1->recv;
	$start_page =~ /(http\w?:\/\/[^\/]+\/)/;
	my $str = $1;
	my $base = URI->new($str);
	my @kek = ();
	push @kek, URI->new_abs($_, $base) for (@lol);
	print {$fh} join "\n", @kek;

	for my $i (@kek) {
		unless (exists($hash->{$i}) or keys %$hash == 1000) {
			run($i, 1);
			p $hash;
		}
	}

# #параллельное выполнение с лимитом 3
# 	my $cv = AE::cv;
# 	my @array = 1..10;
# 	my $i = 0;
# 	my $next; 
# 	$next = sub {
# 		my $cur = $i++;
# 		return if $cur > $#array;
# 		say "Process $array[$cur]";
# 		async sub {
# 			say "Processed $array[$cur]";
# 			$next->();
# 		};
# 	}; $next->() for 1..3;
# 	$cv->recv;

# #AE:HTTP


#     return $total_size, @top10_list;
}
run("https://github.com/Nikolo/Technosfera-perl/tree/anosov-crawler/", 1);
1;
