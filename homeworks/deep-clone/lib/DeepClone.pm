package DeepClone;

use 5.010;
use strict;
use warnings;
use DDP;

=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut

my $cloned;
sub clone;
sub clone {
	my $orig = shift;
	my $newclone;
	my $cloned;
	if (ref($orig) eq 'HASH'){
		$cloned = {%{$orig}};
		while (my ($key, $val) = each(%$orig)){
			say "$key, $val";
			$cloned->{$key} = clone($val) unless ($cloned eq $val);
		}
	} elsif (ref($orig) eq 'ARRAY') {
		$cloned = [@{$orig}];
		for (@$cloned) {
			say $_;
			say $cloned;
			say $orig;
			$_ = clone($_) unless ($cloned eq $_);
		}
	}  elsif (defined $orig) {
		$cloned = $orig;
	}
	return $cloned;
}
1;