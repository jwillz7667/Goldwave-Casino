USE casino_db;

-- Users table indexes
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);

-- Game Sessions indexes
CREATE INDEX idx_game_sessions_status ON game_sessions(status);
CREATE INDEX idx_game_sessions_started_at ON game_sessions(started_at);
CREATE INDEX idx_game_sessions_user_game ON game_sessions(user_id, game_id);

-- Transactions indexes
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_transaction_id ON transactions(transaction_id);

-- Games indexes
CREATE INDEX idx_games_provider_category ON games(provider_id, category_id);
CREATE INDEX idx_games_status ON games(status);
CREATE INDEX idx_games_slug ON games(slug);

-- Jackpots indexes
CREATE INDEX idx_jackpots_status ON jackpots(status);
CREATE INDEX idx_jackpots_current_amount ON jackpots(current_amount);

-- User Bonuses indexes
CREATE INDEX idx_user_bonuses_status ON user_bonuses(status);
CREATE INDEX idx_user_bonuses_expires_at ON user_bonuses(expires_at);
CREATE INDEX idx_user_bonuses_user_bonus ON user_bonuses(user_id, bonus_id);

-- Game Statistics indexes
CREATE INDEX idx_game_statistics_totals ON game_statistics(total_bets, total_wins);

-- User Statistics indexes
CREATE INDEX idx_user_statistics_totals ON user_statistics(total_deposits, total_withdrawals, total_bets, total_wins); 