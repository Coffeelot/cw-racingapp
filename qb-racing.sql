-- CHOOSE ONE OF THE TWO SECTIONS BELOW TO SETUP YOUR DATABASE TABLE
-- IF YOU DONT KNOW WHAT THIS IS OR MEANS DO NOT TOUCH YOUR DATABASE

-- OPTION 1
-- Use these queries on your database if you are converting your existing qb-lapraces table to qb-racing
-- This will conserve all tracks previously created
ALTER TABLE `lapraces` RENAME TO `race_tracks`;
ALTER TABLE `race_tracks` RENAME COLUMN `creator` TO `creatorid`;
ALTER TABLE `race_tracks` ADD COLUMN `creatorname` VARCHAR(50) NULL DEFAULT 'Unknown' AFTER `creatorid`;

-- OPTION 2
-- Use this if you have not used qb-lapraces and dont have races to convert
CREATE TABLE IF NOT EXISTS `race_tracks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `checkpoints` text DEFAULT NULL,
  `records` text DEFAULT NULL,
  `creatorid` varchar(50) DEFAULT NULL,
  `creatorname` varchar(50) DEFAULT NULL,
  `distance` int(11) DEFAULT NULL,
  `raceid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
