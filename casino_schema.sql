-- Use the casino database
USE casino_db;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    balance DECIMAL(20, 2) DEFAULT 0.00,
    bonus_balance DECIMAL(20, 2) DEFAULT 0.00,
    status ENUM('active', 'suspended', 'banned') DEFAULT 'active',
    last_login TIMESTAMP NULL,
    remember_token VARCHAR(100) NULL,
    email_verified_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- User Profiles Table
CREATE TABLE IF NOT EXISTS user_profiles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    date_of_birth DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    address TEXT,
    phone VARCHAR(50),
    currency VARCHAR(10) DEFAULT 'USD',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Game Categories Table
CREATE TABLE IF NOT EXISTS game_categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    status BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Game Providers Table
CREATE TABLE IF NOT EXISTS game_providers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    api_url VARCHAR(255),
    api_key VARCHAR(255),
    status BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Games Table
CREATE TABLE IF NOT EXISTS games (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    provider_id BIGINT UNSIGNED NOT NULL,
    category_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    thumbnail VARCHAR(255),
    min_bet DECIMAL(20, 2) NOT NULL,
    max_bet DECIMAL(20, 2) NOT NULL,
    rtp DECIMAL(5, 2),
    status BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES game_providers(id),
    FOREIGN KEY (category_id) REFERENCES game_categories(id)
);

-- Game Sessions Table
CREATE TABLE IF NOT EXISTS game_sessions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    game_id BIGINT UNSIGNED NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    status ENUM('active', 'completed', 'terminated') DEFAULT 'active',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (game_id) REFERENCES games(id)
);

-- Transactions Table
CREATE TABLE IF NOT EXISTS transactions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    game_session_id BIGINT UNSIGNED NULL,
    type ENUM('deposit', 'withdrawal', 'bet', 'win', 'bonus', 'refund') NOT NULL,
    amount DECIMAL(20, 2) NOT NULL,
    balance_before DECIMAL(20, 2) NOT NULL,
    balance_after DECIMAL(20, 2) NOT NULL,
    status ENUM('pending', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
    transaction_id VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (game_session_id) REFERENCES game_sessions(id)
);

-- Jackpots Table
CREATE TABLE IF NOT EXISTS jackpots (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    current_amount DECIMAL(20, 2) NOT NULL DEFAULT 0.00,
    minimum_amount DECIMAL(20, 2) NOT NULL,
    maximum_amount DECIMAL(20, 2) NOT NULL,
    increment_rate DECIMAL(5, 4) NOT NULL,
    status BOOLEAN DEFAULT true,
    last_won_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Jackpot Winners Table
CREATE TABLE IF NOT EXISTS jackpot_winners (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    jackpot_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(20, 2) NOT NULL,
    won_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (jackpot_id) REFERENCES jackpots(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Payment Methods Table
CREATE TABLE IF NOT EXISTS payment_methods (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type ENUM('credit_card', 'e-wallet', 'crypto', 'bank_transfer') NOT NULL,
    min_deposit DECIMAL(20, 2) NOT NULL,
    max_deposit DECIMAL(20, 2) NOT NULL,
    min_withdrawal DECIMAL(20, 2) NOT NULL,
    max_withdrawal DECIMAL(20, 2) NOT NULL,
    status BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- User Payment Methods Table
CREATE TABLE IF NOT EXISTS user_payment_methods (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    payment_method_id BIGINT UNSIGNED NOT NULL,
    details JSON NOT NULL,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id)
);

-- Bonuses Table
CREATE TABLE IF NOT EXISTS bonuses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type ENUM('deposit', 'no_deposit', 'cashback', 'free_spins') NOT NULL,
    amount DECIMAL(20, 2) NULL,
    percentage DECIMAL(5, 2) NULL,
    wagering_requirement DECIMAL(5, 2) NOT NULL,
    min_deposit DECIMAL(20, 2) NULL,
    max_bonus DECIMAL(20, 2) NULL,
    validity_days INT NOT NULL,
    status BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- User Bonuses Table
CREATE TABLE IF NOT EXISTS user_bonuses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    bonus_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(20, 2) NOT NULL,
    wagering_remaining DECIMAL(20, 2) NOT NULL,
    status ENUM('active', 'completed', 'expired', 'cancelled') DEFAULT 'active',
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (bonus_id) REFERENCES bonuses(id)
);

-- Game Statistics Table
CREATE TABLE IF NOT EXISTS game_statistics (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    game_id BIGINT UNSIGNED NOT NULL,
    total_bets INT DEFAULT 0,
    total_wins INT DEFAULT 0,
    total_bet_amount DECIMAL(20, 2) DEFAULT 0.00,
    total_win_amount DECIMAL(20, 2) DEFAULT 0.00,
    biggest_win DECIMAL(20, 2) DEFAULT 0.00,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (game_id) REFERENCES games(id)
);

-- User Statistics Table
CREATE TABLE IF NOT EXISTS user_statistics (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    total_deposits DECIMAL(20, 2) DEFAULT 0.00,
    total_withdrawals DECIMAL(20, 2) DEFAULT 0.00,
    total_bets DECIMAL(20, 2) DEFAULT 0.00,
    total_wins DECIMAL(20, 2) DEFAULT 0.00,
    biggest_win DECIMAL(20, 2) DEFAULT 0.00,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Chat Messages Table
CREATE TABLE IF NOT EXISTS chat_messages (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- System Settings Table
CREATE TABLE IF NOT EXISTS system_settings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(255) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
); 