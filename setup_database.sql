-- Create the database with proper character set and collation
CREATE DATABASE IF NOT EXISTS casino_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create the user if it doesn't exist and set the password
CREATE USER IF NOT EXISTS 'casino_user'@'localhost' IDENTIFIED BY 'strong_password';

-- Grant privileges to the user
GRANT ALL PRIVILEGES ON casino_db.* TO 'casino_user'@'localhost';

-- Apply the privileges
FLUSH PRIVILEGES; 