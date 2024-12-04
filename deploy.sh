#!/bin/bash

# Exit on error
set -e

# Variables
DOMAIN="goldwavecasino.com"
PROJECT_ROOT="/var/www/goldwavecasino"
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
PHP_VERSION="8.1"

echo "Starting deployment for $DOMAIN..."

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt install -y nginx mysql-server redis-server nodejs npm \
    php$PHP_VERSION php$PHP_VERSION-fpm php$PHP_VERSION-mysql \
    php$PHP_VERSION-curl php$PHP_VERSION-json php$PHP_VERSION-mbstring \
    php$PHP_VERSION-xml php$PHP_VERSION-zip php$PHP_VERSION-gd \
    php$PHP_VERSION-redis php$PHP_VERSION-imagick \
    certbot python3-certbot-nginx git unzip

# Install PM2
echo "Installing PM2..."
sudo npm install -g pm2

# Create project directory
echo "Creating project directory..."
sudo mkdir -p $PROJECT_ROOT
sudo chown -R $USER:$USER $PROJECT_ROOT

# Create SSL directory
echo "Creating SSL directory..."
sudo mkdir -p /etc/nginx/ssl/$DOMAIN
sudo chmod 700 /etc/nginx/ssl/$DOMAIN

# Copy SSL certificates (assuming they're in the current directory)
echo "Copying SSL certificates..."
sudo cp PTwebsocket/ssl/crt.crt /etc/nginx/ssl/$DOMAIN/cert.pem
sudo cp PTwebsocket/ssl/key.key /etc/nginx/ssl/$DOMAIN/key.pem
sudo chmod 600 /etc/nginx/ssl/$DOMAIN/*.pem

# Copy Nginx configuration
echo "Configuring Nginx..."
sudo cp goldwavecasino.conf $NGINX_CONF
sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

# Configure PHP
echo "Configuring PHP..."
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' /etc/php/$PHP_VERSION/fpm/php.ini
sudo sed -i 's/post_max_size = .*/post_max_size = 64M/' /etc/php/$PHP_VERSION/fpm/php.ini
sudo sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/$PHP_VERSION/fpm/php.ini
sudo systemctl restart php$PHP_VERSION-fpm

# Configure MySQL
echo "Configuring MySQL..."
sudo mysql -u root -p'6996' -e "CREATE DATABASE IF NOT EXISTS casino_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -u root -p'6996' -e "CREATE USER IF NOT EXISTS 'casino_user'@'localhost' IDENTIFIED BY 'strong_password';"
sudo mysql -u root -p'6996' -e "GRANT ALL PRIVILEGES ON casino_db.* TO 'casino_user'@'localhost';"
sudo mysql -u root -p'6996' -e "FLUSH PRIVILEGES;"

# Import database schema and data
echo "Importing database..."
mysql -u casino_user -p'strong_password' casino_db < setup_database.sql
mysql -u casino_user -p'strong_password' casino_db < casino_schema.sql
mysql -u casino_user -p'strong_password' casino_db < casino_indexes.sql
mysql -u casino_user -p'strong_password' casino_db < casino_initial_data_final.sql

# Configure Redis
echo "Configuring Redis..."
sudo sed -i 's/# maxmemory .*/maxmemory 512mb/' /etc/redis/redis.conf
sudo sed -i 's/# maxmemory-policy .*/maxmemory-policy allkeys-lru/' /etc/redis/redis.conf
sudo systemctl restart redis-server

# Deploy application files
echo "Deploying application files..."
rsync -av --exclude='.git' --exclude='deploy.sh' --exclude='goldwavecasino.conf' . $PROJECT_ROOT/

# Set permissions
echo "Setting permissions..."
sudo chown -R www-data:www-data $PROJECT_ROOT/storage
sudo chown -R www-data:www-data $PROJECT_ROOT/bootstrap/cache
sudo chmod -R 775 $PROJECT_ROOT/storage
sudo chmod -R 775 $PROJECT_ROOT/bootstrap/cache

# Generate Laravel application key
echo "Configuring Laravel..."
cd $PROJECT_ROOT
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
echo "Please configure your Cloudflare DNS with the following settings:"
echo "1. A record: $DOMAIN -> your-server-ip"
echo "2. Enable Cloudflare proxy (orange cloud)"
echo "3. Enable SSL/TLS mode: Full (strict)"
echo "4. Enable WebSocket support in Cloudflare Network settings" 