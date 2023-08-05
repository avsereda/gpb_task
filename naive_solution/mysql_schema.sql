CREATE DATABASE IF NOT EXISTS test;

CREATE USER IF NOT EXISTS 'test'@'%' IDENTIFIED BY 'test';
GRANT ALL PRIVILEGES ON test.* TO 'test'@'%';
FLUSH PRIVILEGES;

USE test;

CREATE TABLE IF NOT EXISTS `message` (
  `id` text NOT NULL,
  `created` datetime NOT NULL,
  `int_id` tinytext NOT NULL,
  `str` text NOT NULL,
  `status` int(1) DEFAULT NULL,
  PRIMARY KEY (`id`(256)),
  KEY `message_created_idx` (`created`),
  KEY `message_int_id_idx` (`int_id`(16))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `log` (
  `_id` int(11) NOT NULL AUTO_INCREMENT,
  `created` datetime NOT NULL,
  `int_id` tinytext NOT NULL,
  `str` text NOT NULL,
  `address` text NOT NULL,
  PRIMARY KEY (`_id`),
  KEY `log_address_idx` (`address`(64)) USING HASH
) ENGINE=InnoDB  AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;