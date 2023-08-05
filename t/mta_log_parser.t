#! /usr/bin/env perl 

use lib 'lib';

use strict;
use warnings;
use v5.24;
use utf8;
use Data::Dumper qw(Dumper);
use Test::More tests => 6;
use Local::LogParser;

sub test_mta_log_parser {
    my $p = Local::LogParser->new;

    ok( $p, 'can create instance' );

    push @ARGV, '-c', 'config.conf', 'assets/mta.log';

    ok( $p->parse_options,                  'can parse options' );
    ok( $p->load_config,                    'can load config' );
    ok( $p->{config_file} eq 'config.conf', 'can accpet -c option' );

    is_deeply(
        $p->{files},
        [ 'assets/mta.log' ],
        'can parse file parameters'
    );

    ok(
        $p->parse_log_file(
            'assets/mta.log',
            sub {
                my ($m) = @_;

                if ( $m->{message_id} eq '1RwtmW-000MsX-CK' ) {
                    return 0
                      if $m->{flag} eq '<='
                      and $m->{id} ne
                      '120213150629.AUCTION_RENEW.926291@whois.somehost.ru';
                    return 0
                      if $m->{flag} eq '=='
                      and $m->{to_address} ne 'bswdhpjxorekjaelb@gmail.com';

                    return 1;
                }

                return 0;
            }
        ) == 3,
        'can parse log file'
    );
}

test_mta_log_parser();
