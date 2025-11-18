-- Database: marketplace_corev5
DROP DATABASE IF EXISTS marketplace_corev5;
CREATE DATABASE marketplace_corev5;
USE marketplace_corev5;

-- USER RELATED TABLES
-- ----------------------------------------
-- Table `user_roles`
-- Description: Defines different roles for users
-- ----------------------------------------
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `role` ENUM('admin', 'private_user', 'organization') NOT NULL UNIQUE
);

-- ----------------------------------------
-- Table `users`
-- Description: Main user table with essential authentication details
-- ----------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `role_id` INT NOT NULL,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE, -- Indicates if the user account is active / deleted
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_role` FOREIGN KEY (`role_id`) REFERENCES `user_roles`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

-- ----------------------------------------
-- Table `user_details`
-- Description: Separate table for user personal details
-- ----------------------------------------
DROP TABLE IF EXISTS `user_details`;
CREATE TABLE `user_details` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `date_of_birth` DATE NOT NULL,
    `phone_number` VARCHAR(15) NOT NULL UNIQUE,
    `address` VARCHAR(255) NOT NULL,
    `postal_code` VARCHAR(20) NOT NULL,
    `city` VARCHAR(100) NOT NULL,
    `user_id` INT NOT NULL,
    CONSTRAINT `fk_user_for_details` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- USER FUNCTIONALITY TABLES
-- ----------------------------------------
-- Table `Ratings`
-- Description: User ratings and reviews
-- ----------------------------------------
DROP TABLE IF EXISTS `ratings`;
CREATE TABLE `ratings` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `rating` INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    `review` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `rated_user_id` INT NOT NULL,
    `rating_user_id` INT NOT NULL,
    CONSTRAINT `fk_rater` FOREIGN KEY (`rating_user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `fk_ratee` FOREIGN KEY (`rated_user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    UNIQUE KEY `uniq_rater_ratee` (`rating_user_id`, `rated_user_id`),
    INDEX `idx_rater_id` (`rating_user_id`),
    INDEX `idx_ratee_id` (`rated_user_id`)
);

-- ----------------------------------------
-- Table `user_follows`
-- Description: Users following other users
-- ----------------------------------------
DROP TABLE IF EXISTS `user_follows`;
CREATE TABLE `user_follows` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `followed_user_id` INT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_follower` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `fk_followed_user` FOREIGN KEY (`followed_user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    UNIQUE KEY `uniq_user_follow` (`user_id`, `followed_user_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_followed_user_id` (`followed_user_id`)
);

-- PRODUCT RELATED TABLES
-- ----------------------------------------
-- Table `products`
-- Description: Stores product specifications and details
-- ----------------------------------------
DROP TABLE IF EXISTS `listings_products_details`;
DROP TABLE IF EXISTS `listing_images`;
DROP TABLE IF EXISTS `listing_items`;
DROP TABLE IF EXISTS `listings`;
DROP TABLE IF EXISTS `products`;
-- CREATE TABLE `products` (
--    `id` INT PRIMARY KEY AUTO_INCREMENT,
--    `type` VARCHAR(100), -- ENUM('electronics', 'furniture', 'clothing', 'books', 'other') NOT NULL,
--    `brand` VARCHAR(100) NOT NULL,
--    `model` VARCHAR(100) NOT NULL,
--    `height_in_mm` INT NOT NULL,
--    `width_in_mm` INT NOT NULL,
--    `depth_in_mm` INT NOT NULL,
--    `weight_in_grams` INT NOT NULL,
--    `main_material` VARCHAR(100) NOT NULL,
--    `color` VARCHAR(50) NOT NULL,
--    `condition` ENUM('new', 'like new', 'used', 'refurbished') NOT NULL,
--    `description` TEXT
-- );

-- TEST 
CREATE TABLE `products` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `type` VARCHAR(100), -- ENUM('electronics', 'furniture', 'clothing', 'books', 'other') NOT NULL,
    `brand` VARCHAR(100) NOT NULL,
    `model` VARCHAR(100) NOT NULL
);

CREATE TABLE `listings` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `sold_seperately` BOOLEAN NOT NULL DEFAULT TRUE,
    `price` DECIMAL(10,2) NOT NULL -- this is the price of all items if sold together
);




CREATE TABLE `listing_images` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `listing_id` INT NOT NULL,
    `image_url` VARCHAR(255) NOT NULL,
    `is_primary` BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT `fk_listing_for_images` FOREIGN KEY (`listing_id`) REFERENCES `listings`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);



CREATE TABLE `listing_items` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    -- SALE INFORMATION
    `quantity` INT NOT NULL DEFAULT 1,
    `price` DECIMAL(10,2) NOT NULL, -- 100kr
    -- ITEM SPECIFICATIONS
    `height_in_mm` INT NOT NULL,
    `width_in_mm` INT NOT NULL,
    `depth_in_mm` INT NOT NULL,
    `weight_in_kilo_grams` INT NOT NULL,
    `main_material` VARCHAR(100) NOT NULL,
    `color` VARCHAR(50) NOT NULL,
    `condition` ENUM('new', 'like new', 'used', 'refurbished') NOT NULL,
    `description` TEXT
);
CREATE TABLE `listings_products_details` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `product_id` INT NOT NULL,
    `listing_id` INT NOT NULL,
    `listing_item_id` INT NOT NULL,
    CONSTRAINT `fk_listing_for_items` FOREIGN KEY (`listing_id`) REFERENCES `listings`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `fk_product` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `fk_listing_items` foreign key (`listing_item_id`) references `listing_items`(`id`)
    ON DELETE cascade
    ON UPDATE cascade
);
-- ----------------------------------------
-- Table `wishlists`
-- Description: Users' wishlists for products
-- ----------------------------------------
DROP TABLE IF EXISTS `wishlists`;
CREATE TABLE `wishlists` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- -----------------------------------------
-- Table `wishlist_items`
-- Description: Items in users' wishlists
-- -----------------------------------------
DROP TABLE IF EXISTS `wishlist_items`;
CREATE TABLE `wishlist_items` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `wishlist_id` INT NOT NULL,
    `listing_id` INT NOT NULL,
    `added_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_wishlist` FOREIGN KEY (`wishlist_id`) REFERENCES `wishlists`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `fk_wishlist_item_listing` FOREIGN KEY (`listing_id`) REFERENCES `listings`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    UNIQUE KEY `uniq_wishlist_listing` (`wishlist_id`, `listing_id`),
    INDEX `idx_wishlist_id` (`wishlist_id`),
    INDEX `idx_listing_id` (`listing_id`)
);

-- ----------------------------------------
-- Table `user_blocks`
-- Description: Users blocking other users
-- ----------------------------------------
DROP TABLE IF EXISTS `user_blocks`;
CREATE TABLE `user_blocks` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `blocked_user_id` INT NOT NULL,
    `blocked_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_blocker` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `fk_blocked_user` FOREIGN KEY (`blocked_user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    UNIQUE KEY `uniq_user_block` (`user_id`, `blocked_user_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_blocked_user_id` (`blocked_user_id`)
);


-- Trigger, if discount is added on listing_item, discounted price is calculated automatically and inserted
-- DELIMITER //
-- CREATE TRIGGER trg_before_listing_item_insert
-- BEFORE INSERT ON listing_items
-- FOR EACH ROW
-- BEGIN
--    IF NEW.discount_percentage IS NOT NULL AND NEW.discount_percentage > 0 THEN
--        SET NEW.discounted_price = NEW.price - (NEW.price * NEW.discount_percentage / 100);
--    ELSE
--        SET NEW.discounted_price = NEW.price;
--    END IF;
-- END //
-- DELIMITER ;


-- ----------------------------------------
-- Table `archived_products`
-- Description: Archived products for historical data
-- ----------------------------------------
-- DROP TABLE IF EXISTS `archived_products`; 

-- LISTING RELATED TABLES
-- ----------------------------------------
-- Table `listings`
-- Description: Marketplace listings for products
-- ----------------------------------------
-- DROP TABLE IF EXISTS `listings`;
-- CREATE TABLE `listings` (
--    `id` INT PRIMARY KEY AUTO_INCREMENT,
--    `price` DECIMAL(10,2) NOT NULL,
--    `total_stock` INT NOT NULL DEFAULT 1,
--    `total_sold` INT NOT NULL DEFAULT 0,
--    `available_stock` INT NOT NULL DEFAULT 1,
--    `discount_percentage` DECIMAL(5,2) DEFAULT 0,
--    `min_amount_per_order` INT NOT NULL DEFAULT 1,
--    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--    `description` TEXT,
--    `product_id` INT NOT NULL,
--    `user_id` INT NOT NULL,
--    CONSTRAINT `fk_product` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
--    ON DELETE CASCADE
--    ON UPDATE CASCADE,
--    CONSTRAINT `fk_seller` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
--    ON DELETE RESTRICT
--    ON UPDATE CASCADE
-- );

-- ----------------------------------------
-- Table `archived_listings`
-- Description: Archived listings for historical data
-- ----------------------------------------
DROP TABLE IF EXISTS `archived_listings`; 
CREATE TABLE `archived_listings` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `original_listing_id` INT NOT NULL,
    `price` DECIMAL(10,2) NOT NULL,
    `total_stock` INT NOT NULL,
    `total_sold` INT NOT NULL,
    `available_stock` INT NOT NULL,
    `discount_percentage` DECIMAL(5,2),
    `min_amount_per_order` INT NOT NULL,
    `description` TEXT,
    `created_at` TIMESTAMP,
    `archived_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Product reference, and archived product reference
    `product_id` INT, -- Can be NULL if the product is deleted later on
    `user_id` INT NOT NULL,
    -- Original product can be tracked even if deleted later on
    CONSTRAINT `fk_archived_listing_original_product`
    FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
    -- Archived product reference
    CONSTRAINT `fk_archived_listing_product`
    FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    -- User reference
    CONSTRAINT `fk_archived_listing_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    INDEX `idx_original_listing` (`original_listing_id`)
); -- TODO ASK: Should we delete tabel and have attributes instead with simmple index?


-- Table `auctions`
-- Description: Auctions for listings, allowing competitive bidding
-- ----------------------------------------
DROP TABLE IF EXISTS `auctions`;
CREATE TABLE `auctions` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `starting_bid` DECIMAL(10,2) NOT NULL,
    `current_bid` DECIMAL(10,2),
    `status` ENUM('active', 'closed', 'cancelled', 'scheduled') NOT NULL DEFAULT 'scheduled',
    `start_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `end_time` TIMESTAMP NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `listing_id` INT NOT NULL,
    CONSTRAINT `fk_listing` FOREIGN KEY (`listing_id`) REFERENCES `listings`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    INDEX `idx_listing_id` (`listing_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_end_time` (`end_time`),
    INDEX `idx_listing_status` (`listing_id`, `status`)
);

-- -----------------------------------------
-- Table `bids`
-- Description: Bids placed by users on auctions
-- -----------------------------------------
DROP TABLE IF EXISTS `bids`;
CREATE TABLE `bids` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `bid_amount` DECIMAL(10,2) NOT NULL,
    `bid_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `auction_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    CONSTRAINT `fk_auction` FOREIGN KEY (`auction_id`) REFERENCES `auctions`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `fk_user_bidder` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    INDEX `idx_auction_id` (`auction_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_auction_bid_amount` (`auction_id`, `bid_amount` DESC)
);

-- -----------------------------------------
-- Table `interested_buyers`
-- Description: Users who have expressed interest in a listing
-- -----------------------------------------
DROP TABLE IF EXISTS `interested_buyers`;
CREATE TABLE `interested_buyers` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `listing_id` INT NOT NULL,
    `time_registered` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `buyers_comments` TEXT,
    `amount_to_buy` INT NOT NULL DEFAULT 1 CHECK (`amount_to_buy` > 0),
    CONSTRAINT `fk_interested_user` FOREIGN KEY (`user_id`) REFERENCES `users`
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `fk_interested_listing` FOREIGN KEY (`listing_id`) REFERENCES `listings`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    UNIQUE KEY `uniq_user_listing` (`user_id`, `listing_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_listing_id` (`listing_id`),
    INDEX `idx_user_listing` (`user_id`, `listing_id`)
);

-- ROOM RELATED TABLES
-- -----------------------------------------
-- Table `rooms`
-- Description: Simulation of a room where products can be showcased
-- -----------------------------------------
DROP TABLE IF EXISTS `rooms`;
CREATE TABLE `rooms` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `room_name` VARCHAR(100) NOT NULL,
    `user_id` INT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_room_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- -----------------------------------------
-- Table `product_rooms`
-- Description: Many-to-many relationship between products and rooms
-- -----------------------------------------
DROP TABLE IF EXISTS `products_rooms`;
CREATE TABLE `products_rooms` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `product_id` INT NOT NULL,
    `room_id` INT NOT NULL,
    CONSTRAINT `fk_pr_product` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `fk_pr_room` FOREIGN KEY (`room_id`) REFERENCES `rooms`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    UNIQUE KEY `uniq_product_room` (`product_id`, `room_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_room_id` (`room_id`)
);

-- --------------------------------------------
-- Table `styles`
-- Description: Styles applied to products
-- --------------------------------------------
DROP TABLE IF EXISTS `styles`;
CREATE TABLE `styles` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


-- --------------------------------------------
-- Table `product_styles`
-- Description: Many-to-many relationship between products and styles
-- --------------------------------------------
DROP TABLE IF EXISTS `products_styles`;
CREATE TABLE `products_styles` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `product_id` INT NOT NULL,
    `style_id` INT NOT NULL,
    CONSTRAINT `fk_ps_product` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `fk_ps_style` FOREIGN KEY (`style_id`) REFERENCES `styles`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    UNIQUE KEY `uniq_product_style` (`product_id`, `style_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_style_id` (`style_id`)
);

-- --------------------------------------------------
-- Seed data: user roles, users (20+), products, listings
-- Each user will have between 0 and 5 listings (assigned below)
-- Text is in Danish except for image_url which is NULL
-- --------------------------------------------------

-- Add user_id to listings so we can assign listings to users
ALTER TABLE `listings` ADD COLUMN `user_id` INT NOT NULL;
ALTER TABLE `listings` ADD CONSTRAINT `fk_listing_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- Roles
INSERT INTO `user_roles` (`id`, `role`) VALUES
 (1, 'admin'),
 (2, 'private_user'),
 (3, 'organization');

-- Users (20)
INSERT INTO `users` (`id`, `role_id`, `username`, `email`, `password_hash`, `is_active`) VALUES
 (1, 1, 'anders_hansen', 'anders.hansen@example.com', '$2b$12$seededhash', TRUE),
 (2, 2, 'maria_pedersen', 'maria.pedersen@example.com', '$2b$12$seededhash', TRUE),
 (3, 2, 'lars_jensen', 'lars.jensen@example.com', '$2b$12$seededhash', TRUE),
 (4, 2, 'sara_sorensen', 'sara.sorensen@example.com', '$2b$12$seededhash', TRUE),
 (5, 2, 'peter_nielsen', 'peter.nielsen@example.com', '$2b$12$seededhash', TRUE),
 (6, 3, 'emma_olsen', 'emma.olsen@example.com', '$2b$12$seededhash', TRUE),
 (7, 2, 'kristian_frederiksen', 'kristian.f@example.com', '$2b$12$seededhash', TRUE),
 (8, 2, 'anna_larsen', 'anna.larsen@example.com', '$2b$12$seededhash', TRUE),
 (9, 2, 'ole_karlsen', 'ole.karlsen@example.com', '$2b$12$seededhash', TRUE),
 (10, 2, 'ida_steen', 'ida.steen@example.com', '$2b$12$seededhash', TRUE),
 (11, 2, 'jonas_ahl', 'jonas.ahl@example.com', '$2b$12$seededhash', TRUE),
 (12, 2, 'nina_bang', 'nina.bang@example.com', '$2b$12$seededhash', TRUE),
 (13, 2, 'morten_vejl', 'morten.vejl@example.com', '$2b$12$seededhash', TRUE),
 (14, 2, 'lina_roman', 'lina.roman@example.com', '$2b$12$seededhash', TRUE),
 (15, 2, 'simon_berg', 'simon.berg@example.com', '$2b$12$seededhash', TRUE),
 (16, 2, 'karin_holm', 'karin.holm@example.com', '$2b$12$seededhash', TRUE),
 (17, 2, 'thomas_priest', 'thomas.priest@example.com', '$2b$12$seededhash', TRUE),
 (18, 2, 'maja_lund', 'maja.lund@example.com', '$2b$12$seededhash', TRUE),
 (19, 2, 'nicolai_rask', 'nicolai.rask@example.com', '$2b$12$seededhash', TRUE),
 (20, 2, 'freja_kristoff', 'freja.kristoff@example.com', '$2b$12$seededhash', TRUE);

-- User details (Danish addresses and names)
INSERT INTO `user_details` (`first_name`, `last_name`, `date_of_birth`, `phone_number`, `address`, `postal_code`, `city`, `user_id`) VALUES
 ('Anders', 'Hansen', '1985-03-12', '+45 20 11 22 33', 'Østerbrogade 12, 2. tv', '2100', 'København Ø', 1),
 ('Maria', 'Pedersen', '1990-07-05', '+45 21 22 33 44', 'Søndergade 5', '8000', 'Aarhus', 2),
 ('Lars', 'Jensen', '1978-11-30', '+45 22 33 44 55', 'Brogade 18', '5000', 'Odense', 3),
 ('Sara', 'Sørensen', '1995-02-20', '+45 23 44 55 66', 'Vestergade 9', '6000', 'Kolding', 4),
 ('Peter', 'Nielsen', '1982-01-17', '+45 24 55 66 77', 'Langgade 3', '9000', 'Aalborg', 5),
 ('Emma', 'Olsen', '1998-09-09', '+45 25 66 77 88', 'Nygade 2', '4300', 'Holbæk', 6),
 ('Kristian', 'Frederiksen', '1987-05-22', '+45 26 77 88 99', 'Torvegade 7', '4000', 'Roskilde', 7),
 ('Anna', 'Larsen', '1992-12-03', '+45 27 88 99 00', 'Strandvej 45', '3000', 'Helsingør', 8),
 ('Ole', 'Karlsen', '1980-04-14', '+45 28 99 00 11', 'Stationsvej 10', '6000', 'Kolding', 9),
 ('Ida', 'Steen', '1993-06-25', '+45 29 00 11 22', 'Møllevej 6', '8000', 'Aarhus', 10),
 ('Jonas', 'Ahl', '1989-08-08', '+45 30 11 22 33', 'Skovvej 1', '2800', 'Lyngby', 11),
 ('Nina', 'Bang', '1996-10-19', '+45 31 22 33 44', 'Engvej 14', '8600', 'Silkeborg', 12),
 ('Morten', 'Vejl', '1975-02-02', '+45 32 33 44 55', 'Fabrikvej 8', '6000', 'Kolding', 13),
 ('Lina', 'Roman', '1991-03-16', '+45 33 44 55 66', 'Havnevej 21', '2100', 'København Ø', 14),
 ('Simon', 'Berg', '1984-12-29', '+45 34 55 66 77', 'Park Alle 4', '7000', 'Fredericia', 15),
 ('Karin', 'Holm', '1997-07-07', '+45 35 66 77 88', 'Bakkevej 2', '5000', 'Odense', 16),
 ('Thomas', 'Priest', '1986-09-30', '+45 36 77 88 99', 'Lindevej 11', '8000', 'Aarhus', 17),
 ('Maja', 'Lund', '1994-01-12', '+45 37 88 99 00', 'Højbro Plads 3', '1200', 'København K', 18),
 ('Nicolai', 'Rask', '1983-05-05', '+45 38 99 00 11', 'Kanalvej 9', '5000', 'Odense', 19),
 ('Freja', 'Kristoff', '1999-11-11', '+45 39 00 11 22', 'Strøget 2', '6000', 'Kolding', 20);

-- Products and Listings
-- We'll create 36 products/listings and distribute them among the 20 users (0-5 per user)

INSERT INTO `products` (`id`, `type`, `brand`, `model`) VALUES
 (1, 'Stol', 'Ikea', 'POÄNG'),
 (2, 'Sofa', 'Ikea', 'KLIPPAN'),
 (3, 'Sofa', 'BoConcept', 'LækkerStofa'),
 (4, 'Sofa', 'Muuto', 'SoftLounge'),
 (5, 'Stol', 'Hay', 'AboutAChair'),
 (6, 'Stol', 'Ikea', 'BARKABODA'),
 (7, 'Reol', 'Ikea', 'MALM'),
 (8, 'Stol', 'Ikea', 'POÄNG-KID'),
 (9, 'Stol', 'Vitra', 'Eames'),
 (10, 'Sofa', 'Søstrene Grene', 'RetroSofa'),
 (11, 'Bord', 'Ikea', 'LACK'),
 (12, 'Sofa', 'BoConcept', 'UrbanSofa'),
 (13, 'Kommode', 'Ikea', 'NORDLI'),
 (14, 'Skab', 'Ikea', 'HEMNES'),
 (15, 'Sofa', 'Muuto', 'ElementSofa'),
 (16, 'Stol', 'Hay', 'MagsChair'),
 (17, 'Stol', 'Ikea', 'POÄNG2'),
 (18, 'Bord', 'BoConcept', 'MiniTable'),
 (19, 'Kasse', 'Ikea', 'EKET'),
 (20, 'Bord', 'Ikea', 'VITTSJÖ'),
 (21, 'Stol', 'Søstrene Grene', 'ClubChair'),
 (22, 'Bænk', 'Ikea', 'TJUSIG'),
 (23, 'Reol', 'Ikea', 'BILLY'),
 (24, 'Sofa', 'BoConcept', 'ClassicChair'),
 (25, 'Bord', 'Muuto', 'FlowTable'),
 (26, 'Hylde', 'Ikea', 'HEMNES-SKAB'),
 (27, 'Gaderopestativ', 'Hay', 'LoopStand'),
 (28, 'TV-bord', 'Ikea', 'FJÄLLBO'),
 (29, 'bord', 'Ikea', 'LINNMON'),
 (30, 'Sofa', 'BoConcept', 'CornerSofa'),
 (31, 'Skammel', 'Ikea', 'INGO'),
 (32, 'Stol', 'Hay', 'PillowChair'),
 (33, 'Bord', 'Ikea', 'RÅSKOG'),
 (34, 'Skammel', 'Muuto', 'Stool'),
 (35, 'Bord', 'Ikea', 'STOCKHOLM'),
 (36, 'Bord', 'BoConcept', 'TablePro');

-- We'll insert listings and assign them to users according to a preset distribution
-- Distribution per user (user_id: count):
-- 1:3, 2:1, 3:0, 4:5, 5:2, 6:0, 7:4, 8:1, 9:0, 10:2, 11:5, 12:0, 13:3, 14:1, 15:0, 16:2, 17:0, 18:1, 19:4, 20:2

INSERT INTO `listings` (`id`, `sold_seperately`, `price`, `user_id`) VALUES
 (1, TRUE, 499.00, 1),
 (2, TRUE, 250.00, 1),
 (3, TRUE, 1200.00, 1),
 (4, TRUE, 800.00, 2),
 (5, TRUE, 150.00, 4),
 (6, TRUE, 75.00, 4),
 (7, TRUE, 220.00, 4),
 (8, TRUE, 60.00, 4),
 (9, TRUE, 3500.00, 4),
 (10, TRUE, 40.00, 5),
 (11, TRUE, 95.00, 5),
 (12, TRUE, 300.00, 7),
 (13, TRUE, 199.00, 7),
 (14, TRUE, 45.00, 7),
 (15, TRUE, 129.00, 7),
 (16, TRUE, 89.00, 8),
 (17, TRUE, 79.00, 10),
 (18, TRUE, 220.00, 10),
 (19, TRUE, 60.00, 11),
 (20, TRUE, 1200.00, 11),
 (21, TRUE, 350.00, 11),
 (22, TRUE, 180.00, 11),
 (23, TRUE, 55.00, 11),
 (24, TRUE, 1299.00, 13),
 (25, TRUE, 399.00, 13),
 (26, TRUE, 450.00, 13),
 (27, TRUE, 39.00, 14),
 (28, TRUE, 220.00, 16),
 (29, TRUE, 89.00, 16),
 (30, TRUE, 2400.00, 18),
 (31, TRUE, 19.00, 19),
 (32, TRUE, 149.00, 19),
 (33, TRUE, 79.00, 19),
 (34, TRUE, 129.00, 19),
 (35, TRUE, 599.00, 20),
 (36, TRUE, 249.00, 20);

-- Listing items (one item per listing, details in Danish)
INSERT INTO `listing_items` (`id`, `quantity`, `price`, `height_in_mm`, `width_in_mm`, `depth_in_mm`, `weight_in_kilo_grams`, `main_material`, `color`, `condition`, `description`) VALUES
 (1, 2, 499.00, 820, 680, 760, 9000, "Læder", "Brun", 'used', 'Flot lænestol i god stand, brugsspor på armlæn.'),
 (2, 1, 250.00, 830, 1420, 880, 20000, "Stof", "Grå", 'like new', 'Komfortabel sofa, ingen pletter.'),
 (3, 1, 1200.00, 900, 2000, 900, 30000, "Læder", "Gul", 'used', 'Stor sofa med patina, perfekt til stuen.'),
 (4, 1, 800.00, 780, 1600, 850, 25000, "Læder", "Brun", 'like new', 'Moderne lounge-sofa, næsten ny.'),
 (5, 1, 150.00, 780, 520, 520, 5000, "Stål", "Sort", 'used', 'Spisebordsstol i god stand.'),
 (6, 1, 75.00, 2000, 600, 600, 8000, "Træ", "Rød", 'used', 'Højt spisebord, nogen ridser i overfladen.'),
 (7, 1, 220.00, 480, 350, 400, 7000, "Træ", "Hvid", 'like new', 'Praktisk lille reol, som ny.'),
 (8, 1, 60.00, 950, 600, 700, 6000, "Træ", "Hvid", 'used', 'Børnestol i god stand.'),
 (9, 5, 3500.00, 850, 2400, 1000, 45000, "Plastik", "Brun", 'like new', 'Designstol i flot stand.'),
 (10, 1, 40.00, 800, 600, 600, 4000, "Træ", "Brun", 'used', 'Pæn retro sofa, mindre pletter.'),
 (11, 1, 95.00, 120, 800, 400, 3000, "Træ", "Brun", 'used', 'Lille bord, lidt slid.'),
 (12, 1, 300.00, 900, 2100, 1000, 32000, "Stof", "Grå", 'like new', 'Stor sofa, røgfrit hjem.'),
 (13, 1, 199.00, 450, 900, 400, 9000, "Træ", "Hvid", 'used', 'Kommode i god stand.'),
 (14, 1, 45.00, 1800, 600, 600, 10000, "Træ", "Hvid", 'used', 'Skab med enkelte brugsspor.'),
 (15, 1, 129.00, 850, 2000, 950, 28000, "Stof", "Grå", 'like new', 'Komfortabel sofa med god støtte.'),
 (16, 1, 89.00, 780, 650, 700, 10000, "Træ", "Brun", 'used', 'Spisebordsstol, pæn stand.'),
 (17, 4, 79.00, 820, 600, 650, 9500, "Træ", "Brun", 'used', 'Stol med små ridser.'),
 (18, 1, 220.00, 400, 600, 600, 12000, "Træ", "Brun", 'used', 'Lille bord, solid konstruktion.'),
 (19, 1, 60.00, 300, 800, 400, 6000, "Plastik", "Hvid", 'used', 'Praktisk opbevaringskasse.'),
 (20, 1, 1200.00, 760, 1800, 900, 35000, "Træ", "Hvid", 'like new', 'Sofabord i flot stand.'),
 (21, 1, 350.00, 820, 900, 850, 15000, "Stål", "Hvid", 'used', 'Klubstol med slitage.'),
 (22, 1, 180.00, 1400, 800, 700, 20000, "Træ", "Hvid", 'used', 'Praktisk bænk.'),
 (23, 1, 55.00, 200, 800, 400, 2500, "Træ", "Hvid", 'used', 'Bogreol i god stand.'),
 (24, 1, 1299.00, 850, 2200, 1000, 40000, "Læder", "Hvid", 'like new', 'Eksklusiv lædersofa, næsten som ny.'),
 (25, 1, 399.00, 750, 1600, 800, 20000, "Træ", "Hvid", 'used', 'Flot spisebord med plads til 6.'),
 (26, 1, 450.00, 900, 1200, 600, 18000, "Træ", "Hvid", 'used', 'Skab med hylder.'),
 (27, 1, 39.00, 450, 450, 450, 3000, "Træ", "Hvid", 'used', 'Garderobestativ, let at samle.'),
 (28, 1, 220.00, 800, 1000, 600, 14000, "Træ", "Hvid", 'used', 'Funktionelt TV-bord.'),
 (29, 2, 89.00, 720, 1200, 600, 13000, "Træ", "Brun", 'used', 'Skrivebord i pæn stand.'),
 (30, 1, 2400.00, 900, 2800, 1200, 50000, "Stof", "Hvid", 'like new', 'Stor hjørnesofa, perfekt til familie.'),
 (31, 1, 19.00, 300, 400, 300, 1500, "Træ", "Hvid", 'used', 'Billig skammel.'),
 (32, 2, 149.00, 820, 700, 750, 11000, "Træ", "Orange", 'used', 'Komfortabel lænestol.'),
 (33, 1, 79.00, 400, 600, 350, 5000, "Træ", "Hvid", 'used', 'Praktisk rullebord.'),
 (34, 1, 129.00, 450, 450, 450, 6000, "Træ", "Hvid", 'used', 'Lille skammel, pæn stand.'),
 (35, 1, 599.00, 860, 1400, 700, 22000, "Træ", "Hvid", 'like new', 'Sofabord i god kvalitet.'),
 (36, 1, 249.00, 760, 1200, 700, 17000, "Træ", "Hvid", 'used', 'Robust spisebord.'),

 -- Additional realistic mappings (listings that include more than one product)
 (37, 1, 500.00, 760, 1200, 700, 17000, "Stof", "Hvid", 'used', 'Dejlig sofa jeg desværre skal af med da jeg flytter og sælger med.'),   -- listing 3 (sofa) also paired with product 2 (another sofa/sofa-part)
 (38, 1, 600.00, 760, 1200, 700, 17000, "Stof", "Hvid", 'used', 'Sofa der passer til alt.'), -- listing 24 (sofa) paired with coffee table STOCKHOLM
 (39, 1, 1000.00, 760, 1200, 700, 17000, "Stof", "Hvid", 'used', 'En god sofa.'), -- listing 30 (corner sofa) paired with coffee table STOCKHOLM
 (40, 2, 300.00, 760, 1200, 700, 17000, "Træ", "Hvid", 'used', 'Stole til salg.'),  -- listing 1 (chair) paired with small table LACK
 (41, 1, 150.00, 760, 1200, 700, 17000, "Træ", "Hvid", 'used', 'Min reol som jeg sælger.'),  -- listing 7 (reol) paired with product 23 (BILLY)
 (42, 1, 500.00, 760, 1200, 700, 17000, "Stof", "Hvid", 'used', 'Slacker sofa til salg.'); -- listing 12 (sofa) paired with product 24 (ClassicChair)

INSERT INTO `listing_images` (`listing_id`, `image_url`, `is_primary`) VALUES
 (1, "/Chair-04/Chairs1--1-_jpg.rf.02ca62a3131ab22bb90ffca336dfe6a9_0_5376.png", TRUE),
 (1, "/Chair-04/Chairs1--1-_jpg.rf.02ca62a3131ab22bb90ffca336dfe6a9_0_5946.png", FALSE),
 (1, "/Chair-04/Chairs1--1-_jpg.rf.02ca62a3131ab22bb90ffca336dfe6a9_0_9796.png", FALSE),
 (2, "/Coach-01/Sofa--375-_jpg.rf.c6325be15540ad9401e264f1691c7d9a_0_3772.png", TRUE),
 (2, "/Coach-01/Sofa--375-_jpg.rf.c6325be15540ad9401e264f1691c7d9a_0_6595.png", FALSE),
 (2, "/Coach-01/Sofa--375-_jpg.rf.c6325be15540ad9401e264f1691c7d9a_0_9050.png", FALSE),
 (2, "/Coach-01/Sofa--376-_jpg.rf.908e59dcbc72cde1fedfbedecb015795_0_777.png", FALSE),
 (2, "/Coach-01/Sofa--376-_jpg.rf.908e59dcbc72cde1fedfbedecb015795_0_3311.png", FALSE),
 (3, "/Coach-02/Sofa--372-_jpg.rf.ea93af5d1f4924502593e4af15f7759a_0_5351.png", TRUE),
 (3, "/Coach-02/Sofa--372-_jpg.rf.ea93af5d1f4924502593e4af15f7759a_0_6476.png", FALSE),
 (3, "/Coach-02/Sofa--372-_jpg.rf.ea93af5d1f4924502593e4af15f7759a_0_7824.png", FALSE),
 (4, "/Coach-05/Sofa--379-_jpg.rf.111d67d132b0d528e76b2290989859ef_0_549.png", TRUE),
 (4, "/Coach-05/Sofa--379-_jpg.rf.111d67d132b0d528e76b2290989859ef_0_6240.png", FALSE),
 (4, "/Coach-05/Sofa--379-_jpg.rf.111d67d132b0d528e76b2290989859ef_0_6623.png", FALSE),
 (5, "/Chair-01/Chair--269-_jpg.rf.d1a5d5b5a42df1c13f7ade40a85e4390_0_5097.png", TRUE),
 (5, "/Chair-01/Chair--269-_jpg.rf.d1a5d5b5a42df1c13f7ade40a85e4390_0_7528.png", FALSE),
 (5, "/Chair-01/Chair--269-_jpg.rf.d1a5d5b5a42df1c13f7ade40a85e4390_0_8487.png", FALSE),
 (6, "/Chair-02/Chair--270-_jpg.rf.08246b076e2ffe7ff107b5644a45a2a5_0_1258.png", TRUE),
 (6, "/Chair-02/Chair--270-_jpg.rf.08246b076e2ffe7ff107b5644a45a2a5_0_7109.png", FALSE),
 (6, "/Chair-02/Chair--270-_jpg.rf.08246b076e2ffe7ff107b5644a45a2a5_0_8401.png", FALSE),
 -- (7, NULL, TRUE),
 -- (8, NULL, TRUE),
 (9, "/Chair-04/Chairs1--1-_jpg.rf.02ca62a3131ab22bb90ffca336dfe6a9_0_5376.png", TRUE),
 (9, "/Chair-04/Chairs1--1-_jpg.rf.02ca62a3131ab22bb90ffca336dfe6a9_0_5946.png", FALSE),
 (9, "/Chair-04/Chairs1--1-_jpg.rf.02ca62a3131ab22bb90ffca336dfe6a9_0_9796.png", FALSE),
 ( 10, "/Coach-03/Sofa--373-_jpg.rf.4a04d52e387e21b8218b5bab41a317df_0_1784.png", TRUE),
 ( 10, "/Coach-03/Sofa--373-_jpg.rf.4a04d52e387e21b8218b5bab41a317df_0_405.png", FALSE),
 ( 10, "/Coach-03/Sofa--373-_jpg.rf.4a04d52e387e21b8218b5bab41a317df_0_3708.png", FALSE),
 ( 11, "/Table-04/Table--1-_jpg.rf.2160d9cab943221daff98a924ff7c22e_0_2246.png", TRUE),
 ( 11, "/Table-04/Table--1-_jpg.rf.2160d9cab943221daff98a924ff7c22e_0_3725.png", FALSE),
 ( 11, "/Table-04/Table--1-_jpg.rf.2160d9cab943221daff98a924ff7c22e_0_8639.png", FALSE),
 ( 12, "/Coach-06/Sofa--380-_jpg.rf.8c5c47f929dfda85db1ef409e789ed9e_0_9945.png", TRUE),
 ( 12, "/Coach-06/Sofa--380-_jpg.rf.8c5c47f929dfda85db1ef409e789ed9e_0_7139.png", FALSE),
 ( 12, "/Coach-06/Sofa--380-_jpg.rf.8c5c47f929dfda85db1ef409e789ed9e_0_8664.png", FALSE),
 -- ( 13, NULL, TRUE),
 -- ( 14, NULL, TRUE),
 ( 15, "/Coach-07/Sofa--382-_jpg.rf.bfe6db0b3bb48e2e84f965f7fd1d3ffc_0_7075.png", TRUE),
 ( 15, "/Coach-07/Sofa--382-_jpg.rf.bfe6db0b3bb48e2e84f965f7fd1d3ffc_0_3381.png", FALSE),
 ( 15, "/Coach-07/Sofa--382-_jpg.rf.bfe6db0b3bb48e2e84f965f7fd1d3ffc_0_5001.png", FALSE),
 ( 16, "/Chair-06/Chairs1--3-_jpg.rf.9589f3a649f345fe7f397fea2a922c43_0_457.png", TRUE),
 ( 16, "/Chair-06/Chairs1--3-_jpg.rf.9589f3a649f345fe7f397fea2a922c43_0_1185.png", FALSE),
 ( 16, "/Chair-06/Chairs1--3-_jpg.rf.9589f3a649f345fe7f397fea2a922c43_0_2813.png", FALSE),
 ( 17, "/Chair-05/Chairs1--2-_jpg.rf.6229653548825a1e00b66de591a59f29_0_4479.png", TRUE),
 ( 17, "/Chair-05/Chairs1--2-_jpg.rf.6229653548825a1e00b66de591a59f29_0_6096.png", FALSE),
 ( 17, "/Chair-05/Chairs1--2-_jpg.rf.6229653548825a1e00b66de591a59f29_0_6606.png", FALSE),
 ( 18, "/Table-05/Table--127-_jpg.rf.166806211b76785a519e86ae6c426b43_0_1135.png", TRUE),
 ( 18, "/Table-05/Table--127-_jpg.rf.166806211b76785a519e86ae6c426b43_0_1762.png", FALSE),
 ( 18, "/Table-05/Table--127-_jpg.rf.166806211b76785a519e86ae6c426b43_0_1956.png", FALSE),
 -- ( 19, NULL, TRUE),
 -- ( 20, NULL, TRUE),
 -- ( 21, NULL, TRUE),
 -- ( 22, NULL, TRUE),
 -- ( 23, NULL, TRUE),
 ( 24, "/Coach-08/Sofa--371-_jpg.rf.2fd16994ccf9d3a45af79140b1661e74_0_1175.png", TRUE),
 ( 24, "/Coach-08/Sofa--371-_jpg.rf.2fd16994ccf9d3a45af79140b1661e74_0_1715.png", FALSE),
 ( 24, "/Coach-08/Sofa--371-_jpg.rf.2fd16994ccf9d3a45af79140b1661e74_0_3783.png", FALSE),
 -- ( 25, NULL, TRUE),
 -- ( 26, NULL, TRUE),
 -- ( 27, NULL, TRUE),
 -- ( 28, NULL, TRUE),
 ( 29, "/Table-01/Table--100-_jpg.rf.a59eab5a4a848a97001db7b6a2cd867b_0_3976.png", TRUE),
 ( 29, "/Table-01/Table--100-_jpg.rf.a59eab5a4a848a97001db7b6a2cd867b_0_6078.png", FALSE),
 ( 29, "/Table-01/Table--100-_jpg.rf.a59eab5a4a848a97001db7b6a2cd867b_0_8535.png", FALSE),
 ( 29, "/Table-01/Table--101-_jpg.rf.fc4550dad3bf237b3a012c24324e3255_0_306.png", FALSE),
 ( 29, "/Table-01/Table--101-_jpg.rf.fc4550dad3bf237b3a012c24324e3255_0_3854.png", FALSE),
 -- ( 30, NULL, TRUE),
 -- ( 31, NULL, TRUE),
 ( 32, "/Chair-08/Chairs1--5-_jpg.rf.11386ca7c69846d90f4d3fc7b7ebd477_0_403.png", TRUE),
 ( 32, "/Chair-08/Chairs1--5-_jpg.rf.11386ca7c69846d90f4d3fc7b7ebd477_0_1223.png", FALSE),
 ( 32, "/Chair-08/Chairs1--5-_jpg.rf.11386ca7c69846d90f4d3fc7b7ebd477_0_4592.png", FALSE)
 -- ( 33, NULL, TRUE),
 -- ( 34, NULL, TRUE),
 -- ( 35, NULL, TRUE),
 -- ( 36, NULL, TRUE)
 ;
 
-- --------------------------------------------------
-- Seed wishlists, wishlist_items and user_blocks
-- Using existing users (1-20) and listings (1-36)
-- Text / comments in Danish where appropriate
-- --------------------------------------------------

-- One wishlist per user (some users may keep it empty)
INSERT INTO `wishlists` (`id`, `user_id`) VALUES
 (1, 1),
 (2, 2),
 (3, 3),
 (4, 4),
 (5, 5),
 (6, 6),
 (7, 7),
 (8, 8),
 (9, 9),
 (10, 10),
 (11, 11),
 (12, 12),
 (13, 13),
 (14, 14),
 (15, 15),
 (16, 16),
 (17, 17),
 (18, 18),
 (19, 19),
 (20, 20);

-- Wishlist items: hver tuple er et ønske (wishlist_id, listing_id)
-- Sikrer UNIQUE (wishlist_id, listing_id) som constraint kræver
INSERT INTO `wishlist_items` (`id`, `wishlist_id`, `listing_id`) VALUES
 (1, 1, 4),
 (2, 1, 5),
 (3, 1, 6),
 (4, 2, 2),
 -- user 3 har ingen ønskeliste items
 (5, 4, 7),
 (6, 4, 8),
 (7, 4, 9),
 (8, 4, 10),
 (9, 4, 11),
 (10, 5, 12),
 (11, 5, 13),
 -- user 6 tom
 (12, 7, 14),
 (13, 7, 15),
 (14, 7, 16),
 (15, 7, 17),
 (16, 8, 18),
 -- user 9 tom
 (17, 10, 19),
 (18, 10, 20),
 (19, 11, 21),
 (20, 11, 22),
 (21, 11, 23),
 (22, 11, 24),
 (23, 11, 25),
 -- user 12 tom
 (24, 13, 26),
 (25, 13, 27),
 (26, 13, 28),
 (27, 14, 29),
 -- user 15 tom
 (28, 16, 30),
 (29, 16, 31),
 -- user 17 tom
 (30, 18, 32),
 (31, 19, 33),
 (32, 19, 34),
 (33, 19, 35),
 (34, 19, 36),
 (35, 20, 1),
 (36, 20, 3);

-- User blocks: nogle eksempler (user_id blokkerer blocked_user_id)
INSERT INTO `user_blocks` (`id`, `user_id`, `blocked_user_id`) VALUES
 (1, 1, 3),
 (2, 2, 5),
 (3, 4, 1),
 (4, 7, 2),
 (5, 11, 14),
 (6, 13, 9),
 (7, 16, 20),
 (8, 19, 6);

-- Done seeding wishlists, wishlist_items and user_blocks

-- Seed ratings (brugere 1-20, ingen selv-vurderinger, unikke par)
INSERT INTO `ratings` (`id`, `rating`, `review`, `rated_user_id`, `rating_user_id`) VALUES
 (1, 5, 'Utrolig hjælpsom og venlig, varen som beskrevet.', 2, 1),
 (2, 4, 'God kommunikation, hurtig afhentning.', 1, 2),
 (3, 5, 'Anbefaler denne sælger – flot stand.', 4, 3),
 (4, 3, 'Ok oplevelse, men forsendelsen tog lang tid.', 1, 4),
 (5, 4, 'Fin vare, rimelig pris.', 4, 5),
 (6, 5, 'Meget tilfreds, alt i orden.', 2, 6),
 (7, 2, 'Blev lovet mere end leveret.', 11, 7),
 (8, 4, 'Rimelig pris, god kontakt.', 7, 8),
 (9, 5, 'Perfekt køb, virker som nyt.', 11, 9),
 (10, 4, 'Hurtig respons og pakning.', 5, 10),
 (11, 5, 'Meget serviceorienteret.', 12, 11),
 (12, 4, 'Alt gik glat, god handel.', 11, 12),
 (13, 3, 'Produktet havde flere brugsspor end forventet.', 7, 13),
 (14, 5, 'Super kvalitet — anbefales.', 13, 14),
 (15, 4, 'God sælger, rimelig pris.', 16, 15),
 (16, 5, 'Fantastisk service, hurtig afsendelse.', 15, 16),
 (17, 4, 'Ok oplevelse.', 18, 17),
 (18, 5, 'Alt var som aftalt, tak!', 19, 18),
 (19, 2, 'Skuffet over tilstanden.', 20, 19),
 (20, 3, 'Blandet oplevelse — kommunikation ok.', 19, 20),
 (21, 5, 'Super kommunikation og god vare.', 11, 1),
 (22, 4, 'Alt ok, som aftalt.', 7, 2),
 (23, 5, 'Meget hjælpsom.', 11, 3),
 (24, 4, 'Rigtig god handel.', 7, 4);

-- --------------------------------------------------
-- Seed user_follows
-- Users cannot follow themselves and cannot follow someone with whom there is a block (either direction).
-- --------------------------------------------------
INSERT INTO `user_follows` (`id`, `user_id`, `followed_user_id`) VALUES
 (1, 1, 2),
 (2, 1, 5),
 (3, 1, 6),
 (4, 2, 1),
 (5, 2, 6),
 (6, 3, 2),
 (7, 3, 8),
 (8, 4, 3),
 (9, 4, 6),
 (10, 5, 1),
 (11, 5, 8),
 (12, 6, 1),
 (13, 6, 2),
 (14, 6, 11),
 (15, 7, 1),
 (16, 7, 3),
 (17, 7, 8),
 (18, 8, 1),
 (19, 8, 11),
 (20, 9, 2),
 (21, 9, 11),
 (22, 10, 1),
 (23, 10, 5),
 (24, 11, 1),
 (25, 11, 2),
 (26, 11, 3),
 (27, 12, 11),
 (28, 12, 13),
 (29, 13, 11),
 (30, 13, 14),
 (31, 13, 15),
 (32, 14, 1),
 (33, 14, 2),
 (34, 15, 11),
 (35, 15, 16),
 (36, 16, 11),
 (37, 16, 1),
 (38, 17, 11),
 (39, 17, 3),
 (40, 18, 11),
 (41, 18, 19),
 (42, 19, 1),
 (43, 19, 2),
 (44, 19, 11),
 (45, 20, 1),
 (46, 20, 3);

-- --------------------------------------------------
-- Seed auctions, bids, interested_buyers and rooms
-- Based on existing listings (1-36) and users (1-20)
-- --------------------------------------------------
INSERT INTO `auctions` (`id`, `starting_bid`, `current_bid`, `status`, `start_time`, `end_time`, `listing_id`) VALUES
 (1, 500.00, 750.00, 'closed', '2025-10-30 10:00:00', '2025-11-01 12:00:00', 4),
 (2, 3000.00, 3500.00, 'closed', '2025-11-01 09:00:00', '2025-11-05 18:00:00', 9),
 (3, 250.00, 275.00, 'active', '2025-11-12 08:00:00', '2025-11-20 20:00:00', 12),
 (4, 60.00, 120.00, 'active', '2025-11-11 14:00:00', '2025-11-18 20:00:00', 17),
 (5, 1000.00, 1500.00, 'closed', '2025-10-28 15:00:00', '2025-11-10 16:00:00', 24),
 (6, 2000.00, NULL, 'scheduled', '2025-11-20 09:00:00', '2025-11-25 18:00:00', 30),
 (7, 50.00, 80.00, 'active', '2025-11-10 12:00:00', '2025-11-19 21:00:00', 33),
 (8, 400.00, NULL, 'cancelled', '2025-11-05 09:00:00', '2025-11-12 12:00:00', 35),
 (9, 200.00, 300.00, 'closed', '2025-10-29 11:00:00', '2025-11-09 13:00:00', 2),
 (10, 150.00, 170.00, 'active', '2025-11-09 10:00:00', '2025-11-22 22:00:00', 28);

-- Bids: (id, bid_amount, bid_time, auction_id, user_id)
INSERT INTO `bids` (`id`, `bid_amount`, `bid_time`, `auction_id`, `user_id`) VALUES
 (1, 550.00, '2025-10-30 11:00:00', 1, 1),
 (2, 600.00, '2025-10-30 12:00:00', 1, 6),
 (3, 750.00, '2025-10-30 13:00:00', 1, 10),
 (4, 3200.00, '2025-11-02 09:30:00', 2, 5),
 (5, 3400.00, '2025-11-03 10:15:00', 2, 7),
 (6, 3500.00, '2025-11-04 16:45:00', 2, 11),
 (7, 260.00, '2025-11-12 09:00:00', 3, 2),
 (8, 275.00, '2025-11-12 10:30:00', 3, 11),
 (9, 80.00, '2025-11-11 15:00:00', 4, 3),
 (10, 100.00, '2025-11-11 16:10:00', 4, 12),
 (11, 120.00, '2025-11-11 17:20:00', 4, 14),
 (12, 1100.00, '2025-10-28 16:00:00', 5, 2),
 (13, 1400.00, '2025-11-08 11:00:00', 5, 11),
 (14, 1500.00, '2025-11-09 09:30:00', 5, 5),
 (15, 60.00, '2025-11-10 12:30:00', 7, 2),
 (16, 70.00, '2025-11-11 13:45:00', 7, 9),
 (17, 80.00, '2025-11-12 14:20:00', 7, 4),
 (18, 220.00, '2025-10-29 12:00:00', 9, 2),
 (19, 260.00, '2025-10-30 09:45:00', 9, 6),
 (20, 300.00, '2025-11-08 10:00:00', 9, 7),
 (21, 170.00, '2025-11-10 11:00:00', 10, 11);

-- Interested buyers (unique pairs, user_id != owner)
INSERT INTO `interested_buyers` (`id`, `user_id`, `listing_id`, `buyers_comments`, `amount_to_buy`) VALUES
 (1, 3, 4, 'Interesseret, kan afhentes i weekenden.', 1),
 (2, 5, 4, 'Ville gerne måle før køb.', 1),
 (3, 6, 9, 'Ser godt ud, er det røgfrit?', 1),
 (4, 8, 12, 'Kan I sende mål?', 1),
 (5, 2, 17, 'Interesseret i hurtig afhentning.', 1),
 (6, 11, 24, 'Vil gerne se flere billeder.', 1),
 (7, 14, 30, 'Passer til mit hjem, kommer forbi søndag.', 1),
 (8, 15, 33, 'Er prisen til forhandling?', 1),
 (9, 18, 2, 'Interesseret - kan afhente.', 1),
 (10, 19, 28, 'Vil helst afhente i weekenden.', 1),
 (11, 10, 35, 'Ser fint ud, sender privat besked.', 1),
 (12, 12, 29, 'Kan I give rabat ved afhentning?', 1);

-- Rooms: small sample rooms showcasing products
INSERT INTO `rooms` (`id`, `room_name`, `user_id`) VALUES
 (1, 'Stue', 1),
 (2, 'Badeværelse', 2),
 (3, 'Soveværelse', 3),
 (4, 'Kontor', 11),
 (5, 'Entre', 13),
 (6, 'Børneværelse', 18); -- TODO ask: User-id delete? Enum instead?

 -- --------------------------------------------------
 -- Seed products_rooms (which products fit which rooms)
 -- Suggested realistic placements based on room types
 -- --------------------------------------------------
INSERT INTO `products_rooms` (`id`, `product_id`, `room_id`) VALUES
 (1, 2, 1),  -- Sofa (KLIPPAN) in Stue
 (2, 3, 1),  -- Sofa (LækkerStofa) in Stue
 (3, 24, 1), -- Sofa (ClassicChair) in Stue
 (4, 11, 1), -- Bord (LACK) in Stue
 (5, 35, 1), -- Bord (STOCKHOLM) in Stue
 (6, 1, 1),  -- Stol (POÄNG) in Stue

 (7, 19, 2), -- Kasse (EKET) in Badeværelse (storage/boxes)
 (8, 26, 2), -- Hylde (HEMNES-SKAB) in Badeværelse

 (9, 22, 6), -- Bænk (TJUSIG) in Børneværelse (bench / changing)
 
 (10, 31, 2),-- Skammel (INGO) in Badeværelse

 (11, 13, 3),-- Kommode (NORDLI) in Soveværelse
 (12, 14, 3),-- Skab (HEMNES) in Soveværelse
 (13, 31, 3),-- Skammel (INGO) in Soveværelse
 (14, 34, 3),-- Skammel (Stool) in Soveværelse

 (15, 29, 4),-- Bord (LINNMON) in Kontor (desk)
 (16, 33, 4),-- Bord (RÅSKOG) in Kontor (mobile desk/table)
 (17, 11, 4),-- Bord (LACK) in Kontor
 (18, 23, 4),-- Reol (BILLY) in Kontor

 (19, 27, 5),-- Gaderopestativ (LoopStand) in Entre (coat rack)
 (20, 22, 5),-- Bænk (TJUSIG) in Entre
 (21, 19, 5),-- Kasse (EKET) in Entre (storage)
 (22, 28, 5),-- TV-bord (FJÄLLBO) in Entre (small table / console)

 (23, 8, 6), -- POÄNG-KID in Børneværelse
 (24, 18, 6),-- MiniTable in Børneværelse
 (25, 32, 6),-- PillowChair in Børneværelse
 (26, 31, 6),-- Skammel (INGO) in Børneværelse
 (27, 26, 6), -- Hylde (HEMNES-SKAB) in Børneværelse

(28, 23, 1) -- Reol (BILLY) in Stue
;

-- Seed listings_products: link listings to products
INSERT INTO `listings_products_details` (`id`, `product_id`, `listing_id`, `listing_item_id`) VALUES
 (1, 1, 1, 1),  -- listing 1 -> product 1 (POÄNG)
 (2, 2, 2, 2),
 (3, 3, 3, 3),
 (4, 4, 4, 4),
 (5, 5, 5, 5),
 (6, 6, 6, 6),
 (7, 7, 7, 7),
 (8, 8, 8, 8),
 (9, 9, 9, 9),
 (10, 10, 10, 10),
 (11, 11, 11, 11),
 (12, 12, 12, 12),
 (13, 13, 13, 13),
 (14, 14, 14, 14),
 (15, 15, 15, 15),
 (16, 16, 16, 16),
 (17, 17, 17, 17),
 (18, 12, 12, 12), -- listing 18 uses product 12 in listing_items TJEK
 (19, 19, 19, 19),
 (20, 20, 20, 20),
 (21, 21, 21, 21),
 (22, 22, 22, 22),
 (23, 23, 23, 23),
 (24, 24, 24, 24),
 (25, 25, 25, 25),
 (26, 26, 26, 26),
 (27, 27, 27, 27),
 (28, 28, 28, 28),
 (29, 29, 29, 29),
 (30, 30, 30, 30),
 (31, 31, 31, 31),
 (32, 32, 32, 32),
 (33, 33, 33, 33),
 (34, 34, 34, 34),
 (35, 35, 35, 35),
 (36, 36, 36, 36),

 -- Additional realistic mappings (listings that include more than one product)
 (37, 2, 3, 37),   -- listing 3 (sofa) also paired with product 2 (another sofa/sofa-part)
 (38, 35, 24, 38), -- listing 24 (sofa) paired with coffee table STOCKHOLM
 (39, 35, 30, 39), -- listing 30 (corner sofa) paired with coffee table STOCKHOLM
 (40, 11, 1, 40),  -- listing 1 (chair) paired with small table LACK
 (41, 23, 7, 41),  -- listing 7 (reol) paired with product 23 (BILLY)
 (42, 24, 12, 42); -- listing 12 (sofa) paired with product 24 (ClassicChair)

 -- Seed styles: realistic Danish interior-design styles
INSERT INTO `styles` (`id`, `name`, `description`) VALUES
 (1, 'Skandinavisk', 'Lys og funktionel indretning med naturlige materialer og rene linjer.'),
 (2, 'Minimalistisk', 'Fokus på det essentielle: få møbler, neutrale farver og åben plads.'),
 (3, 'Industriel', 'Råt udtryk med metal, synlige installationer og grove overflader.'),
 (4, 'Boheme', 'Farverigt og teksturrigt mix af mønstre, planter og kunsthåndværk.'),
 (5, 'Vintage', 'Retro-møbler og patina – genbrug og nostalgisk charme.'),
 (6, 'Moderne', 'Nutidigt design med rene flader, funktionalitet og høj finish.'),
 (7, 'Mid-century', 'Møbelklassikere fra midten af århundredet: teak, buede former og varme toner.'),
 (8, 'Japandi', 'Kombination af japansk enkelhed og skandinavisk hygge; minimal, naturlig.'),
 (9, 'Rustik', 'Grovtræ, varme farver og robuste materialer for en hyggelig atmosfære.'),
 (10, 'Landlig', 'Hyggelig country-stil med bløde tekstiler, mønstre og vintage-elementer.'),
 (11, 'Eklektisk', 'Personlig blanding af stilarter og farver med fokus på karakter.'),
 (12, 'Art Deco', 'Glamourøst og ornamenteret med metaller, spejle og geometriske mønstre.'),
 (13, 'Bæredygtig', 'Genbrug, naturmaterialer og miljøvenlige valg i både møbler og tekstiler.'),
 (14, 'Urban moderne', 'Bymæssig, strømlinet stil med mørkere nuancer og moderne materialer');

-- Seed products_styles: realistic 1–2 style mappings per product
INSERT INTO `products_styles` (`id`, `product_id`, `style_id`) VALUES
 (1, 1, 1),
 (2, 1, 8),
 (3, 2, 1),
 (4, 2, 6),
 (5, 3, 6),
 (6, 3, 7),
 (7, 4, 6),
 (8, 4, 1),
 (9, 5, 6),
 (10, 5, 7),
 (11, 6, 1),
 (12, 6, 13),
 (13, 7, 1),
 (14, 7, 13),
 (15, 8, 1),
 (16, 8, 4),
 (17, 9, 7),
 (18, 9, 6),
 (19, 10, 5),
 (20, 10, 11),
 (21, 11, 1),
 (22, 11, 2),
 (23, 12, 14),
 (24, 12, 6),
 (25, 13, 1),
 (26, 13, 5),
 (27, 14, 10),
 (28, 14, 1),
 (29, 15, 6),
 (30, 15, 1),
 (31, 16, 6),
 (32, 16, 7),
 (33, 17, 1),
 (34, 17, 8),
 (35, 18, 2),
 (36, 18, 1),
 (37, 19, 1),
 (38, 19, 13),
 (39, 20, 3),
 (40, 20, 6),
 (41, 21, 5),
 (42, 21, 7),
 (43, 22, 1),
 (44, 22, 9),
 (45, 23, 1),
 (46, 23, 2),
 (47, 24, 7),
 (48, 24, 6),
 (49, 25, 6),
 (50, 25, 1),
 (51, 26, 10),
 (52, 26, 1),
 (53, 27, 14),
 (54, 27, 6),
 (55, 28, 3),
 (56, 28, 9),
 (57, 29, 2),
 (58, 29, 1),
 (59, 30, 6),
 (60, 30, 14),
 (61, 31, 1),
 (62, 31, 9),
 (63, 32, 6),
 (64, 32, 1),
 (65, 33, 1),
 (66, 33, 2),
 (67, 34, 7),
 (68, 34, 6),
 (69, 35, 6),
 (70, 35, 1),
 (71, 36, 6),
 (72, 36, 3);
 
 Commit;
