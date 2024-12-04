USE casino_db;

-- Insert Game Providers
INSERT INTO game_providers (name, slug, api_url, status) VALUES
('Evolution Gaming', 'evolution', 'https://api.evolution.com', 1),
('NetEnt', 'netent', 'https://api.netent.com', 1),
('Playtech', 'playtech', 'https://api.playtech.com', 1),
('Microgaming', 'microgaming', 'https://api.microgaming.com', 1),
('Pragmatic Play', 'pragmatic', 'https://api.pragmaticplay.com', 1);

-- Insert Sample Games
INSERT INTO games (provider_id, name, slug, description, game_id, type, min_bet, max_bet, rtp, status) VALUES
(1, 'Starburst', 'starburst', 'Popular space-themed slot game', 'EVO_STAR_01', 'slots', 0.10, 100.00, 96.10, 'active'),
(2, 'Gonzo''s Quest', 'gonzos-quest', 'Adventure-themed slot game', 'NET_GONZO_01', 'slots', 0.20, 200.00, 95.97, 'active'),
(3, 'Blackjack VIP', 'blackjack-vip', 'Premium blackjack experience', 'PT_BJ_VIP_01', 'slots', 1.00, 1000.00, 99.50, 'active'),
(4, 'European Roulette', 'european-roulette', 'Classic European roulette', 'MG_EU_ROUL_01', 'slots', 0.50, 500.00, 97.30, 'active'),
(5, 'Live Baccarat', 'live-baccarat', 'Live dealer baccarat', 'PP_BACC_01', 'slots', 5.00, 2000.00, 98.94, 'active');

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