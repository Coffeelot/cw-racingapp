-- ADD RACE TRACK TABLE (MAKE SURE TO DELETE race_tracks FIRST IF YOU ALREADY HAVE IT FROM QB CORE FOR EXAMPLE!!!!)
-- DROP TABLE IF EXISTS race_tracks;
CREATE TABLE IF NOT EXISTS `race_tracks` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`checkpoints` TEXT NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`metadata` TEXT NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`creatorid` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`creatorname` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`distance` INT(11) NULL DEFAULT NULL,
	`raceid` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`access` TEXT NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`curated` TINYINT(4) NULL DEFAULT '0',
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `raceid` (`raceid`) USING BTREE
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=41
;


-- DROP TABLE IF EXISTS racer_names;
CREATE TABLE IF NOT EXISTS `racer_names` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`citizenid` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`racername` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`lasttouched` TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	`races` INT(11) NOT NULL DEFAULT '0',
	`wins` INT(11) NOT NULL DEFAULT '0',
	`tracks` INT(11) NOT NULL DEFAULT '0',
	`auth` VARCHAR(50) NULL DEFAULT 'racer' COLLATE 'utf8mb4_general_ci',
	`crew` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`createdby` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`revoked` TINYINT(4) NULL DEFAULT '0',
	`ranking` INT(11) NULL DEFAULT '0',
	`active` INT(11) NOT NULL DEFAULT '0',
	`crypto` INT NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `id` (`id`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=47
;

-- Races table
CREATE TABLE IF NOT EXISTS racing_races (
    id INT AUTO_INCREMENT PRIMARY KEY,
    raceId VARCHAR(255) NOT NULL,
    trackId VARCHAR(255) NOT NULL,
    results JSON,
    amountOfRacers INT NOT NULL,
    laps INT NOT NULL,
    hostName VARCHAR(255) NULL,
    maxClass VARCHAR(50) NULL,
    ghosting BOOLEAN NOT NULL DEFAULT FALSE,
    ranked BOOLEAN NOT NULL DEFAULT FALSE,
    reversed BOOLEAN NOT NULL DEFAULT FALSE,
    firstPerson BOOLEAN NOT NULL DEFAULT FALSE,
    automated BOOLEAN NOT NULL DEFAULT FALSE,
    hidden BOOLEAN NOT NULL DEFAULT FALSE,
    silent BOOLEAN NOT NULL DEFAULT FALSE,
    buyIn INT NOT NULL DEFAULT 0,
    data JSON,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_raceId (raceId),
    INDEX idx_trackId (trackId),
    INDEX idx_timestamp (timestamp)
);

-- Track times table
CREATE TABLE IF NOT EXISTS track_times (
    id INT AUTO_INCREMENT PRIMARY KEY,
    trackId VARCHAR(255) NOT NULL,
    racerName VARCHAR(255) NOT NULL,
    carClass VARCHAR(50) NOT NULL,
    vehicleModel VARCHAR(255) NOT NULL,
    raceType VARCHAR(50) NOT NULL,
    time INT NOT NULL,
    reversed BOOLEAN NOT NULL DEFAULT FALSE,
    pbHistory JSON,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_trackId (trackId),
    INDEX idx_racerName (racerName),
    INDEX idx_track_racer_class (trackId, racerName, carClass, raceType, reversed),
    INDEX idx_time (time)
);

CREATE TABLE IF NOT EXISTS `racing_crews` (
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
