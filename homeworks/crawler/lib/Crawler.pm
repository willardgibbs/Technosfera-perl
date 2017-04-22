package Crawler;

use 5.010;
use strict;
use warnings;

use AnyEvent;
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

my $get = sub {
	my $start_page = shift;
	my $ref_on_hrefs = [];
	my $handle1 = http_request
		GET => $start_page,
		timeout => 1,
		sub {
			say "lol";
			my ($body, $hdr) = @_;
			if ($hdr->{Status} == 200) {
				$result->{$start_page} = length(Encode::encode_utf8($body));
				@$ref_on_hrefs = $body =~ /href="(\/[^#"][^"]+)"/g;
			}
		};
	p $ref_on_hrefs;
	return $ref_on_hrefs;
};

sub head {
	my $cb = shift;
	my $start_page = shift;
	my $flag;
	my $top_kek;
	http_request
		HEAD => $start_page,
		timeout => 1,
		$top_kek = sub {
			my ($body, $hdr) = @_;
			if ($hdr->{Status} == 200) {
				if ($flag = $hdr->{"content-type"} =~ /text\/html/) {
					undef $top_kek;
					return $cb->($start_page);
				} else {
					return;
				}
			}
		};
}

sub run {
    my ($start_page, $parallel_factor) = @_;
	my $href_inside = [];
    my $ref_on_hrefs = [];

    #STDOUT->autoflush;

	my $cv = AE::cv;  
	$cv->begin;
	my $next;
	$next = sub {
		$start_page =~ /http\w?:\/\/[^\/]+(\/.+)/;
		my $url = $1;
		$cv->begin;
		$ref_on_hrefs = head $start_page, sub {
			$next->();
			$cv->end;
		};
		p $ref_on_hrefs;
		# = get($start_page) if head($start_page);

		# for (@$ref_on_hrefs) {
		# 	push @$href_inside, $start_page.$1 if ($_ =~ /^$url(.+)$/);
		# }
		# for my $var (@$href_inside) {
		# 	return if exists($result->{$var}) or keys %$result == 1000;
		# }

	}; 
	$next->() for 1..2;
	$cv->end; 
	$cv->recv;
    return top_10($result);
}

my ($total_size, @top10_list) = run("https://github.com/Nikolo/Technosfera-perl/tree/anosov-crawler", 1);
my $tmp = int($total_size/1024);
p $tmp;
p @top10_list;

1;