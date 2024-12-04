USE casino_db;

-- Insert Sample Games
INSERT INTO games (provider_id, category_id, name, slug, description, min_bet, max_bet, rtp, status) VALUES
(1, 1, 'Starburst', 'starburst', 'Popular space-themed slot game', 0.10, 100.00, 96.10, 1),
(2, 1, 'Gonzo''s Quest', 'gonzos-quest', 'Adventure-themed slot game', 0.20, 200.00, 95.97, 1),
(3, 1, 'Blackjack VIP', 'blackjack-vip', 'Premium blackjack experience', 1.00, 1000.00, 99.50, 1),
(4, 1, 'European Roulette', 'european-roulette', 'Classic European roulette', 0.50, 500.00, 97.30, 1),
(5, 1, 'Live Baccarat', 'live-baccarat', 'Live dealer baccarat', 5.00, 2000.00, 98.94, 1);

-- Insert System Settings
INSERT INTO system_settings (setting_key, setting_value) VALUES
('site_name', 'Goldwave Casino'),
('maintenance_mode', 'false'),
('min_withdrawal', '20.00'),
('max_withdrawal_daily', '5000.00'),
('max_withdrawal_monthly', '50000.00'),
('bonus_enabled', 'true'),
('jackpot_enabled', 'true'),
('chat_enabled', 'true'),
('default_currency', 'USD'),
('timezone', 'UTC'); 