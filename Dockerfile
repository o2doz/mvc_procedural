# Use official PHP 8 image with Apache
FROM php:8.4-cli

# Install MySQLi extension
RUN docker-php-ext-install pdo pdo_mysql mysqli

# Set working directory
WORKDIR /var/www/html

# Copy project files (if you have any)
COPY . .

# Expose port 8000 for PHP's built-in server
EXPOSE 8000

# Start PHP built-in server
CMD ["php", "-S", "0.0.0.0:8000", "-t", "/var/www/html"]
