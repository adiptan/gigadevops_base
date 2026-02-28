#!/bin/bash
# Задание 3: Развёртывание LEMP стека
# LEMP = Linux + Nginx + MySQL/MariaDB + PHP

set -e  # Останавливать при ошибках

echo "=== Шаг 1: Обновление списка пакетов ==="
apt update

echo ""
echo "=== Шаг 2: Установка Nginx ==="
apt install -y nginx
systemctl status nginx --no-pager | head -10
nginx -v

echo ""
echo "=== Шаг 3: Установка MariaDB ==="
apt install -y mariadb-server mariadb-client
systemctl status mariadb --no-pager | head -10
mysql --version

echo ""
echo "=== Шаг 4: Установка PHP 8.3 и модулей ==="
apt install -y php-fpm php-mysql php-cli php-curl php-gd php-mbstring php-xml php-zip php-json
php -v
systemctl status php8.3-fpm --no-pager | head -10

echo ""
echo "=== Шаг 5: Проверка установленных сервисов ==="
systemctl is-active nginx
systemctl is-active mariadb
systemctl is-active php8.3-fpm

echo ""
echo "=== Шаг 6: Настройка MariaDB ==="
# Создание тестовой БД и пользователя
mysql -e "CREATE DATABASE IF NOT EXISTS testdb;"
mysql -e "CREATE USER IF NOT EXISTS 'testuser'@'localhost' IDENTIFIED BY 'testpass123';"
mysql -e "GRANT ALL PRIVILEGES ON testdb.* TO 'testuser'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
mysql -e "SHOW DATABASES;"

echo ""
echo "=== Шаг 7: Создание тестового PHP файла ==="
mkdir -p /var/www/html/test
cat > /var/www/html/test/info.php << 'PHPEOF'
<?php
phpinfo();
?>
PHPEOF

cat > /var/www/html/test/db_test.php << 'PHPEOF'
<?php
$servername = "localhost";
$username = "testuser";
$password = "testpass123";
$dbname = "testdb";

// Создание соединения
$conn = new mysqli($servername, $username, $password, $dbname);

// Проверка соединения
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully to database: " . $dbname;
$conn->close();
?>
PHPEOF

chown -R www-data:www-data /var/www/html/test

echo ""
echo "=== Шаг 8: Настройка Nginx для PHP ==="
cat > /etc/nginx/sites-available/test << 'NGINXEOF'
server {
    listen 80;
    listen [::]:80;
    
    root /var/www/html/test;
    index index.php index.html index.htm;
    
    server_name localhost;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    }
    
    location ~ /\.ht {
        deny all;
    }
}
NGINXEOF

# Активация конфигурации
ln -sf /etc/nginx/sites-available/test /etc/nginx/sites-enabled/test
rm -f /etc/nginx/sites-enabled/default

# Проверка конфигурации
nginx -t

# Перезагрузка Nginx
systemctl reload nginx

echo ""
echo "=== LEMP стек установлен! ==="
echo "Nginx: $(nginx -v 2>&1)"
echo "MariaDB: $(mysql --version)"
echo "PHP: $(php -v | head -1)"
echo ""
echo "Тестовые файлы:"
echo "  - http://localhost/info.php (phpinfo)"
echo "  - http://localhost/db_test.php (тест БД)"

