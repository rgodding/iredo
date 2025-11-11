-- Event for database
SET GLOBAL event_scheduler = ON;

-- Event to close expired auction every minute
CREATE EVENT IF NOT EXISTS evt_close_auctions
ON SCHEDULE EVERY 1 MINUTE
ON COMPLETION PRESERVE
DO
BEGIN
    UPDATE auctions
    SET status = 'closed'
    WHERE end_time <= NOW() AND status = 'active';
END;

-- Event to start scheduled auctions every minute
CREATE EVENT IF NOT EXISTS evt_start_auctions
ON SCHEDULE EVERY 1 MINUTE
ON COMPLETION PRESERVE
DO
BEGIN
    UPDATE auctions
    SET status = 'active'
    WHERE start_time <= NOW() AND status = 'scheduled';
END;

-- Could add more events as needed
-- Examples:
-- -- Event to archive old bids
-- -- Event to send notifications for upcoming auction endings
-- -- Event to update product popularity based on bids