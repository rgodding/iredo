-- Database: marketplace_core
DROP DATABASE IF EXISTS marketplace_core;
CREATE DATABASE marketplace_core;
USE marketplace_core;

-- USER RELATED TABLES
------------------------------------------
-- Table `user_roles`
-- Description: Defines different roles for users
------------------------------------------
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `role` ENUM('admin', 'user', 'seller') NOT NULL UNIQUE
);

------------------------------------------
-- Table `users`
-- Description: Main user table with essential authentication details
------------------------------------------
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
    CONSTRAINT `fk_role` FOREIGN KEY (`role_id`) REFERENCES `user_roles`(`id`),
    ON DELETE RESTRICT,
    ON UPDATE CASCADE
);

------------------------------------------
-- Table `user_details`
-- Description: Separate table for user personal details
------------------------------------------
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
    CONSTRAINT `fk_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
    ON DELETE CASCADE,
    ON UPDATE CASCADE
);

-- USER FUNCTIONALITY TABLES
------------------------------------------
-- Table `Ratings`
-- Description: User ratings and reviews
------------------------------------------
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

------------------------------------------
-- Table `user_follows`
-- Description: Users following other users
------------------------------------------
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

------------------------------------------
-- Table `wishlists`
-- Description: Users' wishlists for products
------------------------------------------
DROP TABLE IF EXISTS `wishlists`;
CREATE TABLE `wishlists` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-------------------------------------------
-- Table `wishlist_items`
-- Description: Items in users' wishlists
-------------------------------------------
DROP TABLE IF EXISTS `wishlist_items`;
CREATE TABLE `wishlist_items` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `wishlist_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    `added_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_wishlist` FOREIGN KEY (`wishlist_id`) REFERENCES `wishlists`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `fk_wishlist_product` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    UNIQUE KEY `uniq_wishlist_product` (`wishlist_id`, `product_id`),
    INDEX `idx_wishlist_id` (`wishlist_id`),
    INDEX `idx_product_id` (`product_id`)
);

------------------------------------------
-- Table `user_blocks`
-- Description: Users blocking other users
------------------------------------------
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

-- PRODUCT RELATED TABLES
------------------------------------------
-- Table `products`
-- Description: Stores product specifications and details
------------------------------------------
DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `type` VARCHAR(100), --ENUM('electronics', 'furniture', 'clothing', 'books', 'other') NOT NULL,
    `brand` VARCHAR(100) NOT NULL,
    `model` VARCHAR(100) NOT NULL,
    `height_in_mm` INT NOT NULL,
    `width_in_mm` INT NOT NULL,
    `depth_in_mm` INT NOT NULL,
    `weight_in_grams` INT NOT NULL,
    `main_material` VARCHAR(100) NOT NULL,
    `color` VARCHAR(50) NOT NULL,
    `condition` ENUM('new', 'like new', 'used', 'refurbished') NOT NULL,
    `description` TEXT
);

------------------------------------------
-- Table `archived_products`
-- Description: Archived products for historical data
------------------------------------------
DROP TABLE IF EXISTS `archived_products`;
CREATE TABLE `archived_products` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `original_product_id` INT NOT NULL,
    `type` VARCHAR(100),
    `brand` VARCHAR(100) NOT NULL,
    `model` VARCHAR(100) NOT NULL,
    `height_in_mm` INT NOT NULL,
    `width_in_mm` INT NOT NULL,
    `depth_in_mm` INT NOT NULL,
    `weight_in_grams` INT NOT NULL,
    `main_material` VARCHAR(100) NOT NULL,
    `color` VARCHAR(50) NOT NULL,
    `condition` ENUM('new', 'like new', 'used', 'refurbished') NOT NULL,
    `description` TEXT,
    `archived_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `archived_reason` VARCHAR(255) DEFAULT 'unspecified',
    INDEX `idx_original_product` (`original_product_id`)
);


-- LISTING RELATED TABLES
------------------------------------------
-- Table `listings`
-- Description: Marketplace listings for products
------------------------------------------
DROP TABLE IF EXISTS `listings`;
CREATE TABLE `listings` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `price` DECIMAL(10,2) NOT NULL,
    `total_stock` INT NOT NULL DEFAULT 1,
    `total_sold` INT NOT NULL DEFAULT 0,
    `available_stock` INT NOT NULL DEFAULT 1,
    `discount_percentage` DECIMAL(5,2) DEFAULT 0,
    `min_amount_per_order` INT NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `description` TEXT,
    `product_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    CONSTRAINT `fk_product` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `fk_seller` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

------------------------------------------
-- Table `archived_listings`
-- Description: Archived listings for historical data
------------------------------------------
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
    `archived_product_id` INT NOT NULL, -- Reference to archived_products table
    `user_id` INT NOT NULL,
    -- Original product can be tracked even if deleted later on
    CONSTRAINT `fk_archived_listing_original_product`
    FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
    -- Archived product reference
    CONSTRAINT `fk_archived_listing_archived_product`
    FOREIGN KEY (`archived_product_id`) REFERENCES `archived_products`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    -- User reference
    CONSTRAINT `fk_archived_listing_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    INDEX `idx_original_listing` (`original_listing_id`)
);


-- Table `auctions`
-- Description: Auctions for listings, allowing competitive bidding
------------------------------------------
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

-------------------------------------------
-- Table `bids`
-- Description: Bids placed by users on auctions
-------------------------------------------
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
    CONSTRAINT `fk_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    INDEX `idx_auction_id` (`auction_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_auction_bid_amount` (`auction_id`, `bid_amount` DESC)
);

-------------------------------------------
-- Table `interested_buyers`
-- Description: Users who have expressed interest in a listing
-------------------------------------------
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
-------------------------------------------
-- Table `rooms`
-- Description: Simulation of a room where products can be showcased
-------------------------------------------
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

-------------------------------------------
-- Table `product_rooms`
-- Description: Many-to-many relationship between products and rooms
-------------------------------------------
DROP TABLE IF EXISTS `product_rooms`;
CREATE TABLE `product_rooms` (
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

----------------------------------------------
-- Table `styles`
-- Description: Styles applied to products
----------------------------------------------
DROP TABLE IF EXISTS `styles`;
CREATE TABLE `styles` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

----------------------------------------------
-- Table `product_styles`
-- Description: Many-to-many relationship between products and styles
----------------------------------------------
DROP TABLE IF EXISTS `product_styles`;
CREATE TABLE `product_styles` (
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
