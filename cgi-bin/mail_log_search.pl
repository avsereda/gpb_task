#! /usr/bin/env perl

use strict;
use warnings;
use utf8;
use v5.24;
use CGI qw(:standart header);
use Mojo::Template;
use Local::SQLStore;

my $DB_DSN      = "DBI:mysql:database=test;host=mariadb"; 
my $DB_USER     = "test";
my $DB_PASSWORD = 'test';

my $q = CGI->new; say $q->header;

my $page_title      = 'MTA log search tool';
my $truncated       = 0;
my $search_result   = [];

if ($q->param) {
    my $email = $q->param('email_address');
    if ($email and $email =~ /^\s*([\w\d+_.-]+@[^\s]+?)\s*$/i) {
        $page_title .= ": (Search result for: ${email})";
        say STDERR 'Debug: ', $page_title;

        my ($db, $error);
        ($db, $error) = Local::SQLStore->new($DB_DSN, 
            user        => $DB_USER, 
            password    => $DB_PASSWORD);

        if ($error) {
            say STDERR "$error\n";
        } else {
            ($search_result, $truncated) = $db->search_to_address($email);
            my $error = $db->error_message;
            if ($error) {
                say STDERR "$error\n";
            }
            $db->close;
        }
    }
}

say Mojo::Template->new(vars => 1)->render(load_template(), {
    title           => $page_title, 
    truncated       => $truncated, 
    search_result   => $search_result});

exit 0;

sub load_template {
    local $/ = undef;
    return <DATA>;
}

__DATA__

<!DOCTYPE html>
<html>
    <head>
        <title><%= $title %></title>
        <style>
            table, td, th {
                border: 1px solid;
            }

            table {
                width: 100%;
                border-collapse: collapse;
            }
        </style>
    </head>
    <body>
        <p>MTA log search tool</p>
        <form method="post" action="#">
            <label for="email_address">*To* email address to search for</label>
            <input type="text" name="email_address" required>
            <button action="submit">Search</button>
        </form>
        <hr/>
        <% if ($truncated) { %>
            The output was truncated. Only 100 entries displayed.
        <% } %>
        <table>
            <tr>
                <th>Timestamp</th>
                <th>Message</th>
            </tr>
            <% for my $row (@$search_result) { %>
                <tr>
                    <td><%= $row->[0] %></td>
                    <td><%= $row->[1] %></td>
                </tr>
            <% } %>
        </table>
    </body>
</html>





