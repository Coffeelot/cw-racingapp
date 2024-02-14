CREATE TABLE `racing_crews` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`crew_name` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`members` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`wins` INT(11) NULL DEFAULT NULL,
	`races` INT(11) NULL DEFAULT NULL,
	`rank` INT(11) NULL DEFAULT NULL,
	`founder_name` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`founder_citizenid` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`id`) USING BTREE,
	CONSTRAINT `members` CHECK (json_valid(`members`))
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=17
;
