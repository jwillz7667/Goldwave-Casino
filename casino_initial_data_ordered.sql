USE casino_db;

-- Insert Game Categories
INSERT INTO game_categories (id, name, slug, description, status) VALUES
(1, 'Slots', 'slots', 'Classic and video slot machines', 1),
(2, 'Table Games', 'table-games', 'Traditional casino table games', 1),
(3, 'Live Casino', 'live-casino', 'Real-time live dealer games', 1),
(4, 'Poker', 'poker', 'Video poker and poker games', 1),
(5, 'Arcade', 'arcade', 'Skill-based arcade games', 1);

-- Insert Game Providers
INSERT INTO game_providers (id, name, slug, api_url, status) VALUES
(1, 'Evolution Gaming', 'evolution', 'https://api.evolution.com', 1),
(2, 'NetEnt', 'netent', 'https://api.netent.com', 1),
(3, 'Playtech', 'playtech', 'https://api.playtech.com', 1),
(4, 'Microgaming', 'microgaming', 'https://api.microgaming.com', 1),
(5, 'Pragmatic Play', 'pragmatic', 'https://api.pragmaticplay.com', 1);

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