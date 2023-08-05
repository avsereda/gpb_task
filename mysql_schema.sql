CREATE DATABASE IF NOT EXISTS test;

CREATE USER IF NOT EXISTS 'test'@'%' IDENTIFIED BY 'test';
GRANT ALL PRIVILEGES ON test.* TO 'test'@'%';
FLUSH PRIVILEGES;

USE test;

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
