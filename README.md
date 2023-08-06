# Тестовое задание

Выполнить разбор файла почтового лога, залить данные в БД и организовать поиск по адресу получателя.

## Исходные данные:

- Файл лога maillog
- Схема таблиц в БД (допускается использовать postgresql или mysql):

```SQL
CREATE TABLE message (
    created TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    id VARCHAR NOT NULL,
    int_id CHAR(16) NOT NULL,
    str VARCHAR NOT NULL,
    status BOOL,
    CONSTRAINT message_id_pk PRIMARY KEY(id)
);

CREATE INDEX message_created_idx ON message (created);
CREATE INDEX message_int_id_idx ON message (int_id);

CREATE TABLE log (
    created TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    int_id CHAR(16) NOT NULL,
    str VARCHAR,
    address VARCHAR
);

CREATE INDEX log_address_idx ON log USING hash (address);
```

## Пояснения:

В качестве разделителя в файле лога используется символ пробела.
Значения первых полей:
- дата
- время
- внутренний id сообщения
- флаг
- адрес получателя (либо отправителя)
- другая информация

В качестве флагов используются следующие обозначения:

- `<=` прибытие сообщения (в этом случае за флагом следует адрес отправителя)
- `=>` нормальная доставка сообщения
- `->` дополнительный адрес в той же доставке
- `**` доставка не удалась
- `==` доставка задержана (временная проблема)

В случаях, когда в лог пишется общая информация, флаг и адрес получателя не указываются.

## Задачи:

1. Выполнить разбор предлагаемого файла лога с заполнением таблиц БД:

В таблицу message должны попасть только строки прибытия сообщения (с флагом <=). Поля таблицы
должны содержать следующую информацию:

- `created` - timestamp строки лога
- `id` - значение поля id=xxxx из строки лога
- `int_id` - внутренний id сообщения
- `str` - строка лога (без временной метки)

В таблицу log записываются все остальные строки:
- `created` - timestamp строки лога
- `int_id` - внутренний id сообщения
- `str` - строка лога (без временной метки)
- `address` - адрес получателя

2. Создать html-страницу с поисковой формой, содержащей одно поле (`type="text"`) для ввода адреса получателя.
Результатом отправки формы должен являться список найденных записей `<timestamp>` `<строка лога>` из двух
таблиц, отсортированных по идентификаторам сообщений (`int_id`) и времени их появления в логе.
Отображаемый результат необходимо ограничить сотней записей, если количество найденных строк превышает
указанный лимит, должно выдаваться соответствующее сообщение.

# Мое решение

В каталоге `naive_solution` представлен код, который решает те компоненты задачи, которые описаны в ТЗ.
Для удобства демо версия может быть запущена через docker compose.
Однако, на мой взгляд, в ТЗ не указан рад моментов. А именно, как именно будет запускаться код,
который будет проводить разбор файла журнала и наполнение базы. На мой взгляд возможным решением
может быть запуск данного кода как postrotate процедуры (См. logrotate(8)). 

Данное решение позволит выполнять регулярный запуск кода анализатора журнала. 
При этом администратор сохраняет возможность  ручного запуска, передав файл(ы) журанала в качетве аргумента командной строки.

Таким образом анализатор может быть запущен из исполняемого файла `bin/mta-log-parser.pl`.
Сам анализатор реализован в виде perl модуля. Web сервер реализован в виде docker контейнера.
База может быть так же развернута на базе docker контейнера, либо может использовать уже существующая база данных.
SQL скрипт необходимый для настройки базы: `mysql_schema.sql`. Для удобства запуска приложения в составе 
проекта находится `docker-compose.yml` файл. Который позволит собрать контейнер с web сервером, запустить базу и web сервер.

## Схема базы

На мой взгляд предложенная в ТЗ схема усложняет анализатор. Так же в ней есть потенциальные проблемы с 
вставкой данных если по какой-то причине значения полей id= сообщений будут не уникальными. Моя схема база следующая:

```
CREATE TABLE IF NOT EXISTS `message` (
  `seq` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `message_id` varchar(16) NOT NULL,
  `flag` varchar(2) NOT NULL,
  `to_address` varchar(256) NOT NULL,
  `id` varchar(998) NOT NULL,
  `text` text NOT NULL,
  PRIMARY KEY (`seq`),
  KEY `to_address_idx` (`to_address`(256))
) ENGINE=InnoDB  AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

Данная схема практически полностью отражает структуру полей журнала. При этом допускает неуникальные значения
id= сообщений. В текущей схеме индекс создан только для поля `to_address`, 
так как мы будем искать только по адресу получателя. Размеры полей `to_address` выбраны на основании RFC 3696. 

 >  In addition to restrictions on syntax, there is a length limit on
 >  email addresses.  That limit is a maximum of 64 characters (octets)
 >  in the "local part" (before the "@") and a maximum of 255 characters
 >  (octets) in the domain part (after the "@") for a total length of 320
 >  characters. However, there is a restriction in RFC 2821 on the length of an
 >  address in MAIL and RCPT commands of 256 characters.  Since addresses
 >  that do not fit in those fields are not normally useful, the upper
 >  limit on address lengths should normally be considered to be 256.

Что касается размера поля id, то его размер ограничен макимальной длинной строки в email сообщении.

> Each line of characters MUST be no more than 998 characters, 
> and SHOULD be no more than 78 characters, excluding the CRLF.

## Структура проекта 

Все модули, содержащиеся в составе проекта расположены `lib`.

- bin/mta-log-parser.pl - скрипт для запуска анализатора
- lib/Local/LogParser.pm - основной код анализатора
- lib/Local/Misc.pm - вспомогательные функции
- lib/Local/Store.pm - модуля для работы с базой данных

# Документация

Документация публичного интерфейса ко всем модулям оформлена с помощью POD.
Для просмотра документации по любому компоненту проекта нужно использовать следующую команду (пример):

```
pod2man -u bin/mta-log-parser.pl | preconv |  groff -Tutf8 -man | less
```

Для всех элементов интерфейса, которые не являются частью публичного API 
написаны комментарии в свободной форме.

## Зависимости

Все зависимости необходимые для работы внутри docker будут автоматически добавлены при сборке оброза.
Для работы анализатора нужны пакет DBI и поддержка MySQL для DBI. Данные пакеты могут быть установлены из 
репозитория дистрибутива. Например:

```
apt install libdbi-perl libdbd-mysql-perl
```

## Тесты 

Все юнит тесты расположены в каталоге `t`. Для запуска тестов необходимо выполнить 
следующую команду в корне проекта:

```
prove t/
```

Утилиита `prove` поставляется вместе с perl и не требует отдельной установки.

## Оформление кода и стиль

Весь код отформатирован с помощью `perltidy` (Используются настройки "по-умолчанию").
См. `perlstyle(1)`

## Скриншоты

Нормальный вывод

![Alt text](/assets/screenshots/screen_01.png?raw=true)

Пример вывода сообщение с неудавшейся доставкой

![Alt text](/assets/screenshots/screen_02.png?raw=true)

Пример сообщения информирующего о том, что вывод усечен

![Alt text](/assets/screenshots/screen_03.png?raw=true)