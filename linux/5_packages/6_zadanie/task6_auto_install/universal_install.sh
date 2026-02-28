#!/bin/bash
#===============================================================================
# Универсальный скрипт установки LEMP стека
# Поддерживает: Ubuntu/Debian (apt), CentOS/RHEL (yum/dnf)
# Автор: Vovchik
# Дата: 2026-02-28
#===============================================================================

set -e  # Останавливаться при ошибках

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции вывода
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка прав root
if [ "$EUID" -ne 0 ]; then 
    log_error "Скрипт должен быть запущен с правами root"
    exit 1
fi

#===============================================================================
# Шаг 1: Определение ОС и пакетного менеджера
#===============================================================================
log_info "Определение операционной системы..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID
else
    log_error "Не удалось определить ОС"
    exit 1
fi

# Определение пакетного менеджера
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
    PKG_INSTALL="apt-get install -y"
    PKG_UPDATE="apt-get update"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    PKG_INSTALL="dnf install -y"
    PKG_UPDATE="dnf check-update || true"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    PKG_INSTALL="yum install -y"
    PKG_UPDATE="yum check-update || true"
else
    log_error "Неподдерживаемый пакетный менеджер"
    exit 1
fi

log_success "ОС определена: $OS $OS_VERSION"
log_success "Пакетный менеджер: $PKG_MANAGER"

#===============================================================================
# Шаг 2: Обновление списка пакетов
#===============================================================================
log_info "Обновление списка пакетов..."
$PKG_UPDATE
log_success "Список пакетов обновлён"

#===============================================================================
# Шаг 3: Установка Nginx
#===============================================================================
log_info "Установка Nginx..."
$PKG_INSTALL nginx

# Запуск и автозагрузка
systemctl start nginx
systemctl enable nginx

log_success "Nginx установлен и запущен"
nginx -v

#===============================================================================
# Шаг 4: Установка MariaDB/MySQL
#===============================================================================
log_info "Установка MariaDB..."

if [ "$PKG_MANAGER" == "apt" ]; then
    $PKG_INSTALL mariadb-server mariadb-client
else
    $PKG_INSTALL mariadb-server mariadb
fi

# Запуск и автозагрузка
systemctl start mariadb
systemctl enable mariadb

log_success "MariaDB установлена и запущена"
mysql --version

#===============================================================================
# Шаг 5: Установка PHP
#===============================================================================
log_info "Установка PHP и модулей..."

if [ "$PKG_MANAGER" == "apt" ]; then
    # Ubuntu/Debian
    PHP_PACKAGES="php-fpm php-mysql php-cli php-curl php-gd php-mbstring php-xml php-zip"
    $PKG_INSTALL $PHP_PACKAGES
    
    # Определение версии PHP
    PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
    PHP_FPM_SERVICE="php${PHP_VERSION}-fpm"
else
    # CentOS/RHEL
    PHP_PACKAGES="php php-fpm php-mysqlnd php-cli php-curl php-gd php-mbstring php-xml php-zip"
    $PKG_INSTALL $PHP_PACKAGES
    PHP_FPM_SERVICE="php-fpm"
fi

# Запуск и автозагрузка PHP-FPM
systemctl start $PHP_FPM_SERVICE
systemctl enable $PHP_FPM_SERVICE

log_success "PHP установлен"
php -v

#===============================================================================
# Шаг 6: Настройка Nginx для работы с PHP
#===============================================================================
log_info "Настройка Nginx для PHP..."

NGINX_CONF="/etc/nginx/sites-available/default"
if [ "$PKG_MANAGER" != "apt" ]; then
    NGINX_CONF="/etc/nginx/conf.d/default.conf"
fi

# Определение пути к PHP-FPM сокету
if [ "$PKG_MANAGER" == "apt" ]; then
    PHP_SOCK="/run/php/php${PHP_VERSION}-fpm.sock"
else
    PHP_SOCK="/run/php-fpm/www.sock"
fi

