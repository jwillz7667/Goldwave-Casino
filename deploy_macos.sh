#!/bin/bash

# Exit on error
set -e

# Variables
DOMAIN="goldwavecasino.com"
PROJECT_ROOT="/Users/$(whoami)/Sites/goldwavecasino"
NGINX_CONF="/opt/homebrew/etc/nginx/servers/$DOMAIN.conf"
PHP_VERSION="8.1"

echo "Starting deployment for $DOMAIN..."

# Update Homebrew
echo "Updating Homebrew packages..."
brew update && brew upgrade

# Install required packages
echo "Installing required packages..."
brew install nginx mysql@8.0 redis node
brew tap shivammathur/php
brew install shivammathur/php/php@$PHP_VERSION

# Install PHP extensions
echo "Installing PHP extensions..."
pecl install imagick
pecl install redis

# Link PHP and MySQL
echo "Linking PHP and MySQL..."
brew link php@$PHP_VERSION
brew link mysql@8.0

# Install PM2
echo "Installing PM2..."
npm install -g pm2

# Create project directory
echo "Creating project directory..."
mkdir -p $PROJECT_ROOT
chown -R $(whoami):staff $PROJECT_ROOT

# Create SSL directory
echo "Creating SSL directory..."
sudo mkdir -p /opt/homebrew/etc/nginx/ssl/$DOMAIN
sudo chmod 700 /opt/homebrew/etc/nginx/ssl/$DOMAIN

# Copy SSL certificates
echo "Copying SSL certificates..."
sudo cp PTwebsocket/ssl/crt.crt /opt/homebrew/etc/nginx/ssl/$DOMAIN/cert.pem
sudo cp PTwebsocket/ssl/key.key /opt/homebrew/etc/nginx/ssl/$DOMAIN/key.pem
sudo chmod 600 /opt/homebrew/etc/nginx/ssl/$DOMAIN/*.pem

# Create Nginx servers directory if it doesn't exist
mkdir -p /opt/homebrew/etc/nginx/servers

# Copy Nginx configuration
echo "Configuring Nginx..."
cp goldwavecasino.conf $NGINX_CONF
brew services restart nginx

# Configure PHP
echo "Configuring PHP..."
PHP_INI="/opt/homebrew/etc/php/$PHP_VERSION/php.ini"
sed -i '' 's/upload_max_filesize = .*/upload_max_filesize = 64M/' $PHP_INI
sed -i '' 's/post_max_size = .*/post_max_size = 64M/' $PHP_INI
sed -i '' 's/memory_limit = .*/memory_limit = 256M/' $PHP_INI
brew services restart php@$PHP_VERSION

# Configure MySQL
echo "Configuring MySQL..."
brew services start mysql@8.0
mysql -u root -p'6996' -e "CREATE DATABASE IF NOT EXISTS casino_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p'6996' -e "CREATE USER IF NOT EXISTS 'casino_user'@'localhost' IDENTIFIED BY 'strong_password';"
mysql -u root -p'6996' -e "GRANT ALL PRIVILEGES ON casino_db.* TO 'casino_user'@'localhost';"
mysql -u root -p'6996' -e "FLUSH PRIVILEGES;"

# Import database schema and data
echo "Importing database..."
mysql -u casino_user -p'strong_password' casino_db < setup_database.sql
mysql -u casino_user -p'strong_password' casino_db < casino_schema.sql
mysql -u casino_user -p'strong_password' casino_db < casino_indexes.sql
mysql -u casino_user -p'strong_password' casino_db < casino_initial_data_final.sql

# Configure Redis
echo "Configuring Redis..."
REDIS_CONF="/opt/homebrew/etc/redis.conf"
sed -i '' 's/# maxmemory .*/maxmemory 512mb/' $REDIS_CONF
sed -i '' 's/# maxmemory-policy .*/maxmemory-policy allkeys-lru/' $REDIS_CONF
brew services restart redis

# Deploy application files
echo "Deploying application files..."
rsync -av --exclude='.git' --exclude='deploy*.sh' --exclude='goldwavecasino.conf' . $PROJECT_ROOT/

# Set permissions
echo "Setting permissions..."
chmod -R 775 $PROJECT_ROOT/storage
chmod -R 775 $PROJECT_ROOT/bootstrap/cache

# Install Composer if not installed
if ! command -v composer &> /dev/null; then
    echo "Installing Composer..."
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    php -r "unlink('composer-setup.php');"
fi

# Install Laravel dependencies
echo "Installing Laravel dependencies..."
cd $PROJECT_ROOT
composer install

# Generate Laravel application key
echo "Configuring Laravel..."
php artisan key:generate
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start PM2 processes
echo "Starting PM2 processes..."
pm2 start ecosystem.config.js
pm2 save
pm2 startup

echo "Deployment completed successfully!"
echo "Please verify the following services are running:"
echo "1. Nginx: brew services list | grep nginx"
echo "2. PHP-FPM: brew services list | grep php"
echo "3. MySQL: brew services list | grep mysql"
echo "4. Redis: brew services list | grep redis"
echo "5. PM2 processes: pm2 list"

echo "Your application should now be accessible at https://$DOMAIN" 