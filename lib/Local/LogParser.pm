package Local::LogParser;

use lib 'lib';
use strict;
use warnings;
use v5.24;
use utf8;
use Getopt::Std;
use Local::Misc qw(parse_config);
use open qw(:std :encoding(utf-8))
  ; # Мы хотим чтобы все FILEHANDLE работали с многобайтовми последовательностями "по-умолчанию"

our $VERSION = '0.2';

use Exporter qw(import);
our @EXPORT_OK = qw();

=encoding utf-8

=head1 NAME

Local::LogParser - корневой модуль приложения анализатора.

=head1 SYNOPSIS

use Local::LogParser;

Local::LogParser->new->run;

=head1 DESCRIPTION

Данный модуль реализует функционал анализа файл(ов) журнала
и наполняет базу данных в соответствии с заданием. (см. README.md)
Ниже представлено описание методов публичного API.

=cut

=over

=item B<new()> - метод класса, создает новый экземпляр приложения

Не принимает параметров.
Возвращает экземпляр приложения.

=back

=cut

sub new {
    my ($klass) = @_;

    my $self = { config => undef, config_file => '', files => [] };
    bless $self, $klass;
    return $self;
}

=over

=item B<run()> - метод объекта, запускает приложение и выполняет процесс анализа данных и формирование записей в базе.

Не принимает параметров.
Не возвращает значений.

=back

=cut

sub run {
    my ($self) = @_;

    $self->parse_options;
    $self->load_config;
    $self->db_connect;

    for my $file ( @{ $self->{files} } ) {
        $self->parse_log_file(
            $file,
            sub {
                my ($m) = @_;
                return 1;
            }
        );
    }

    $self->db_close;
    return 1;
}

sub db_connect {
    my ($self) = @_;

    return 1;
}

sub db_close {
    my ($self) = @_;

    return 1;
}

# Вывод справки по параметрам командной строки
sub show_usage {
    my ($self) = @_;

    say STDERR <<'EOF';
usage: mta-log-parser  [options] [files]
options:
    -c <filename>   - configuration file to use (mandatory parameter),
    -h              - show this message and exit.

EOF
    exit 0;
}

# Анализирует конфигурационный файл и наполняет соответствующие поля объекта
# см. описание формата в самом файле конфигурации.
sub load_config {
    my ($self) = @_;

    my $config = parse_config( $self->{config_file} )
      or die "Error: Unable to load configuration.\n";

    $self->{config} = $config;
    return 1;
}

# Анализирует аргументы командной строки
sub parse_options {
    my ($self) = @_;

    my %options = ();
    if ( getopts( "hc:", \%options ) ) {
        $self->show_usage
          if $options{h};
        $self->{config_file} = $options{c}
          if $options{c};
    }

    for (@ARGV) {
        push @{ $self->{files} }, $_ if $_;
    }

    return 1;
}

# Анализирует файл журнала почтового сервера, выполняет разделение полей строки
# сообщения и для каждой записи вызывает callback, передавая ему в качестве аргумента
# хеш с значениями сообщения.
#
# Данный метод возвращает количество сообщений, для которых callback вернул true.
sub parse_log_file {
    my ( $self, $log_file, $callback ) = @_;

    return 0
      if not -r $log_file;

    my $n = 0;
    open my $f, '<', $log_file or return 0;
    while (<$f>) {

# Предварительно разбираем строку лога...
# Достаем общие для всех и интересующих нас записи сообщения.
        if (/^([\d\-]+\s[\d\:]+)\s+([\w\d-]+)\s+([^ ]+)\s+(.+)/i) {
            my $m = {
                datetime   => $1,
                message_id => $2,
                flag       => $3,
                text       => $4,
            };

            if ( $m->{flag} eq '<=' and $m->{text} =~ /.*?id=([^\s]+)/ ) {
                $m->{id} = $1;
            }
            elsif ( $m->{flag} =~ /(?:\=\=|\=\>|\-\>|\*\*)/
                and $m->{text} =~ /^([^\@]+\@[^\s:]+)/ )
            {
                my $email = $1;
                $email = $1
                  if $email =~ /^.+?\<([^ \>]+)\>$/;
                $m->{to_address} = $email;
            }

            if ( ref $callback eq 'CODE' and $m->{message_id} ) {
                $n++
                  if $callback->($m);
            }
        }
    }

    close $f;
    return $n;
}

1;
