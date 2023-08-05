package Local::Store;

use lib 'lib';
use strict;
use warnings;
use v5.24;
use utf8;
use DBI;

our $VERSION = '0.2';

use Exporter qw(import);
our @EXPORT_OK = qw();

=encoding utf-8

=head1 NAME

Local::Store - модуль для работы с базой данных

=head1 SYNOPSIS

use Local::Store;

my ($db, $error) = Local::Store->new($dsn, $user, $password);

$db->insert($table, \@messages);

$db->error;

$db->load_for_to_address('foo@exapmle.com', n => 100);

$db-close;

=head1 DESCRIPTION

Данный модуль реализует взаимодействие с базой данных.
Он используется как скриптом анализатора так и CGI скриптом.

=cut

=over

=item I<($db, $error)> = new(I<$dsn>, user => I<$user>, password => I<$password>) - метод класса, создает новое подключение к базе.  

Принимает строку, описывающую DSN в соответствии с синтаксисом DBI,
а так же логин и пароль от базы данных.
Возвращает массив, в котором первый элемент это объект, второй - строка ошибки

=back

=cut

sub new {
    my ( $klass, $dsn, %params ) = @_;

    my $self = \%params;
    $self->{error} = '';
    eval {
        my %attrs = (

# Мы хотим, чтобы DBI сигнализировал об ошибках с помощью die
            RaiseError => 1,

# Мы отключаем autocommit для ускорения опрераций вставки в базу.
            AutoCommit => 0
        );

        $self->{db} =
          DBI->connect( $dsn, $self->{user}, $self->{password}, \%attrs );
    };

    if ($@) {
        $self->{error} = $@;
        $self->{error} =~ s/at .+$//;
        return undef, $self->{error};
    }

    bless $self, $klass;
    return $self, '';
}

=over

=item B<close()> - закрывает соединение с базой.

Не принимает параметров.
Не возвращает значений.

=back

=cut

sub close {
    my ($self) = @_;
    $self->{db}->disconnect
      if $self->{db};
}

=over

=item B<error()> - возвращает строку ошибки последней неудавшейся операции.

Не принимает параметров.

=back

=cut

sub error {
    my ($self) = @_;
    return $self->{error};
}

=over

=item B<insert($table, \@messages)> - осуществляет вставку строк в таблицу SQL.

Принимает название таблицы и ссылку на массив ссылок на хеш, ключи которого соответствуют именам
столбцов таблицы. Вставка выполняется в рамках одной транзакции.

Возвращает B<undef> в случаи ошибки 

=back

=cut

sub insert {
    my ( $self, $table, $rows ) = @_;

    return 1
      unless @$rows
      ;    # Нечего делать, передан пустой массив

    my @keys         = keys %{ $rows->[0] };
    my $columns      = join ',', @keys;
    my $placeholders = join ',', split( //, '?' x scalar @keys );

    my $sql = "INSERT INTO $table ($columns) VALUES ($placeholders)";
    eval {
        my $th = $self->{db}->prepare($sql);
        for my $row (@$rows) {
            my @values =
              map { $row->{$_} }
              @keys
              ; # Подготавливаем список значений для вставки

            $th->execute(@values);
        }

        $th->finish();
    };

    if ($@) {
        $self->{db}->rollback()
          ; # Откатываем транзакцию, если произошли ошибки при вставке

        $self->{error} = $@;
        $self->{error} =~ s/at .+$//;
        return 0;
    }

    $self->{db}->commit();
    return 1;
}

1;
