package Anagram;

use 5.010;
use strict;
use warnings;
use Encode qw(encode decode);

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
    my $kek = shift;
    my %tmp;
    my %parshash;
    my %result;
    my $words_list = [@$kek];#мб из-за use constant в тесте
    for my $val (@$words_list) {
        $val = lc decode('utf-8', $val);
        $parshash{$val} = pars($val);
        if (keys %tmp) {
            my $iter = 0;
            for (keys %tmp) {
                if (equalarray($parshash{$_}, $parshash{$val})) {
                    push @{$tmp{$_}}, $val;
                    $iter++;
                }
            }
            $tmp{$val} = [$val] unless $iter;
        } else {
            $tmp{$val} = [$val];
        }
    }
    for (keys %tmp) {
        $tmp{$_} = deldupl(@{$tmp{$_}});
        delete $tmp{$_} if (scalar @{$tmp{$_}} == 1);
    }
    $tmp{$_} = [sort @{$tmp{$_}}] for (keys %tmp);
    while (my ($key, $value) = each %tmp) {
        my $temp = encode('utf-8', $key);
        $result{$temp} = [];
        push @{$result{$temp}}, encode('utf-8', $_) for (@$value);
    } 
    return \%result;
} 
#anagram([ qw(пятка слиток пятак ЛиСток стул ПяТаК тяпка столик слиток) ]);
1;