package Crawler;

use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;
use Web::Query;
use URI;
use HTML::LinkExtor;
use DDP;
$AnyEvent::HTTP::MAX_PER_HOST = 100;
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

sub run {
	my ($start_page, $parallel_factor) = @_;
	my $total_size;	
	my @top10_list;
	my $limit = 1000;
	my %unic;
	$start_page =~ /http\w?:\/\/[^\/]+(\/.+)/;
	my $part = $1;
	my @links = ($start_page);
	my $num = 0;
	my $cv = AnyEvent->condvar;
	$cv->begin;
	my $next; $next = sub {
		$num++;
		unless ((keys(%unic) < $limit) && (@links)) {
			$cv->send;
			return;
		}
		my $link = shift @links;
		$cv->begin;
		http_head
			$link,
			sub {
				my ($body, $header) = @_;
				if ($header->{"content-type"} =~ "text/html") {	
					$cv->begin;
					http_get
						$link,
						sub {
							$body = shift;
							$unic{$link} = length $body;
							my @href = $body =~ /href="(\/[^#"][^"]+)"/g;
							for (@href) {
								my $tmp = $_ =~ /^$part(.+)$/;
								push @links, $start_page.$1 if $tmp && !$unic{$start_page.$1};
							}
							my $min = $parallel_factor;
							$min = @links if @links < $parallel_factor;
							$next->() while ($num <= $min);
							$num--;
							$cv->end;
							return;
						};
				}
				$cv->end;
			};

	}; $next->();
	$cv->end;
	$cv->recv;
	@top10_list = sort {$unic{$b} <=> $unic{$a}} keys %unic;
	$total_size += $unic{$_} for @top10_list;
	@top10_list = @top10_list[0..9];
	return $total_size, @top10_list;
}
1;