#! /usr/bin/env perl 

use lib 'lib';

use strict;
use warnings;
use v5.24;
use utf8;
use Local::LogParser;

my $p = Local::LogParser->new;
$p->run;

__END__

=encoding utf-8

=head1 NAME

mta-log-parser - скрипт для анализа лога MTA и наполнения базы данных.

=head1 DESCRIPTION

Разбирает файл журнала и заполняет базу данных записями из журнала.
Данный скрипт может быть запущен как вручную, там и может использоваться
совместно с L<logrotate(8)>. В последнем варианте необходимо добавить 
строку его запуска в секцию B<postrotate>.

=head1 OPTIONS

=over 

=item B<-c> I<filename> - обязательный параметр, файл конфигурации, который будет использовать скрипт.

=back

=cut 

