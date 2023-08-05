#! /usr/bin/env perl

use strict;
use warnings;
use v5.24;
use utf8;

my $db_ready = undef;
my $timeout  = 10;

for my $n (1 .. 10) {
    sleep $timeout;
    system 'cat mysql_schema.sql | mysql -uroot -proot -hmariadb';
    if ($? == 0) {
        $db_ready = 1; last;
    }
}

die "Error: MariaDB: failed to setup database!\n"
    if not $db_ready;

say 'Parse MTA log file ...';
system './mail_log_parse.pl';
if ($? != 0) {
    die "Error: Unable to proceed!";
}

say 'Starting Apache web server ...';
say 'Please open: http://localhost:8080/cgi-bin/mail_log_search.pl';

exec '/usr/sbin/apache2ctl', '-D', 'FOREGROUND';
