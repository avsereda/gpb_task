#! /usr/bin/env perl 

use lib 'lib';

use strict;
use warnings;
use v5.24;
use utf8;
use Data::Dumper qw(Dumper);
use Test::More tests => 3;
use Local::Store;

sub test_store {
    my ( $db, $error ) = Local::Store->new(
        'DBI:mysql:database=test;host=127.0.0.1',
        user     => 'test',
        password => 'test'
    );

    ok( $db && $error eq '' or die "$error\n", 'can connect database' );

    my @messages = (
        {
            datetime   => '2012-02-13 15:09:16',
            message_id => '1RwtmW-000MsX-CK',
            flag       => '<=',
            to_address => '',
            id         => '120213150629.AUCTION_RENEW.926291@whois.somehost.ru',
            text =>
'tpxmuwr@somehost.ru H=mail.somehost.com [84.154.134.45] P=esmtp S=1701 id=120213150629.AUCTION_RENEW.926291@whois.somehost.ru',
        },

        {
            datetime   => '2012-02-13 15:09:17',
            message_id => '1RwtmW-000MsX-CK',
            flag       => '==',
            to_address => 'bswdhpjxorekjaelb@gmail.com',
            id         => '',
            text =>
'bswdhpjxorekjaelb@gmail.com R=dnslookup T=remote_smtp defer (-1): domain matches queue_smtp_domains, or -odqs set',
        },

        {
            datetime   => '2012-02-13 15:11:41',
            message_id => '1RwtmW-000MsX-CK',
            flag       => '**',
            to_address => 'bswdhpjxorekjaelb@gmail.com',
            id         => '',
            text =>
'bswdhpjxorekjaelb@gmail.com R=dnslookup T=remote_smtp: SMTP error from remote mail server after RCPT TO:<bswdhpjxorekjaelb@gmail.com>: host gmail-smtp-in.l.google.com [209.85.137.26]: 550-5.1.1 The email account that you tried to reach does not exist. Please try\\n550-5.1.1 double-checking the recipient\'s email address for typos or\\n550-5.1.1 unnecessary spaces. Learn more at\\n550 5.1.1 http://support.google.com/mail/bin/answer.py?answer=6596 nx10si6357592lab.5',
        },
    );

    ok( $db->insert( 'message', \@messages )
          or die $db->error . "\n",
        'can insert to database' );

    my ( $result, $truncated );
    ( $result, $truncated ) =
      $db->load_for_to_address('bswdhpjxorekjaelb@gmail.com');

    ok( scalar @$result > 0 or die $db->error . "\n", 'can search email' );
    
    $db->close if $db;
}

test_store();
