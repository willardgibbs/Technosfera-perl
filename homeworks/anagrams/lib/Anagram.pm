package Anagram;

use 5.010;
use strict;
use warnings;
use DDP;
use utf8;
use open qw(:std :utf8);

#use encoding 'cp1251';

=encoding UTF8

=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функцию поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
    'пятак'  => ['пятак', 'пятка', 'тяпка'],
    'листок' => ['листок', 'слиток', 'столик'],
}

=cut
sub pars {
    my $str = shift;
    my @res = sort (split //, $str);
    return \@res;
}

sub equalarray {
    my $arrrefF = shift;
    my $arrrefS = shift;
    my $flag = 1;
    if (scalar @{$arrrefF} == scalar @{$arrrefS}) {
        for (my $i = 0; $i < scalar @{$arrrefF}; $i++) {
            $flag = 0 if !($arrrefF->[$i] eq $arrrefS->[$i]);
        }
    } else {
        $flag = 0;
    }
    return $flag;
}

sub deldupl {
    my %tmp;
    my @res = grep {! $tmp{$_}++ } @_;
    return \@res;
}

sub anagram {
    my $words_list = shift;
    my %result;
    my %parshash;
    my %tmp;
    my $count = 0;
    for (@$words_list) {
        $_ = lc($_);
        $parshash{$_} = pars($_);
    }
    for my $val (@$words_list) {
        if (keys %result) {
            my $iter = 0;
            for (keys %result) {
                if (equalarray($parshash{$_}, $parshash{$val})) {
                    push @{$result{$_}}, $val;
                    $iter++;
                }
            }
            $result{$val} = [$val] unless $iter;
        } else {
            $result{$val} = [$val];
        }
        $count++;
        p $count;
    }
    for (keys %result) {
        $result{$_} = deldupl(@{$result{$_}});
        delete $result{$_} if (scalar @{$result{$_}} == 1);
    }
    return \%result;
}
1;