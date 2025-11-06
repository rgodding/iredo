-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- What should naming structure be?
-- height_in_mm
-- heighinmm

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema marketplace-core
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema marketplace-core
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `marketplace-core` DEFAULT CHARACTER SET utf8mb3 ;
USE `marketplace-core` ;

-- -----------------------------------------------------
-- Table `marketplace-core`.`UserType`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`UserType` (
                                                             `id` INT NOT NULL,
                                                             `usertype` VARCHAR(45) NOT NULL, -- Should it be ENUM? : `usertype` ENUM('user','admin'),
    PRIMARY KEY (`id`),
    UNIQUE INDEX `usertype_UNIQUE` (`usertype` ASC) VISIBLE)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `marketplace-core`.`Users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`Users` (
                                                          `id` INT NOT NULL,
                                                          `phonenumber` VARCHAR(15) NOT NULL,
    `email` VARCHAR(150) NOT NULL,
    `firstname` VARCHAR(50) NOT NULL,
    `lastnames` VARCHAR(150) NOT NULL,
    `password` VARCHAR(100) NOT NULL, -- Should it be in seperate table / Salt & Hash?
    `homestreet` VARCHAR(100) NOT NULL, -- 
    `homestreetnumber` VARCHAR(5) NOT NULL, -- Should street be in seperates, or just have a single line
    `apartment` VARCHAR(10) NULL DEFAULT NULL, --
    `postalcode` VARCHAR(4) NOT NULL, -- Should we add city along with postal code?
    `usertype_id` INT NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `PhoneNumber_UNIQUE` (`phonenumber` ASC) VISIBLE,
    UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE,
    INDEX `usertype_id_idx` (`usertype_id` ASC) VISIBLE,
    CONSTRAINT `usertype_id`
    FOREIGN KEY (`usertype_id`)
    REFERENCES `marketplace-core`.`UserType` (`id`)
    ON DELETE RESTRICT)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `marketplace-core`.`ProductTypes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`ProductTypes` ( -- Should we call it products? Maybe have "ProductTypes" that specifies, Chair, Table, Couch etc.
                                                                 `id` INT NOT NULL,
                                                                 `type` VARCHAR(100) NOT NULL, -- Should this be a foreign key to a types table?
    `brand` VARCHAR(100) NULL DEFAULT NULL,
    `heightinmm` INT NOT NULL,
    `lengthinmm` INT NOT NULL,
    `depthinmm` INT NULL DEFAULT NULL, -- Should it be called Width?
    `model` VARCHAR(100) NULL DEFAULT NULL, -- Specify "modelId/modelName" ?
    `mainmaterial` VARCHAR(100) NULL DEFAULT NULL,
    `maincolor` VARCHAR(30) NULL DEFAULT NULL, -- Should we add additional colors? Maybe add primary or (slightly, a lot, dominant etc.?)
    PRIMARY KEY (`id`))
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `marketplace-core`.`SalesPosts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`SalesPosts` (
                                                               `id` INT NOT NULL,
                                                               `title` VARCHAR(150) NOT NULL DEFAULT '"(Udefineret)"', -- (Undefined)
    `timeposted` TIMESTAMP NOT NULL, -- created_at TIMESTAMP CURRENT_TIMESTAMP,
    `promoted` TINYINT NOT NULL DEFAULT '0', -- Maybe seperate table with promoted Posts?
    `price` FLOAT(9,2) NOT NULL,
    `totalamount` INT NOT NULL DEFAULT '1',
    `soldamount` INT NOT NULL DEFAULT '0',
    `discount` FLOAT(3,2) NULL DEFAULT NULL,
    `condition` VARCHAR(45) NULL DEFAULT NULL, -- Should it be ENUM? ENUM('Perfect', 'Slightly used' etc.)
    `imagesurl` VARCHAR(200) NULL DEFAULT NULL, -- Should this be a table for itself? Id, Name, FileName, Alt?
    `salesstatus` VARCHAR(45) NOT NULL, -- Should this be ENUM?
    `minamountperpurchases` INT NULL DEFAULT NULL,
    `pricesold` FLOAT(9,2) NULL DEFAULT NULL,
    `seller` INT NOT NULL, -- Should this be user_id?
    `product` INT NOT NULL, -- should this be product_id?
    `description` VARCHAR(255) NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `imagesurl_UNIQUE` (`imagesurl` ASC) VISIBLE, -- Should this be seperately?
    INDEX `postedbyuser_idx` (`seller` ASC) VISIBLE,
    INDEX `product_id_idx` (`product` ASC) VISIBLE,
    CONSTRAINT `postedbyuser_id`
    FOREIGN KEY (`seller`)
    REFERENCES `marketplace-core`.`Users` (`id`)
    ON UPDATE CASCADE,
    CONSTRAINT `product_id`
    FOREIGN KEY (`product`)
    REFERENCES `marketplace-core`.`ProductTypes` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
    ENGINE = InnoDB -- Understand this
    DEFAULT CHARACTER SET = utf8mb3; -- 


-- -----------------------------------------------------
-- Table `marketplace-core`.`Auctions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`Auctions` (
                                                             `id` INT NOT NULL,
                                                             `minamountperbiddings` FLOAT(5,2) NOT NULL,
    `status` VARCHAR(45) NOT NULL, -- Should this be ENUM? 
    `salespost` INT NOT NULL, -- salespost_id
    PRIMARY KEY (`id`),
    INDEX `salespost_idx` (`salespost` ASC) VISIBLE,
    CONSTRAINT `salespost_id_auction`
    FOREIGN KEY (`salespost`)
    REFERENCES `marketplace-core`.`SalesPosts` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `marketplace-core`.`Biddings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`Biddings` (
                                                             `id` INT NOT NULL,
                                                             `bidding` FLOAT(7,2) NOT NULL, -- Maybe "Bids"
    `timebid` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `auction` INT NOT NULL, -- "auction_id"
    `userbidding` INT NOT NULL, -- "user_id"
    PRIMARY KEY (`id`),
    INDEX `userbidding_id_idx` (`userbidding` ASC) VISIBLE,
    INDEX `auction_id_idx` (`auction` ASC) VISIBLE,
    CONSTRAINT `auction_id`
    FOREIGN KEY (`auction`)
    REFERENCES `marketplace-core`.`Auctions` (`id`),
    CONSTRAINT `userbidding_id`
    FOREIGN KEY (`userbidding`)
    REFERENCES `marketplace-core`.`Users` (`id`))
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `marketplace-core`.`Blocked`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`Blocked` (
                                                            `id` INT NOT NULL,
                                                            `blockeduser` INT NOT NULL,
                                                            `byuser` INT NOT NULL,
                                                            PRIMARY KEY (`id`),
    INDEX `id_idx` (`blockeduser` ASC) VISIBLE,
    INDEX `byuser_id_idx` (`byuser` ASC) VISIBLE,
    CONSTRAINT `blockeduser_id`
    FOREIGN KEY (`blockeduser`)
    REFERENCES `marketplace-core`.`Users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `byuser_id`
    FOREIGN KEY (`byuser`)
    REFERENCES `marketplace-core`.`Users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `marketplace-core`.`BuyersList`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`BuyersList` (
                                                               `id` INT NOT NULL,
                                                               `interestedbuyer` INT NOT NULL,
                                                               `salespost` INT NOT NULL,
                                                               `status` VARCHAR(100) NOT NULL DEFAULT '"Awaiting seller"',
    `timerequested` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `buyerscomment` VARCHAR(255) NULL DEFAULT NULL,
    `amounttobuy` INT NOT NULL DEFAULT '1',
    PRIMARY KEY (`id`),
    INDEX `salespost_id_idx` (`salespost` ASC) VISIBLE,
    INDEX `buyer_id_idx` (`interestedbuyer` ASC) VISIBLE,
    CONSTRAINT `buyer_id`
    FOREIGN KEY (`interestedbuyer`)
    REFERENCES `marketplace-core`.`Users` (`id`),
    CONSTRAINT `salespost_id_buyerslists`
    FOREIGN KEY (`salespost`)
    REFERENCES `marketplace-core`.`SalesPosts` (`id`))
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `marketplace-core`.`Rooms`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`Rooms` (
                                                          `id` INT NOT NULL,
                                                          `name` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `marketplace-core`.`Product_Rooms`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`Product_Rooms` (
                                                                  `id` INT NOT NULL,
                                                                  `product` INT NOT NULL,
                                                                  `room` INT NOT NULL,
                                                                  PRIMARY KEY (`id`),
    INDEX `room_idx` (`room` ASC) VISIBLE,
    INDEX `product_idx` (`product` ASC) VISIBLE,
    CONSTRAINT `product_id_rooms`
    FOREIGN KEY (`product`)
    REFERENCES `marketplace-core`.`ProductTypes` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `room_id`
    FOREIGN KEY (`room`)
    REFERENCES `marketplace-core`.`Rooms` (`id`))
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `marketplace-core`.`Styles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`Styles` (
                                                           `id` INT NOT NULL,
                                                           `title` VARCHAR(100) NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `title_UNIQUE` (`title` ASC) VISIBLE,
    UNIQUE INDEX `description_UNIQUE` (`description` ASC) VISIBLE)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `marketplace-core`.`Product_Style`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`Product_Style` (
                                                                  `id` INT NOT NULL,
                                                                  `product` INT NOT NULL,
                                                                  `style` INT NOT NULL,
                                                                  PRIMARY KEY (`id`),
    INDEX `product_idx` (`product` ASC) VISIBLE,
    INDEX `style_idx` (`style` ASC) VISIBLE,
    CONSTRAINT `product_id_styles`
    FOREIGN KEY (`product`)
    REFERENCES `marketplace-core`.`ProductTypes` (`id`),
    CONSTRAINT `style_id`
    FOREIGN KEY (`style`)
    REFERENCES `marketplace-core`.`Styles` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `marketplace-core`.`Ratings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`Ratings` (
                                                            `id` INT NOT NULL,
                                                            `stars` INT NOT NULL,
                                                            `note` VARCHAR(255) NULL DEFAULT NULL,
    `ratedbyuser` INT NOT NULL,
    `seller` INT NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `ratinguser_id_idx` (`ratedbyuser` ASC) VISIBLE,
    INDEX `usertorate_id_idx` (`seller` ASC) VISIBLE,
    CONSTRAINT `ratinguser_id`
    FOREIGN KEY (`ratedbyuser`)
    REFERENCES `marketplace-core`.`Users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `usertorate_id`
    FOREIGN KEY (`seller`)
    REFERENCES `marketplace-core`.`Users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `marketplace-core`.`Subscriptions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`Subscriptions` (
                                                                  `id` INT NOT NULL,
                                                                  `usertofollow` INT NOT NULL,
                                                                  `userfollowedby` INT NOT NULL,
                                                                  PRIMARY KEY (`id`),
    INDEX `usertofollow_id_idx` (`usertofollow` ASC) VISIBLE,
    INDEX `userfollowedby_id_idx` (`userfollowedby` ASC) VISIBLE,
    CONSTRAINT `userfollowedby_id`
    FOREIGN KEY (`userfollowedby`)
    REFERENCES `marketplace-core`.`Users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `usertofollow_id`
    FOREIGN KEY (`usertofollow`)
    REFERENCES `marketplace-core`.`Users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `marketplace-core`.`Wishlists`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marketplace-core`.`Wishlists` (
                                                              `id` INT NOT NULL,
                                                              `userslist` INT NOT NULL,
                                                              `salespost` INT NOT NULL,
                                                              `amounttowish` INT NOT NULL DEFAULT '1',
                                                              PRIMARY KEY (`id`),
    INDEX `userslist_id_idx` (`userslist` ASC) VISIBLE,
    INDEX `salespost_id_idx` (`salespost` ASC) VISIBLE,
    CONSTRAINT `salespost_id_wished`
    FOREIGN KEY (`salespost`)
    REFERENCES `marketplace-core`.`SalesPosts` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    CONSTRAINT `userslist_id`
    FOREIGN KEY (`userslist`)
    REFERENCES `marketplace-core`.`Users` (`id`)
    ON UPDATE CASCADE)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8mb3;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
