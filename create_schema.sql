-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
  -- Schema quakes
  -- -----------------------------------------------------
  CREATE SCHEMA IF NOT EXISTS `quakes`;
USE `quakes`;
-- -----------------------------------------------------
  -- Table `quakes`.`Agencies`
  -- -----------------------------------------------------
  DROP TABLE IF EXISTS `quakes`.`Agencies`;
CREATE TABLE IF NOT EXISTS `quakes`.`Agencies` (
    `id` SMALLINT NOT NULL AUTO_INCREMENT,
    `abbreviation` VARCHAR(45) NOT NULL,
    `details` VARCHAR(250) NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `abbreviation_UNIQUE` (`abbreviation` ASC) VISIBLE
  ) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARACTER SET = utf8;
-- -----------------------------------------------------
  -- Table `quakes`.`Alerts`
  -- -----------------------------------------------------
  DROP TABLE IF EXISTS `quakes`.`Alerts`;
CREATE TABLE IF NOT EXISTS `quakes`.`Alerts` (
    `id` TINYINT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE
  ) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARACTER SET = utf8;
-- -----------------------------------------------------
  -- Table `quakes`.`Contributed`
  -- -----------------------------------------------------
  DROP TABLE IF EXISTS `quakes`.`Contributed`;
CREATE TABLE IF NOT EXISTS `quakes`.`Contributed` (
    `agency` SMALLINT NOT NULL,
    `event_global_id` INT NOT NULL,
    PRIMARY KEY (`agency`, `event_global_id`),
    CONSTRAINT `fk_Contributed_Agencies` FOREIGN KEY (`agency`) REFERENCES `quakes`.`Agencies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
  ) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8;
-- -----------------------------------------------------
  -- Table `quakes`.`IdMap`
  -- -----------------------------------------------------
  DROP TABLE IF EXISTS `quakes`.`IdMap`;
CREATE TABLE IF NOT EXISTS `quakes`.`IdMap` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `local_id` VARCHAR(45) NOT NULL,
    `global_id` INT NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `local_id_UNIQUE` (`local_id` ASC) VISIBLE
  ) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARACTER SET = utf8;
-- -----------------------------------------------------
  -- Table `quakes`.`MagnitudeTypes`
  -- -----------------------------------------------------
  DROP TABLE IF EXISTS `quakes`.`MagnitudeTypes`;
CREATE TABLE IF NOT EXISTS `quakes`.`MagnitudeTypes` (
    `id` TINYINT NOT NULL AUTO_INCREMENT,
    `id_type` TINYINT NOT NULL,
    `name` VARCHAR(5) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE
  ) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARACTER SET = utf8;
-- -----------------------------------------------------
  -- Table `quakes`.`Status`
  -- -----------------------------------------------------
  DROP TABLE IF EXISTS `quakes`.`Status`;
CREATE TABLE IF NOT EXISTS `quakes`.`Status` (
    `id` TINYINT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE
  ) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARACTER SET = utf8;
-- -----------------------------------------------------
  -- Table `quakes`.`Events`
  -- -----------------------------------------------------
  DROP TABLE IF EXISTS `quakes`.`Events`;
CREATE TABLE IF NOT EXISTS `quakes`.`Events` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `magnitude` DECIMAL(3, 1) NULL DEFAULT NULL,
    `place` VARCHAR(250) NULL DEFAULT NULL,
    `time` DATETIME NULL DEFAULT NULL,
    `updated` DATETIME NULL DEFAULT NULL,
    `timezone_offset` SMALLINT NULL DEFAULT NULL,
    `url` VARCHAR(250) NULL DEFAULT NULL,
    `detail` VARCHAR(250) NULL DEFAULT NULL,
    `felt` INT NULL DEFAULT NULL,
    `cdi` FLOAT NULL DEFAULT NULL,
    `mmi` FLOAT NULL DEFAULT NULL,
    `alert` TINYINT NULL DEFAULT NULL,
    `status` TINYINT NULL DEFAULT NULL,
    `tsunami` TINYINT NULL DEFAULT NULL,
    `significance` INT NULL DEFAULT NULL,
    `network` SMALLINT NOT NULL,
    `n_stations` INT NULL DEFAULT NULL,
    `dmin` FLOAT NULL DEFAULT NULL,
    `rms` FLOAT NULL DEFAULT NULL,
    `gap` FLOAT NULL DEFAULT NULL,
    `magnitude_type` TINYINT NULL DEFAULT NULL,
    `title` VARCHAR(250) NULL DEFAULT NULL,
    `longitude` DECIMAL(16, 13) NULL DEFAULT NULL,
    `latitude` DECIMAL(16, 13) NULL DEFAULT NULL,
    `depth` DECIMAL(16, 13) NULL DEFAULT NULL,
    `local_id` INT NOT NULL,
    `types` VARCHAR(250) NULL DEFAULT NULL,
    `code` VARCHAR(45) NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    INDEX `fk_Events_Alerts_idx` (`alert` ASC) VISIBLE,
    INDEX `fk_Events_StatusNames_idx` (`status` ASC) VISIBLE,
    INDEX `fk_Events_MagnitudeTypes_idx` (`magnitude_type` ASC) VISIBLE,
    INDEX `fk_Events_IdMap_idx` (`local_id` ASC) VISIBLE,
    INDEX `fk_Events_Agencies_idx` (`network` ASC) VISIBLE,
    CONSTRAINT `fk_Events_Agencies` FOREIGN KEY (`network`) REFERENCES `quakes`.`Agencies` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_Events_Alerts` FOREIGN KEY (`alert`) REFERENCES `quakes`.`Alerts` (`id`) ON UPDATE CASCADE,
    CONSTRAINT `fk_Events_IdMap` FOREIGN KEY (`local_id`) REFERENCES `quakes`.`IdMap` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_Events_MagnitudeTypes` FOREIGN KEY (`magnitude_type`) REFERENCES `quakes`.`MagnitudeTypes` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_Events_Status` FOREIGN KEY (`status`) REFERENCES `quakes`.`Status` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
  ) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARACTER SET = utf8;
