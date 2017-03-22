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

sub cloning {
	my $orig = $_[0];
	my $new = $orig;  
	if (ref($orig) eq 'HASH'){
		$new = {%{$orig}};
		my $cycle = 0;
		while (my ($key, $val) = each(%$orig)){
			$cycle = 1 if (defined $val and ($val eq $orig));
		}
		unless ($cycle) {
			while (my ($key, $val) = each(%$orig)) {
				$new->{$key} = cloning($val, $_[1]);
			}
		}		
	} elsif (ref($orig) eq 'ARRAY') {
		$new = [@{$orig}];
		my $cycle = 0;
		for (@$new) {
			$cycle = 1 if (defined $_ and ($_ eq $orig));
		}
		unless ($cycle) {
			for my $val (@$new) {
				$val = cloning($val, $_[1]);
			}
		}
	} elsif (ref($orig)) {
		$_[1] = 1;
	}
	return $new;
}
sub clone {
	my $orig = shift;
	my $flag = 0;
	my $result = cloning($orig, $flag);
	if ($flag){
		return undef;
	} else {
		return $result;
	}
}
1;