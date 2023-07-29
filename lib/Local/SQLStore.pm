package Local::SQLStore;

our $VERSION = '0.1';

use strict;
use warnings;
use Exporter qw(import);
our @EXPORT_OK = qw();

use DBI;

sub new {
    my ($klass, $dsn, %params) = @_;

    my $self = \%params; 
    bless $self, $klass;
    eval {
        my %attrs = (RaiseError => 1, AutoCommit => 0);
        $self->{db} = DBI->connect($dsn, 
            $self->{user}, 
            $self->{password}, \%attrs);
    };

    if ($@) {
        $self->{error_message} = 'DB connect error: '. $@;
        return undef, $self->{error_message}; 
    }

    $self, $self->{error_message};
}

sub error_message {
    my ($self) = @_; 
    $self->{error_message};
}

sub close {
    my ($self) = @_;
    $self->{db}->disconnect();
}

sub insert_txn {
    my ($self, $table, $rows) = @_;

    my @keys         = keys %{ $rows->[0] };
    my $columns      = join ',', @keys;
    my $placeholders = join ',', split(//, '?' x scalar @keys);
    my $sql          = "INSERT INTO ${table} (${columns}) VALUES (${placeholders})";

    eval {
        my $stmt = $self->{db}->prepare($sql);
        for my $row (@{ $rows }) {
            my @values = map { $row->{$_} } @keys;
            $stmt->execute(@values);
        }

        $stmt->finish();
    };

    if ($@) {
        $self->{db}->rollback();
        $self->{error_message} = 'SQL insert failed: '. $@;
        return $self->{error_message} 
    }

    $self->{db}->commit();
    1;
}

sub create_messages {
    my ($self, $messages) = @_;
    $self->insert_txn('message', $messages);
}

sub create_logs {
    my ($self, $logs) = @_;
    $self->insert_txn('log', $logs);
}

sub search_to_address {
    my ($self, $to_address) = @_;

    my @result;
    my $truncated   = 0; # Sets to 1 when result was truncated.

    eval {
        my %int_ids;

        # First load internal message ids for a given *TO* email address ...
        my $stmt = $self->{db}->prepare(
            sprintf('SELECT created, int_id, str FROM log WHERE address=%s ORDER BY created, int_id LIMIT 101', 
                $self->{db}->quote($to_address)));

        $stmt->execute();
        my $n = 0; while (my (@rows) = $stmt->fetchrow()) {
            $n++; if ($n >= 100) {
                $truncated = 1; last;
            }
            $int_ids{$rows[1]} = undef;
            push @result, [$rows[0], $rows[2]],
        }

        $stmt->finish();
        
        if (%int_ids) { # ... then load messages
            $stmt = $self->{db}->prepare(
                sprintf('SELECT created, str FROM message WHERE int_id IN (%s) ORDER BY created, int_id LIMIT 101',
                    join ',', split(//, '?' x scalar keys %int_ids)));

            $stmt->execute(keys %int_ids);
            $n = 0; while (my (@rows) = $stmt->fetchrow()) {
                $n++; if ($n >= 100) {
                    $truncated = 1; last;
                }
                push @result, [$rows[0], $rows[1]],
            }

            $stmt->finish();
        }
    };

    if ($@) {
        $self->{error_message} = 'SQL query failed: '. $@;
        return [], 0 
            if wantarray;

        return [];
    }

    @result = sort { $a->[0] cmp $b->[0] } @result;
    return \@result, $truncated 
        if wantarray;

    \@result;
}

1;

__END__