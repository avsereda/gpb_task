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

txn {
    my $th = shift;
    ...
} $db, $sql_query

$db->error;

$db->load_for_to_address('foo@exapmle.com', n => 100);

$db-close;

=head1 DESCRIPTION

Данный модуль реализует взаимодействие с базой данных.
Он используется как скриптом анализатора так и CGI скриптом.

=head1 CONSTANTS

=cut

=over

=item B<SQL_MESSAGE_COLUMNS> - названия столбцов таблицы сообщений.  

=back

Столбцы таблицы: I<datetime message_id flag to_address id text>

=cut

use constant SQL_MESSAGE_COLUMNS =>
  qw(datetime message_id flag to_address id text);

# Вспомогательная функция для перехвата ошибок
sub try(&) {
    my ($block) = @_;

    eval { $block->() };
    if ($@) {
        my $error = $@;
        $error =~ s/at .+$//;
        return $error;
    }

    return '';
}

=head1 METHODS

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
    $self->{error} = try {
        my %attrs = (

# Мы хотим, чтобы DBI сигнализировал об ошибках с помощью die
            RaiseError => 1,

# Мы отключаем autocommit для ускорения опрераций вставки в базу.
            AutoCommit => 0
        );

        $self->{db} =
          DBI->connect( $dsn, $self->{user}, $self->{password}, \%attrs );
    };

    bless $self, $klass;
    return $self, $self->{error};
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

=item B<txn({ ... } $self, $sql_query)> - SQL транзакция.

=back

Возвращает истину в случаи, если не было ошибок.

=cut

sub txn(&$$) {
    my ( $block, $self, $sql_query ) = @_;

    $self->{error} = try {
        my $th = $self->{db}->prepare($sql_query);
        $block->($th);
        $th->finish();
    };

    if ( $self->{error} ) {
        $self->{db}->rollback()
          ; # Откатываем транзакцию, если произошли ошибки при вставке

        return 0;
    }

    $self->{db}->commit();
    return 1;
}

=over

=item B<sql_query_insert_message)> - SQL запрос, который используется для вставке в таблицу сообщений.  

=back

=cut

sub sql_query_insert_message {
    my ($self) = @_;

    my @columns      = SQL_MESSAGE_COLUMNS;
    my $columns      = join ',', @columns;
    my $placeholders = join ',', split( //, '?' x scalar @columns );

    return "INSERT INTO message ($columns) VALUES ($placeholders)";
};

=over

=item B<insert($table, \@messages)> - осуществляет вставку строк в таблицу SQL.

Принимает название таблицы и ссылку на массив ссылок на хеш, ключи которого соответствуют именам
столбцов таблицы. Вставка выполняется в рамках одной транзакции.

Возвращает B<undef> в случаи ошибки 

=back

=cut

sub insert {
    my ( $self, $table, $rows ) = @_;

    txn {
        my $th = shift;
        for my $row (@$rows) {
            my @values =
              map { $row->{$_} }
              SQL_MESSAGE_COLUMNS
              ; # Подготавливаем список значений для вставки

            $th->execute(@values);
        }
    }
    $self, $self->sql_query_insert_message;
    return not $self->{error};
}

1;
