USE casino_db;

-- Insert Game Categories
INSERT INTO game_categories (name, slug, description, status) VALUES
('Slots', 'slots', 'Classic and video slot machines', true),
('Table Games', 'table-games', 'Traditional casino table games', true),
('Live Casino', 'live-casino', 'Real-time live dealer games', true),
('Poker', 'poker', 'Video poker and poker games', true),
('Arcade', 'arcade', 'Skill-based arcade games', true);

-- Insert Game Providers
INSERT INTO game_providers (name, slug, api_url, status) VALUES
('Evolution Gaming', 'evolution', 'https://api.evolution.com', true),
('NetEnt', 'netent', 'https://api.netent.com', true),
('Playtech', 'playtech', 'https://api.playtech.com', true),
('Microgaming', 'microgaming', 'https://api.microgaming.com', true),
('Pragmatic Play', 'pragmatic', 'https://api.pragmaticplay.com', true);

-- Insert Sample Games
INSERT INTO games (provider_id, category_id, name, slug, description, min_bet, max_bet, rtp, status) VALUES
(1, 1, 'Starburst', 'starburst', 'Popular space-themed slot game', 0.10, 100.00, 96.10, true),
(2, 1, 'Gonzo''s Quest', 'gonzos-quest', 'Adventure-themed slot game', 0.20, 200.00, 95.97, true),
(3, 2, 'Blackjack VIP', 'blackjack-vip', 'Premium blackjack experience', 1.00, 1000.00, 99.50, true),
(4, 2, 'European Roulette', 'european-roulette', 'Classic European roulette', 0.50, 500.00, 97.30, true),
(5, 3, 'Live Baccarat', 'live-baccarat', 'Live dealer baccarat', 5.00, 2000.00, 98.94, true);

-- Insert Payment Methods
INSERT INTO payment_methods (name, type, min_deposit, max_deposit, min_withdrawal, max_withdrawal, status) VALUES
('Visa/Mastercard', 'credit_card', 10.00, 5000.00, 20.00, 5000.00, true),
('PayPal', 'e-wallet', 10.00, 10000.00, 20.00, 10000.00, true),
('Bitcoin', 'crypto', 20.00, 50000.00, 50.00, 50000.00, true),
('Bank Transfer', 'bank_transfer', 50.00, 100000.00, 100.00, 100000.00, true);

-- Insert Jackpots
INSERT INTO jackpots (name, current_amount, minimum_amount, maximum_amount, increment_rate, status) VALUES
('Mini Jackpot', 1000.00, 1000.00, 5000.00, 0.0010, true),
('Major Jackpot', 10000.00, 10000.00, 50000.00, 0.0015, true),
('Mega Jackpot', 100000.00, 100000.00, 1000000.00, 0.0020, true);

-- Insert Bonuses
INSERT INTO bonuses (name, type, amount, percentage, wagering_requirement, min_deposit, max_bonus, validity_days, status) VALUES
('Welcome Bonus', 'deposit', NULL, 100.00, 35.00, 20.00, 500.00, 30, true),
('No Deposit Bonus', 'no_deposit', 10.00, NULL, 40.00, NULL, 10.00, 7, true),
('Cashback Bonus', 'cashback', NULL, 10.00, 10.00, NULL, 1000.00, 7, true),
('Free Spins', 'free_spins', 50.00, NULL, 35.00, 20.00, 50.00, 7, true);

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