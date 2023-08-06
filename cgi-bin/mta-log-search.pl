#! /usr/bin/env perl

use lib 'lib';
use strict;
use warnings;
use utf8;
use v5.24;
use CGI qw(:standart header -utf8);
use Mojo::Template;
use Local::Store;

# Параметры подключения к базе могут быть указаны прямо тут
# или получены через  переменные окружения (например при запуске
# внутри docker контейнера)

my $DB_DSN      = "DBI:mysql:database=test;host=mariadb";
my $DB_USER     = "test";
my $DB_PASSWORD = 'test';

my $q = CGI->new;
say $q->header("text/html; charset=UTF-8");

my $title         = '';
my $truncated     = 0;
my $error         = '';
my $search_result = [];
my $email         = '';

if ( $q->param ) {

    # Обрабатываем данные формы
    if ( $q->param('email_address') =~ /^\s*([\w\d+_.-]+@[^\s]+?)\s*$/i ) {
        $email = $1;
        $title = 'Результат поиска для ' . $email;
        my ( $db, $error ) = Local::Store->new(
            $DB_DSN,
            user     => $DB_USER,
            password => $DB_PASSWORD,
        );

        if ( $db->error ) {
            $error = $db->error;
        }
        else {
            ( $search_result, $truncated ) = $db->load_for_to_address($email);
            if ( $db->error ) {
                $error = $db->error;
            }
        }

        $db->close if $db;
    }
}

say Mojo::Template->new( vars => 1 )->render(
    load_template(),
    {
        title         => $title,
        error         => $error,
        truncated     => $truncated,
        search_result => $search_result,
        email         => $email,
    }
);

exit 0;

sub load_template {
    local $/ = undef;
    return <DATA>;
}

__DATA__

<!DOCTYPE html>
<html lang="ru">
<head>
  <title><%= $title %></title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="/dist/css/bootstrap.min.css">
  <script src="/dist/js/jquery-3.7.0.min.js"></script>
  <script src="/dist/js/bootstrap.bundle.min.js"></script>
  <style>
  </style>
</head>
<body>
<div class="container">
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <div class="container-fluid">
            <div class="collapse navbar-collapse" id="nav">
                <form class="d-flex w-100" method="post" action="#">
                    <input class="form-control me-2" type="search" name="email_address" placeholder="foo@example.com" required>
                    <button class="btn btn-outline-success" type="submit">Поиск</button>
                </form>
            </div>
        </div>
    </nav>
    <% if ($error) { %>
        <div class="alert alert-danger alert-dismissible fade show m-3" role="alert">
            <strong>Ой</strong> При обработке запроса произошла ошибка <%= $error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ($truncated) { %>
        <div class="alert alert-warning m-3" role="alert">
            Показаны не все доступные записи 
        </div>
    <% } %>
    <% if ($email and not scalar @$search_result) { %>
        <div class="alert alert-dark m-3" role="alert">
            Ничего не найдено
        </div>
    <% } elsif (not $email) { %>
        <h4 class="m-5">Введите адрес получателя в поисковой строке выше</h4>
    <% } else { %>
        <h4>Результат поиска для <b><%= $email %></b></h4>
        <table class="table table-sm">
            <thead>
                <tr>
                    <th scope="col">Дата Время</th>
                    <th scope="col">Текст сообщения</th>
                </tr>
            </thead>
            <tbody>
                <% for my $row (@$search_result) { %>
                    <% if ($row->[2] eq '**') { %>
                        <tr class="table-danger">
                            <td><%= $row->[0] %></td>
                            <td><%= $row->[5] %></td>
                        </tr>
                    <% } else { %>
                        <tr>
                            <td><%= $row->[0] %></td>
                            <td><%= $row->[5] %></td>
                        </tr>
                    <% } %>
                <% } %>
            </tbody>
        </table>
    <% } %>
</div>
</body>
</html>
