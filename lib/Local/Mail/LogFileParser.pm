package Local::Mail::LogFileParser;

our $VERSION = '0.1';

use strict;
use warnings;
use v5.24;
use Exporter qw(import);
our @EXPORT_OK = qw();

use IO::Uncompress::Unzip qw($UnzipError);

sub new {
    my ($klass, $filename, %params) = @_;

    my $self = \%params;

    $self->{filename}       = $filename,
    $self->{error_message}  = '';
    $self->{cache}          = {};

    bless $self, $klass;
    if ($filename =~ /\.zip$/i) {
        return undef, $self->{error_message}
            if not $self->read_zip_file;

    } else {
        my $f;
        if (not open $f, '<', $filename) {
            $self->{error_message} = 'Unable to open: '. $filename . ": $!";
            return undef, $self->{error_message};
        }

        while ( my $line = <$f> ) {
            $self->preparse_log_line($line);
        }

        close $f;
    }

    if (ref $self->{process} eq 'CODE') {
        for my $msg_id (keys %{ $self->{cache} }) {
            $self->{process}($msg_id, $self->{cache}{$msg_id});
        }
    }

    $self, $self->{error_message};
}

sub error_message {
    my ($self) = @_; 
    $self->{error_message};
}

sub preparse_log_line {
    my ($self, $log_line) = @_;

    if ($log_line =~ /^([\d\-]+\s[\d\:]+)\s+([\w\d-]+)\s+([^ ]+)\s+(.*)/i) {
        my ($datetime, $message_id, $flag, $raw_message) = ($1, $2, $3, $4);

        my $entry = {
            flag        => $flag, 
            text        => $raw_message,
            datetime    => $datetime,
            status      => 1,
        };

        if ($flag eq '<=' and $raw_message =~ /.*?id=([^\s]+)/) {
            $entry->{id} = $1;

        } elsif ($flag =~ /(?:\=\=|\=\>|\-\>|\*\*)/ and $raw_message =~ /^([^\@]+\@[^\s:]+)/) {
            my $email = $1;
            $email = $1 if $email =~ /^.+?\<([^ \>]+)\>$/;
            $entry->{to_address} = $email;
        } elsif ($flag eq '**') {
            $entry->{status} = 0;
        }

        push @{ $self->{cache}{$message_id}{parts} }, $entry
            if $message_id;
    }
}

sub read_zip_file {
    my ($self) = @_;

    my $z = IO::Uncompress::Unzip->new( $self->{filename} );
    if (not $z) {
        $self->{error_message} = 'Unzip error: '. $UnzipError;
        return undef;
    }

    while ( my $line = $z->getline() ) {
        $self->preparse_log_line($line);
    }

    $z->close;
    1;
}

1;

__END__