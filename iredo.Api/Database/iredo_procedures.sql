-- Store procedures for database

-- Create a new user
DELIMITER //
CREATE PROCEDURE CreateUser(
    -- Parameters for `users` table
    IN p_username VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_password_hash VARCHAR(255),
    -- Parameters for `user_details` table
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_date_of_birth DATE,
    IN p_phone_number VARCHAR(15),
    IN p_address VARCHAR(255),
    IN p_postal_code VARCHAR(20),
    IN p_city VARCHAR(100)
)
BEGIN
    -- Handler for duplicate entries
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        ROLLBACK;
        SELECT 'Duplicate entry. User with the same username, phone number or email already exists.' AS ErrorMessage;
    END;
    -- Error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback transaction on error
        ROLLBACK;
        SELECT 'Error occurred while creating user.' AS ErrorMessage;
    END;
        
    -- Variable to hold the new user ID
    DECLARE new_user_id INT;

    -- Start the transaction. If any part fails, the whole transaction will be rolled back.
    START TRANSACTION;
    -- Insert into `users` table
    INSERT INTO users (username, email, password_hash)
    VALUES (p_username, p_email, p_password_hash);

    -- Get the last inserted user ID
    SET new_user_id = LAST_INSERT_ID();

    -- Insert into `user_details` table
    INSERT INTO user_details (user_id, first_name, last_name, date_of_birth, phone_number, address, postal_code, city)
    VALUES (new_user_id, p_first_name, p_last_name, p_date_of_birth, p_phone_number, p_address, p_postal_code, p_city);

    -- Commit the transaction
    COMMIT;

    SELECT 'User created successfully with ID: ' AS SuccessMessage, new_user_id AS UserID;
END //
DELIMITER ;


-- Create a listing along with a new product
DELIMITER //
CREATE PROCEDURE CreateListingWithProduct(
    -- Parameters for `products` table
    IN p_type VARCHAR(100),
    IN p_brand VARCHAR(100),
    IN p_model VARCHAR(100),
    IN p_height_in_mm INT,
    IN p_width_in_mm INT,
    IN p_depth_in_mm INT,
    IN p_weight_in_grams INT,
    IN p_main_material VARCHAR(100),
    IN p_color VARCHAR(50),
    IN p_condition ENUM('New', 'Like New', 'Used', 'Refurbished'),
    IN p_description TEXT,
    -- Parameters for `listings` table
    IN p_price DECIMAL(10,2),
    IN p_total_stock INT,
    IN p_discount DECIMAL(5,2),
    IN p_min_amount_per_order INT,
    IN p_user_id INT
)
    BEGIN
    -- Variable to hold the new product and listing IDs
    DECLARE new_product_id INT;
    DECLARE new_listing_id INT;

    -- Error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback transaction on error
        ROLLBACK;
        SELECT 'Error occurred while creating listing and product.' AS ErrorMessage;
    END;

    -- Start the transaction. If any part fails, the whole transaction will be rolled back.
    START TRANSACTION;

    -- Insert into `products` table
    INSERT INTO products (type, brand, model, height_in_mm, width_in_mm, 
    depth_in_mm, weight_in_grams, main_material, color, condition, description)
    VALUES (p_type, p_brand, p_model, p_height_in_mm, p_width_in_mm, 
    p_depth_in_mm, p_weight_in_grams, p_main_material, p_color, p_condition, p_description);

    -- Get the last inserted product ID
    SET new_product_id = LAST_INSERT_ID();

    -- Insert into `listings` table
    INSERT INTO listings (product_id, price, total_stock, available_stock, discount_percentage, min_amount_per_order, user_id)
    VALUES (new_product_id, p_price, p_total_stock, p_total_stock, p_discount, p_min_amount_per_order, p_user_id);

    -- Get the last inserted listing ID
    SET new_listing_id = LAST_INSERT_ID();

    COMMIT;

    SELECT 'Listing created successfully with ID: ' AS SuccessMessage, new_listing_id AS ListingID;
END //
DELIMITER ;

-- Create a listing with an existing product
DELIMITER //
CREATE PROCEDURE CreateListingWithExistingProduct(
    -- Parameters for `listings` table
    IN p_product_id INT,
    IN p_price DECIMAL(10,2),
    IN p_total_stock INT,
    IN p_discount DECIMAL(5,2),
    IN p_min_amount_per_order INT,
    IN p_user_id INT
)
BEGIN
    -- Variable to hold the new listing ID
    DECLARE new_listing_id INT;

    -- Error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback transaction on error
        ROLLBACK;
        SELECT 'Error occurred while creating listing.' AS ErrorMessage;
    END;

    -- Start the transaction. If any part fails, the whole transaction will be rolled back.
    START TRANSACTION;

    -- Insert into `listings` table
    INSERT INTO listings (product_id, price, total_stock, available_stock, discount_percentage, min_amount_per_order, user_id)
    VALUES (p_product_id, p_price, p_total_stock, p_total_stock, p_discount, p_min_amount_per_order, p_user_id);

    -- Get the last inserted listing ID
    SET new_listing_id = LAST_INSERT_ID();

    COMMIT;

    SELECT 'Listing created successfully with ID: ' AS SuccessMessage, new_listing_id AS ListingID;
END //

-- Create a bid for a listing
DELIMITER //
CREATE PROCEDURE CreateBid(
    IN p_auction_id INT,
    IN p_user_id INT,
    IN p_bid_amount DECIMAL(10,2)
)
BEGIN
    DECLARE current_highest_bid DECIMAL(10,2);
    DECLARE auction_status ENUM('active', 'closed', 'cancelled');

    START TRANSACTION;

    -- Get the current highest bid for the listing
    SELECT current_bid, status
    INTO current_highest_bid, auction_status
    FROM auctions
    WHERE id = p_auction_id
    FOR UPDATE;

    -- Check if the auction is active
    IF auction_status <> 'active' THEN
        ROLLBACK;
        SELECT 'Auction is not active. Cannot place bid.' AS ErrorMessage;
        RETURN;
    END IF;

    -- Check bid amount
    IF p_bid_amount <= current_highest_bid THEN
        ROLLBACK;
        SELECT 'Bid amount must be higher than the current highest bid.' AS ErrorMessage;
        RETURN;
    END IF;

    -- Insert the new bid
    INSERT INTO bids (auction_id, user_id, bid_amount, bid_time)
    VALUES (p_auction_id, p_user_id, p_bid_amount, NOW());

    -- Update the current highest bid in the auctions table
    UPDATE auctions
    SET current_bid = p_bid_amount
    WHERE id = p_auction_id;

    COMMIT;
    SELECT 'Bid placed successfully.' AS SuccessMessage;
END //
DELIMITER ;