-- -----------------------------------------------------
  -- Placeholder table for view `quakes`.`ViewForViz`
  -- -----------------------------------------------------
  CREATE TABLE IF NOT EXISTS `quakes`.`ViewForViz` (`id` INT);
-- -----------------------------------------------------
  -- View `quakes`.`ViewForViz`
  -- -----------------------------------------------------
  DROP TABLE IF EXISTS `quakes`.`ViewForViz`;
DROP VIEW IF EXISTS `quakes`.`ViewForViz`;
CREATE
  OR REPLACE VIEW ViewForViz AS WITH MagTypeHelper AS (
    SELECT
      m.id_type AS id_type,
      m.name AS name
    FROM
      (
        SELECT
          m.id_type AS id_type,
          m.name AS name,
          ROW_NUMBER() OVER(
            PARTITION BY m.id_type
            ORDER BY
              m.name
          ) AS rankcol
        FROM
          MagnitudeTypes m
      ) m
    WHERE
      m.rankcol = 1
  ),
  MagIdToName AS (
    SELECT
      t1.id AS id,
      t2.name AS name
    FROM
      MagnitudeTypes t1
      JOIN MagTypeHelper t2 ON t1.id_type = t2.id_type
  ),
  AgencyAndScore AS (
    SELECT
      a.id,
      a.abbreviation as abb,
      COUNT(e.id) as score
    FROM
      Agencies a
      LEFT JOIN Events e ON a.id = e.network
    GROUP BY
      a.id,
      a.abbreviation
  ),
  EventHelper AS (
    SELECT
      im.global_id AS id,
      e.longitude AS longitude,
      e.latitude as latitude,
      e.depth as depth,
      e.magnitude AS magnitude,
      m.name AS magnitude_type,
      e.gap AS gap,
      e.rms AS rms,
      e.dmin AS dmin,
      e.mmi AS mmi,
      e.cdi AS cdi,
      e.n_stations AS n_stations,
      e.felt AS felt,
      e.significance AS significance,
      e.tsunami AS marine,
      al.name AS alert,
      s.name as status,
      e.time AS time,
      e.updated AS updated,
      e.timezone_offset as timezone_offset,
      aas.abb AS network,
      ROW_NUMBER() OVER(
        PARTITION BY im.global_id
        ORDER BY
          aas.SCORE DESC
      ) as rankcol
    FROM
      Events e
      LEFT JOIN IdMap im ON e.local_id = im.id
      LEFT JOIN AgencyAndScore aas ON e.network = aas.id
      LEFT JOIN Status s ON e.status = s.id
      LEFT JOIN Alerts al ON e.alert = al.id
      LEFT JOIN MagIdToName m ON e.magnitude_type = m.id
  )
SELECT
  e.id AS id,
  e.longitude AS longitude,
  e.latitude as latitude,
  e.depth as depth,
  e.magnitude AS magnitude,
  e.magnitude_type AS magnitude_type,
  e.gap AS gap,
  e.rms AS rms,
  e.dmin AS dmin,
  e.mmi AS mmi,
  e.cdi AS cdi,
  e.n_stations AS n_stations,
  e.felt AS felt,
  e.significance AS significance,
  e.marine AS marine,
  e.alert AS alert,
  e.status as status,
  e.time AS time,
  e.updated AS updated,
  e.timezone_offset as timezone_offset,
  e.network AS network
FROM
  EventHelper e
WHERE
  e.rankcol = 1;
SET
  SQL_MODE = @OLD_SQL_MODE;
SET
  FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET
  UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;