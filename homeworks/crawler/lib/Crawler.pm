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
my $result = {};

sub top_10 {
	my $result = shift;
	my $total_size;
	my @top10_list;
	for (keys %$result) {
		$total_size += $result->{$_};
	}
	my @mass = sort { $result->{$b} <=> $result->{$a} } keys %$result;
	@top10_list = @mass[0..9];
	return $total_size, @top10_list;
}

sub myrequests {
	my $start_page = shift;
	my $ref_on_hrefs;
    STDOUT->autoflush;
	my $exit_wait = AnyEvent->condvar;
	my $exit_wait1 = AnyEvent->condvar;
	my $flag;

	my $handle = http_request
		HEAD => $start_page,
		timeout => 1,
		sub {
			my ($body, $hdr) = @_;
			if ($hdr->{Status} == 200) {
				$flag = $hdr->{"content-type"} =~ /text\/html/;
			}
			$exit_wait->send;
		};
	$exit_wait->recv;
	return unless $flag;

	my $handle1 = http_request
		GET => $start_page,
		timeout => 1,
		sub {
			my ($body, $hdr) = @_;
			if ($hdr->{Status} == 200) {
				$result->{$start_page} = length(Encode::encode_utf8($body));
				@$ref_on_hrefs = $body =~ /href="(\/[^#"][^"]+)"/g;
			}
			$exit_wait1->send;
		};
	$exit_wait1->recv;
	return $ref_on_hrefs;
}

sub run {
    my ($start_page, $parallel_factor) = @_;
    $start_page =~ /http\w?:\/\/[^\/]+(\/.+)/;
	my $url = $1;
	my $href_inside = [];
    my $ref_on_hrefs = myrequests($start_page);
	for (@$ref_on_hrefs) {
		push @$href_inside, $start_page.$url if ($_ =~ /^$url(.+)$/);
	};
	for my $var (@$href_inside) {
		run($var, 1) unless exists($result->{$var}) or keys %$result == 1000;
	}
    return top_10($result);
}
my ($total_size, @top10_list) = run("https://github.com/Nikolo/Technosfera-perl/tree/anosov-crawler", 1);
my $tmp = int($total_size/1024);
p $tmp;
p @top10_list;
1;