#!/bin/bash
# Установка phpMyAdmin

set -e

echo "=== Установка зависимостей для phpMyAdmin ==="
apt install -y wget unzip php-mbstring php-zip php-gd php-json php-curl

echo ""
echo "=== Скачивание phpMyAdmin ==="
cd /tmp
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O phpmyadmin.zip

echo ""
echo "=== Распаковка phpMyAdmin ==="
unzip -q phpmyadmin.zip
PMA_DIR=$(find /tmp -maxdepth 1 -type d -name "phpMyAdmin-*" | head -1)
mv "$PMA_DIR" /var/www/html/phpmyadmin

echo ""
echo "=== Настройка phpMyAdmin ==="
cd /var/www/html/phpmyadmin
cp config.sample.inc.php config.inc.php

# Генерация случайного blowfish_secret
BLOWFISH_SECRET=$(openssl rand -base64 32)
sed -i "s/\['blowfish_secret'\] = ''/['blowfish_secret'] = '$BLOWFISH_SECRET'/" config.inc.php

# Создание директории для временных файлов
mkdir -p /var/www/html/phpmyadmin/tmp
chown -R www-data:www-data /var/www/html/phpmyadmin
chmod 755 /var/www/html/phpmyadmin/tmp

echo ""
echo "=== Настройка Nginx для phpMyAdmin ==="
cat > /etc/nginx/sites-available/phpmyadmin << 'NGINXEOF'
server {
    listen 8080;
    listen [::]:8080;
    
    root /var/www/html/phpmyadmin;
    index index.php index.html;
    
    server_name localhost;
    
    access_log /var/log/nginx/phpmyadmin_access.log;
    error_log /var/log/nginx/phpmyadmin_error.log;
    
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
    
    location ~ /(libraries|setup/frames|setup/libs) {
        deny all;
        return 404;
    }
}
NGINXEOF

# Активация конфигурации
ln -sf /etc/nginx/sites-available/phpmyadmin /etc/nginx/sites-enabled/phpmyadmin

# Проверка и перезагрузка Nginx
nginx -t
systemctl reload nginx

echo ""
echo "=== phpMyAdmin установлен! ==="
echo "URL: http://localhost:8080"
echo "Пользователь БД: testuser"
echo "Пароль: testpass123"
echo "База данных: testdb"

