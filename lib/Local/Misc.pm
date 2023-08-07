package Local::Misc;

use strict;
use warnings;
use v5.24;
use utf8;

use open qw(:std :encoding(utf-8))
  ; # Мы хотим чтобы все FILEHANDLE работали с многобайтовми последовательностями "по-умолчанию"

our $VERSION = '0.1';

use Exporter qw(import);
our @EXPORT_OK = qw(parse_config);

=encoding utf-8

=head1 NAME

Local::Misc - модуль содержит вспомогательные функции.

=head1 DESCRIPTION

Данный модуль содержит вспомогательные функции, которые 
используются в других компонентах проекта.

=cut 

=over

=item B<parse_config(I<filename>)> 

Разбирает файл конфигурации на выражения.

Возвращает ссылку на хеш, содержащий поля конфигурационного файла
или B<undef> в случаи любых ошибок.

=back

I<filename> - путь к конфигурационному файлу.

=cut

sub parse_config {
    my ($filename) = @_;

    return undef
      if not( $filename and -f $filename );

    my $config = {};
    open my $f, '<', $filename or return undef;
    my $n = 0;
    while (<$f>) {
        $n++;
        next
          if /^(?:\s*#.*|\s*)$/
          ; # Пропускаем комментарии и пустые строки.

        chomp;    # Отрезаем конец строки.

# Все остальные строки представляют из себя комбинацию
# ключи - значение. Разбираем их с помощью данного регулярного выражения.
        if (/^\s*([\w\d_]+)\s*=\s*['"]([^'"]+)['"].*$/) {
            my ( $key, $value ) = ( $1, $2 );
            $config->{$key} = $value;
        }
        else {
            say STDERR 'Warning: Syntax error in configuration file: '
              . $filename
              . ", at line: $n";
        }
    }

    close $f;
    return $config;
}

1;
