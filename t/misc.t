#! /usr/bin/env perl 

use lib 'lib';

use strict;
use warnings;
use v5.24;
use utf8;
use Data::Dumper qw(Dumper);
use Test::More tests => 1;
use Local::Misc qw(parse_config);

sub test_parse_config {
    my $filename = 'config.conf';
    my $config   = parse_config($filename);
    return 0
      if not $config;

    my $want_config = {
        db_dsn      => 'DBI:mysql:database=test;host=127.0.0.1',
        db_user     => 'test',
        db_password => 'test',
    };

    is_deeply( $want_config, $config, 'can parse config' );
}

test_parse_config();
