-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Timezone setting
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema quakes
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `quakes` DEFAULT CHARACTER SET utf8 ;
USE `quakes` ;

-- -----------------------------------------------------
-- Table `quakes`.`IdMap`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `quakes`.`IdMap`;

CREATE TABLE IF NOT EXISTS `quakes`.`IdMap` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `local_id` VARCHAR(45) NOT NULL,
  `global_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `local_id_UNIQUE` (`local_id` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `quakes`.`Alerts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `quakes`.`Alerts`;

CREATE TABLE IF NOT EXISTS `quakes`.`Alerts` (
  `id` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `quakes`.`Status`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `quakes`.`Status`;

CREATE TABLE IF NOT EXISTS `quakes`.`Status` (
  `id` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `quakes`.`MagnitudeTypes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `quakes`.`MagnitudeTypes`;

CREATE TABLE IF NOT EXISTS `quakes`.`MagnitudeTypes` (
  `id` TINYINT NOT NULL AUTO_INCREMENT,
  `id_type` TINYINT NOT NULL,
  `name` VARCHAR(5) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `quakes`.`Agencies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `quakes`.`Agencies`;

CREATE TABLE IF NOT EXISTS `quakes`.`Agencies` (
  `id` SMALLINT NOT NULL AUTO_INCREMENT,
  `abbreviation` VARCHAR(45) NOT NULL,
  `details` VARCHAR(250) NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `abbreviation_UNIQUE` (`abbreviation` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `quakes`.`Events`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `quakes`.`Events`;

CREATE TABLE IF NOT EXISTS `quakes`.`Events` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `magnitude` DECIMAL(3,1) NULL,
  `place` VARCHAR(250) NULL,
  `time` DATETIME NULL,
  `updated` DATETIME NULL,
  `timezone_offset` SMALLINT NULL,
  `url` VARCHAR(250) NULL,
  `detail` VARCHAR(250) NULL,
  `felt` INT NULL,
  `cdi` FLOAT NULL,
  `mmi` FLOAT NULL,
  `alert` TINYINT NULL,
  `status` TINYINT NULL,
  `tsunami` TINYINT NULL,
  `significance` INT NULL,
  `network` SMALLINT NOT NULL,
  `n_stations` INT NULL,
  `dmin` FLOAT NULL,
  `rms` FLOAT NULL,
  `gap` FLOAT NULL,
  `magnitude_type` TINYINT NULL,
  `title` VARCHAR(250) NULL,
  `longitude` DECIMAL(16,13) NULL,
  `latitude` DECIMAL(16,13) NULL,
  `depth` DECIMAL(16,13) NULL,
  `local_id` INT NOT NULL,
  `types` VARCHAR(250) NULL,
  `code` VARCHAR(45) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Events_Alerts_idx` (`alert` ASC) VISIBLE,
  INDEX `fk_Events_StatusNames_idx` (`status` ASC) VISIBLE,
  INDEX `fk_Events_MagnitudeTypes_idx` (`magnitude_type` ASC) VISIBLE,
  INDEX `fk_Events_IdMap_idx` (`local_id` ASC) VISIBLE,
  INDEX `fk_Events_Agencies_idx` (`network` ASC) VISIBLE,
  UNIQUE INDEX `local_id_UNIQUE` (`local_id` ASC) VISIBLE,
  CONSTRAINT `fk_Events_Alerts`
    FOREIGN KEY (`alert`)
    REFERENCES `quakes`.`Alerts` (`id`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Events_Status`
    FOREIGN KEY (`status`)
    REFERENCES `quakes`.`Status` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Events_MagnitudeTypes`
    FOREIGN KEY (`magnitude_type`)
    REFERENCES `quakes`.`MagnitudeTypes` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Events_IdMap`
    FOREIGN KEY (`local_id`)
    REFERENCES `quakes`.`IdMap` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Events_Agencies`
    FOREIGN KEY (`network`)
    REFERENCES `quakes`.`Agencies` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `quakes`.`Contributed`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `quakes`.`Contributed`;

CREATE TABLE IF NOT EXISTS `quakes`.`Contributed` (
  `agency` SMALLINT NOT NULL,
  `event_global_id` INT NOT NULL,
  PRIMARY KEY (`agency`, `event_global_id`),
  CONSTRAINT `fk_Contributed_Agencies`
    FOREIGN KEY (`agency`)
    REFERENCES `quakes`.`Agencies` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

USE `quakes` ;


-- -----------------------------------------------------
-- Placeholder table for view `quakes`.`events_without_meta`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `quakes`.`events_without_meta` (`global_id` INT, `mag` INT, `mag_type` INT, `time` INT, `tz` INT, `felt` INT, `cdi` INT, `mmi` INT, `alert` INT, `status` INT, `marine` INT, `significance` INT, `network` INT, `n_stations` INT, `dmin` INT, `rms` INT, `gap` INT, `longitude` INT, `latitude` INT, `depth` INT);

-- -----------------------------------------------------
-- View `quakes`.`events_without_meta`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `quakes`.`events_without_meta`;
USE `quakes`;
CREATE  OR REPLACE VIEW `events_without_meta` AS 
SELECT im.global_id AS global_id, e.magnitude AS mag, m.id_type AS mag_type,
		e.time AS time, e.timezone_offset AS tz, felt, cdi, mmi,
        a.name AS alert, s.name AS status, e.tsunami AS marine, significance,
        ag.abbreviation AS agency, n_stations, dmin, rms, gap, longitude, latitude, depth
FROM Events e
	JOIN IdMap im ON e.local_id = im.id
    JOIN Alerts a ON e.alert = a.id
    JOIN Status s ON e.status = s.id
    JOIN MagnitudeTypes m ON e.magnitude_type = m.id
    JOIN Agencies ag ON e.network = ag.id;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