cat > "$NGINX_CONF" << NGINXCONF
server {
    listen 80;
    root /var/www/html;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        fastcgi_pass unix:${PHP_SOCK};
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
NGINXCONF

# Проверка и перезагрузка Nginx
nginx -t && systemctl reload nginx

log_success "Nginx настроен для работы с PHP"

#===============================================================================
# Шаг 7: Создание тестовой базы данных
#===============================================================================
log_info "Создание тестовой базы данных..."

DB_NAME="testapp"
DB_USER="testuser"
DB_PASS="SecurePass123!"

mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Создание тестовой таблицы
mysql ${DB_NAME} -e "CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);"

# Вставка тестовых данных
mysql ${DB_NAME} -e "INSERT INTO users (username, email) VALUES 
    ('admin', 'admin@example.com'),
    ('testuser', 'test@example.com');"

log_success "Тестовая БД создана: ${DB_NAME}"
log_info "Пользователь БД: ${DB_USER}"
log_info "Пароль БД: ${DB_PASS}"

#===============================================================================
# Шаг 8: Создание тестового PHP файла
#===============================================================================
log_info "Создание тестовых PHP файлов..."

mkdir -p /var/www/html

# phpinfo
cat > /var/www/html/info.php << 'PHPINFO'
<?php
phpinfo();
?>
PHPINFO

# Тест подключения к БД
cat > /var/www/html/db_test.php << DBTEST
<?php
\$conn = new mysqli("localhost", "${DB_USER}", "${DB_PASS}", "${DB_NAME}");

if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}

echo "<h2>Database Connection Test</h2>";
echo "<p><strong>Status:</strong> ✅ Connected successfully</p>";
echo "<p><strong>Database:</strong> ${DB_NAME}</p>";

\$result = \$conn->query("SELECT * FROM users");
echo "<h3>Users Table:</h3><ul>";
while(\$row = \$result->fetch_assoc()) {
    echo "<li>ID: " . \$row["id"] . " - " . \$row["username"] . " (" . \$row["email"] . ")</li>";
}
echo "</ul>";

\$conn->close();
?>
DBTEST

chown -R www-data:www-data /var/www/html 2>/dev/null || chown -R nginx:nginx /var/www/html

log_success "Тестовые файлы созданы"

#===============================================================================
# Шаг 9: Настройка firewall
#===============================================================================
log_info "Настройка firewall..."

if command -v ufw &> /dev/null; then
    # Ubuntu/Debian (ufw)
    ufw --force enable
    ufw allow 22/tcp    # SSH
    ufw allow 80/tcp    # HTTP
    ufw allow 443/tcp   # HTTPS
    ufw reload
    log_success "UFW настроен (разрешены порты: 22, 80, 443)"
    
elif command -v firewall-cmd &> /dev/null; then
    # CentOS/RHEL (firewalld)
    systemctl start firewalld
    systemctl enable firewalld
    firewall-cmd --permanent --add-service=ssh
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
    log_success "Firewalld настроен (разрешены: SSH, HTTP, HTTPS)"
    
else
    log_warning "Firewall не найден, пропускаем настройку"
fi

#===============================================================================
# Шаг 10: Итоговая информация
#===============================================================================
echo ""
echo "==============================================================================="
log_success "Установка завершена успешно!"
echo "==============================================================================="
echo ""
echo "Установленные компоненты:"
echo "  - Nginx:   $(nginx -v 2>&1 | cut -d'/' -f2)"
echo "  - MariaDB: $(mysql --version | awk '{print $5}' | sed 's/,//')"
echo "  - PHP:     $(php -v | head -1 | awk '{print $2}')"
echo ""
echo "База данных:"
echo "  - Имя БД:       ${DB_NAME}"
echo "  - Пользователь: ${DB_USER}"
echo "  - Пароль:       ${DB_PASS}"
echo "  - Таблица:      users (2 записи)"
echo ""
echo "Тестовые страницы:"
echo "  - http://localhost/info.php     (phpinfo)"
echo "  - http://localhost/db_test.php  (тест БД)"
echo ""
echo "Firewall:"
echo "  - Разрешённые порты: 22 (SSH), 80 (HTTP), 443 (HTTPS)"
echo ""
echo "==============================================================================="
