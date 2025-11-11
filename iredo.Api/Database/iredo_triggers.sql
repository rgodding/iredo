-- Triggers for the Database

-- Create a wishlist entry when a new user is created
DELIMITER //
CREATE TRIGGER trg_after_user_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO wishlists (user_id)
    VALUES (NEW.id);
END //
DELIMITER ;

-- Prevent direct deletion of users (use deactivation instead)
DELIMITER //
CREATE TRIGGER trg_before_user_delete
BEFORE DELETE ON users
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User deletion is not allowed. Set is_active = FALSE instead.';
END //
DELIMITER ;

-- Archive listings (and their products) before deletion
DELIMITER //
CREATE TRIGGER trg_before_listing_delete
BEFORE DELETE ON listings
FOR EACH ROW
BEGIN
    DECLARE new_archived_product_id INT;

    -- Step 1: Archive the related product
    INSERT INTO archived_products (
        original_product_id,
        type,
        brand,
        model,
        height_in_mm,
        width_in_mm,
        depth_in_mm,
        weight_in_grams,
        main_material,
        color,
        `condition`,
        description,
        archived_at
    )
    SELECT
        p.id,
        p.type,
        p.brand,
        p.model,
        p.height_in_mm,
        p.width_in_mm,
        p.depth_in_mm,
        p.weight_in_grams,
        p.main_material,
        p.color,
        p.condition,
        p.description,
        NOW()
    FROM products p
    WHERE p.id = OLD.product_id;

    -- Step 2: Capture the new archived product ID
    SET new_archived_product_id = LAST_INSERT_ID();

    -- Step 3: Archive the listing
    INSERT INTO archived_listings (
        original_listing_id,
        price,
        total_stock,
        total_sold,
        available_stock,
        discount_percentage,
        min_amount_per_order,
        description,
        created_at,
        archived_at,
        product_id,
        archived_product_id,
        user_id
    )
    VALUES (
        OLD.id,
        OLD.price,
        OLD.total_stock,
        OLD.total_sold,
        OLD.available_stock,
        OLD.discount_percentage,
        OLD.min_amount_per_order,
        OLD.description,
        OLD.created_at,
        NOW(),
        OLD.product_id,
        new_archived_product_id,
        OLD.user_id
    );
END //
DELIMITER ;
