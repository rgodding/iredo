-- Functions for database

-- Get user full name by user ID
DELIMITER //
CREATE FUNCTION GetUserFullName(p_user_id INT)
RETURNS VARCHAR(101)
DETERMINISTIC
BEGIN
    DECLARE full_name VARCHAR(101);
    
    SELECT CONCAT(first_name, ' ', last_name) INTO full_name
    FROM user_details
    WHERE user_id = p_user_id;
    RETURN full_name;
END //
DELIMITER ;

-- Check if user is blocked
DELIMITER //
CREATE FUNCTION IsUserBlocked(p_user_id INT, p_blocked_user_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE is_blocked BOOLEAN DEFAULT FALSE;
    IF EXISTS (
        SELECT 1
        FROM user_blocks
        WHERE user_id = p_user_id AND blocked_user_id = p_blocked_user_id
    ) THEN
        SET is_blocked = TRUE;
    END IF;
    RETURN is_blocked;
END //
DELIMITER ;

-- Get the discounted price for a listing
DELIMITER //
CREATE FUNCTION GetDiscountedPrice(p_listing_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE base_price DECIMAL(10,2);
    DECLARE discount_percentage DECIMAL(5,2);
    SELECT price, discount_percentage INTO base_price, discount_percentage
    FROM listings
    WHERE id = p_listing_id;
    RETURN base_price * (1 - discount_percentage / 100);
END //
DELIMITER ;