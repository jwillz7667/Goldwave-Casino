USE casino_db;

-- Create Admin User
INSERT INTO users (username, email, password, status, balance) VALUES
('admin', 'admin@goldwave.casino', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'active', 0.00);

-- Create Admin Profile
INSERT INTO user_profiles (user_id, first_name, last_name, country, currency) VALUES
(1, 'System', 'Administrator', 'US', 'USD');

-- Create Triggers for Statistics Updates
DELIMITER //

-- Update Game Statistics after each transaction
CREATE TRIGGER after_transaction_insert
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.type = 'bet' THEN
        UPDATE game_statistics 
        SET total_bets = total_bets + 1,
            total_bet_amount = total_bet_amount + NEW.amount
        WHERE game_id = (SELECT game_id FROM game_sessions WHERE id = NEW.game_session_id);
    ELSEIF NEW.type = 'win' THEN
        UPDATE game_statistics 
        SET total_wins = total_wins + 1,
            total_win_amount = total_win_amount + NEW.amount,
            biggest_win = GREATEST(biggest_win, NEW.amount)
        WHERE game_id = (SELECT game_id FROM game_sessions WHERE id = NEW.game_session_id);
    END IF;
END//

-- Update User Statistics after each transaction
CREATE TRIGGER after_transaction_user_stats
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    CASE NEW.type
        WHEN 'deposit' THEN
            UPDATE user_statistics 
            SET total_deposits = total_deposits + NEW.amount
            WHERE user_id = NEW.user_id;
        WHEN 'withdrawal' THEN
            UPDATE user_statistics 
            SET total_withdrawals = total_withdrawals + NEW.amount
            WHERE user_id = NEW.user_id;
        WHEN 'bet' THEN
            UPDATE user_statistics 
            SET total_bets = total_bets + NEW.amount
            WHERE user_id = NEW.user_id;
        WHEN 'win' THEN
            UPDATE user_statistics 
            SET total_wins = total_wins + NEW.amount,
                biggest_win = GREATEST(biggest_win, NEW.amount)
            WHERE user_id = NEW.user_id;
    END CASE;
END//

-- Jackpot Increment Trigger
CREATE TRIGGER after_bet_jackpot_increment
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.type = 'bet' THEN
        UPDATE jackpots 
        SET current_amount = current_amount + (NEW.amount * increment_rate)
        WHERE status = true;
    END IF;
END//

DELIMITER ;

-- Create Views for Easy Reporting
CREATE VIEW vw_user_summary AS
SELECT 
    u.username,
    u.email,
    u.balance,
    u.bonus_balance,
    us.total_deposits,
    us.total_withdrawals,
    us.total_bets,
    us.total_wins,
    us.biggest_win,
    COUNT(DISTINCT gs.id) as total_games_played
FROM users u
LEFT JOIN user_statistics us ON u.id = us.user_id
LEFT JOIN game_sessions gs ON u.id = gs.user_id
GROUP BY u.id;

CREATE VIEW vw_game_summary AS
SELECT 
    g.name as game_name,
    gp.name as provider_name,
    gc.name as category_name,
    gs.total_bets,
    gs.total_wins,
    gs.total_bet_amount,
    gs.total_win_amount,
    gs.biggest_win,
    g.rtp
FROM games g
JOIN game_providers gp ON g.provider_id = gp.id
JOIN game_categories gc ON g.category_id = gc.id
LEFT JOIN game_statistics gs ON g.id = gs.game_id;

-- Create Stored Procedures for Common Operations
DELIMITER //

-- Procedure to award bonus to user
CREATE PROCEDURE sp_award_bonus(
    IN p_user_id BIGINT,
    IN p_bonus_id BIGINT
)
BEGIN
    DECLARE v_bonus_amount DECIMAL(20,2);
    DECLARE v_wagering_req DECIMAL(5,2);
    DECLARE v_validity_days INT;
    
    -- Get bonus details
    SELECT amount, wagering_requirement, validity_days 
    INTO v_bonus_amount, v_wagering_req, v_validity_days
    FROM bonuses WHERE id = p_bonus_id;
    
    -- Insert user bonus
    INSERT INTO user_bonuses (
        user_id, 
        bonus_id, 
        amount, 
        wagering_remaining,
        expires_at
    ) VALUES (
        p_user_id,
        p_bonus_id,
        v_bonus_amount,
        v_bonus_amount * v_wagering_req,
        DATE_ADD(NOW(), INTERVAL v_validity_days DAY)
    );
    
    -- Update user bonus balance
    UPDATE users 
    SET bonus_balance = bonus_balance + v_bonus_amount
    WHERE id = p_user_id;
END//

-- Procedure to process withdrawal
CREATE PROCEDURE sp_process_withdrawal(
    IN p_user_id BIGINT,
    IN p_amount DECIMAL(20,2),
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_balance DECIMAL(20,2);
    DECLARE v_daily_limit DECIMAL(20,2);
    DECLARE v_monthly_limit DECIMAL(20,2);
    DECLARE v_daily_total DECIMAL(20,2);
    DECLARE v_monthly_total DECIMAL(20,2);
    
    -- Get user balance
    SELECT balance INTO v_balance
    FROM users WHERE id = p_user_id;
    
    -- Get withdrawal limits
    SELECT 
        CAST(setting_value AS DECIMAL(20,2))
    INTO v_daily_limit
    FROM system_settings 
    WHERE setting_key = 'max_withdrawal_daily';
    
    -- Check balance
    IF v_balance < p_amount THEN
        SET p_success = FALSE;
        SET p_message = 'Insufficient balance';
        
    -- Check daily limit
    ELSEIF (SELECT SUM(amount) 
            FROM transactions 
            WHERE user_id = p_user_id 
            AND type = 'withdrawal' 
            AND DATE(created_at) = CURDATE()) + p_amount > v_daily_limit THEN
        SET p_success = FALSE;
        SET p_message = 'Daily withdrawal limit exceeded';
        
    ELSE
        -- Process withdrawal
        INSERT INTO transactions (
            user_id,
            type,
            amount,
            balance_before,
            balance_after,
            status,
            transaction_id
        ) VALUES (
            p_user_id,
            'withdrawal',
            p_amount,
            v_balance,
            v_balance - p_amount,
            'pending',
            UUID()
        );
        
        UPDATE users 
        SET balance = balance - p_amount
        WHERE id = p_user_id;
        
        SET p_success = TRUE;
        SET p_message = 'Withdrawal processed successfully';
    END IF;
END//

DELIMITER ; 