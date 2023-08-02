#! /usr/bin/env perl 

use strict;
use warnings; 
use v5.24;
use utf8;
use Local::SQLStore;
use Local::Mail::LogFileParser;
use Data::Dumper qw(Dumper);

my $LOG_FILE    = 'assets/out.zip';
my $DB_DSN      = "DBI:mysql:database=test;host=mariadb"; 
my $DB_USER     = "test";
my $DB_PASSWORD = 'test';

my $messages = [];
my $logs     = [];
my $parser   = undef;
my $error    = '';

my %id_set;
($parser, $error) = Local::Mail::LogFileParser->new($LOG_FILE, 
    process => sub {
        my ($msg_id, $log_entry) = @_;

        my $msg = {status => 1};
        for my $part (@{ $log_entry->{parts} }) {
            if ($part->{flag} eq '<=') {
                $msg->{created} = $part->{datetime} if not $msg->{created};
                $msg->{id}      = $part->{id};
                $msg->{int_id}  = $msg_id;
                $msg->{str}     = $part->{text};

            } elsif ($part->{flag} eq '**') {
                $msg->{status} = 0;

            } elsif ($part->{to_address}) {
                push @{ $logs },
                    {
                        created    => $part->{datetime},
                        int_id     => $msg_id,
                        str        => $part->{text},
                        address    => $part->{to_address},
                    };
            }
        }

        if ($msg->{id}) {
            if (not exists $id_set{$msg->{id}}) {
                $id_set{$msg->{id}} = undef;
                push @{ $messages }, $msg;
            } else {
                say STDERR 'Warning: Prevent from inserting duplicate id='. ($msg->{id} // '') 
                    .' message_id=['. ($msg->{int_id} // '') .']';
            }
        }
    });

if (not $parser) {
    die "Error: Parse error: $LOG_FILE: $error\n";
}

my $db; ($db, $error) = Local::SQLStore->new($DB_DSN, 
    user     => $DB_USER, 
    password => $DB_PASSWORD);

die "Error: $error\n" if not $db;

$db->create_messages($messages);
die 'Error: ', $db->error_message, "\n" 
    if $db->error_message;

$db->create_logs($logs);
die 'Error: ', $db->error_message, "\n" 
    if $db->error_message;

$db->close();
