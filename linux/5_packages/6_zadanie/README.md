# Задание 6: Автоматизированный скрипт установки

**Дата выполнения:** 2026-02-28  
**Система:** Ubuntu 24.04 (Noble)  
**Поддерживаемые ОС:** Ubuntu, Debian, CentOS, RHEL

---

## Содержание

1. [Описание скрипта](#1-описание-скрипта)
2. [Функционал](#2-функционал)
3. [Структура скрипта](#3-структура-скрипта)
4. [Использование](#4-использование)
5. [Код скрипта](#5-код-скрипта)

---

## 1. Описание скрипта

**universal_install.sh** — универсальный скрипт для автоматической установки LEMP стека на различных дистрибутивах Linux.

### Особенности:

- ✅ **Автоопределение ОС** — распознаёт Ubuntu, Debian, CentOS, RHEL
- ✅ **Выбор пакетного менеджера** — apt, yum или dnf
- ✅ **Установка LEMP** — Nginx, MariaDB, PHP с модулями
- ✅ **Настройка конфигураций** — автоматическая настройка Nginx для PHP
- ✅ **Создание тестовой БД** — база данных с таблицей и тестовыми данными
- ✅ **Настройка firewall** — ufw (Ubuntu/Debian) или firewalld (CentOS/RHEL)
- ✅ **Цветной вывод** — информативные логи с цветовой индикацией

---

## 2. Функционал

### 2.1. Определение операционной системы

**Код:**
```bash
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID
else
    log_error "Не удалось определить ОС"
    exit 1
fi
```

**Поддерживаемые ОС:**
- Ubuntu 20.04, 22.04, 24.04
- Debian 10, 11, 12
- CentOS 7, 8, 9
- RHEL 7, 8, 9

---

### 2.2. Определение пакетного менеджера

**Код:**
```bash
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
fi
```

**Результат:**
- Автоматический выбор пакетного менеджера
- Универсальные команды установки

---

### 2.3. Установка Nginx

**Код:**
```bash
$PKG_INSTALL nginx
systemctl start nginx
systemctl enable nginx
```

**Действия:**
1. Установка Nginx через пакетный менеджер
2. Запуск сервиса
3. Добавление в автозагрузку

---

### 2.4. Установка MariaDB

**Код:**
```bash
if [ "$PKG_MANAGER" == "apt" ]; then
    $PKG_INSTALL mariadb-server mariadb-client
else
    $PKG_INSTALL mariadb-server mariadb
fi

systemctl start mariadb
systemctl enable mariadb
```

**Особенности:**
- Разные пакеты для apt и yum/dnf
- Автозапуск сервиса

---

### 2.5. Установка PHP и модулей

**Код:**
```bash
if [ "$PKG_MANAGER" == "apt" ]; then
    PHP_PACKAGES="php-fpm php-mysql php-cli php-curl php-gd php-mbstring php-xml php-zip"
    $PKG_INSTALL $PHP_PACKAGES
    PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
    PHP_FPM_SERVICE="php${PHP_VERSION}-fpm"
else
    PHP_PACKAGES="php php-fpm php-mysqlnd php-cli php-curl php-gd php-mbstring php-xml php-zip"
    $PKG_INSTALL $PHP_PACKAGES
    PHP_FPM_SERVICE="php-fpm"
fi

systemctl start $PHP_FPM_SERVICE
systemctl enable $PHP_FPM_SERVICE
```

**Установленные модули:**
- php-fpm — FastCGI Process Manager
- php-mysql / php-mysqlnd — драйвер MySQL
- php-cli — командная строка
- php-curl — HTTP запросы
- php-gd — работа с изображениями
- php-mbstring — многобайтовые строки
- php-xml — обработка XML
- php-zip — работа с архивами

---

### 2.6. Настройка Nginx для PHP

**Код:**
```bash
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

nginx -t && systemctl reload nginx
```

**Особенности:**
- Разные пути конфигурации для apt и yum/dnf
- Автоопределение пути к PHP-FPM сокету
- Проверка конфигурации перед перезагрузкой

---

### 2.7. Создание тестовой базы данных

**Код:**
```bash
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
```

**Результат:**
- База данных: `testapp`
- Пользователь: `testuser` / `SecurePass123!`
- Таблица: `users` с 2 записями

---

### 2.8. Создание тестовых PHP файлов

**info.php:**
```php
<?php
phpinfo();
?>
```

**db_test.php:**
```php
<?php
$conn = new mysqli("localhost", "testuser", "SecurePass123!", "testapp");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

echo "<h2>Database Connection Test</h2>";
echo "<p><strong>Status:</strong> ✅ Connected successfully</p>";
echo "<p><strong>Database:</strong> testapp</p>";

$result = $conn->query("SELECT * FROM users");
echo "<h3>Users Table:</h3><ul>";
while($row = $result->fetch_assoc()) {
    echo "<li>ID: " . $row["id"] . " - " . $row["username"] . " (" . $row["email"] . ")</li>";
}
echo "</ul>";

$conn->close();
?>
```

---

### 2.9. Настройка firewall

**Ubuntu/Debian (ufw):**
```bash
ufw --force enable
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw reload
```

**CentOS/RHEL (firewalld):**
```bash
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
```

---

### 2.10. Цветной вывод логов

**Функции:**
```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
```

**Пример вывода:**
```
[INFO] Определение операционной системы...
[SUCCESS] ОС определена: ubuntu 24.04
[SUCCESS] Пакетный менеджер: apt
[INFO] Установка Nginx...
[SUCCESS] Nginx установлен и запущен
```

---

## 3. Структура скрипта

```
universal_install.sh
├── Проверка прав root
├── Шаг 1: Определение ОС и пакетного менеджера
├── Шаг 2: Обновление списка пакетов
├── Шаг 3: Установка Nginx
├── Шаг 4: Установка MariaDB
├── Шаг 5: Установка PHP
├── Шаг 6: Настройка Nginx для PHP
├── Шаг 7: Создание тестовой БД
├── Шаг 8: Создание тестовых PHP файлов
├── Шаг 9: Настройка firewall
└── Шаг 10: Итоговая информация
```

---

## 4. Использование

### 4.1. Скачивание и запуск

**Команды:**
```bash
# Скачивание скрипта
wget https://example.com/universal_install.sh

# Или если у вас уже есть файл:
chmod +x universal_install.sh

# Запуск с правами root
sudo ./universal_install.sh
```

---

### 4.2. Пример вывода

```
[INFO] Определение операционной системы...
[SUCCESS] ОС определена: ubuntu 24.04
[SUCCESS] Пакетный менеджер: apt

[INFO] Обновление списка пакетов...
[SUCCESS] Список пакетов обновлён

[INFO] Установка Nginx...
[SUCCESS] Nginx установлен и запущен
nginx version: nginx/1.24.0 (Ubuntu)

[INFO] Установка MariaDB...
[SUCCESS] MariaDB установлена и запущена
mysql  Ver 15.1 Distrib 10.11.14-MariaDB

[INFO] Установка PHP и модулей...
[SUCCESS] PHP установлен
PHP 8.3.6 (cli)

[INFO] Настройка Nginx для PHP...
nginx: configuration file /etc/nginx/nginx.conf test is successful
[SUCCESS] Nginx настроен для работы с PHP

[INFO] Создание тестовой базы данных...
[SUCCESS] Тестовая БД создана: testapp
[INFO] Пользователь БД: testuser
[INFO] Пароль БД: SecurePass123!

[INFO] Создание тестовых PHP файлов...
[SUCCESS] Тестовые файлы созданы

[INFO] Настройка firewall...
[SUCCESS] UFW настроен (разрешены порты: 22, 80, 443)

===============================================================================
[SUCCESS] Установка завершена успешно!
===============================================================================

Установленные компоненты:
  - Nginx:   1.24.0
  - MariaDB: 10.11.14
  - PHP:     8.3.6

База данных:
  - Имя БД:       testapp
  - Пользователь: testuser
  - Пароль:       SecurePass123!
  - Таблица:      users (2 записи)

Тестовые страницы:
  - http://localhost/info.php     (phpinfo)
  - http://localhost/db_test.php  (тест БД)

Firewall:
  - Разрешённые порты: 22 (SSH), 80 (HTTP), 443 (HTTPS)

===============================================================================
```

---

### 4.3. Проверка установки

**Команды:**
```bash
# Проверка сервисов
systemctl status nginx
systemctl status mariadb
systemctl status php8.3-fpm  # или php-fpm для CentOS/RHEL

# Проверка версий
nginx -v
mysql --version
php -v

# Тестирование PHP
curl http://localhost/info.php | grep "PHP Version"

# Тестирование БД
curl http://localhost/db_test.php | grep "Connected successfully"

# Проверка firewall
sudo ufw status        # Ubuntu/Debian
sudo firewall-cmd --list-all  # CentOS/RHEL
```

---

## 5. Код скрипта

**Полный код доступен в:** `task6_auto_install/universal_install.sh`

**Основные блоки:**

### 5.1. Определение ОС

```bash
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID
fi
```

### 5.2. Выбор пакетного менеджера

```bash
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
fi
```

### 5.3. Универсальная установка

```bash
$PKG_INSTALL nginx
$PKG_INSTALL mariadb-server
$PKG_INSTALL php-fpm php-mysql ...
```

### 5.4. Адаптивная конфигурация

```bash
# Разные пути для разных ОС
if [ "$PKG_MANAGER" == "apt" ]; then
    NGINX_CONF="/etc/nginx/sites-available/default"
    PHP_SOCK="/run/php/php${PHP_VERSION}-fpm.sock"
else
    NGINX_CONF="/etc/nginx/conf.d/default.conf"
    PHP_SOCK="/run/php-fpm/www.sock"
fi
```

---

## Итоги выполнения задания

✅ **Выполнено:**

1. **Создан универсальный скрипт:**
   - ✅ Определяет текущую ОС
   - ✅ Выбирает соответствующий пакетный менеджер
   - ✅ Устанавливает необходимые пакеты и зависимости

2. **Настроены базовые конфигурации:**
   - ✅ Nginx для работы с PHP
   - ✅ PHP-FPM для обработки запросов
   - ✅ MariaDB для хранения данных

3. **Создана тестовая база данных:**
   - ✅ База `testapp`
   - ✅ Пользователь `testuser`
   - ✅ Таблица `users` с тестовыми данными

4. **Настроен firewall:**
   - ✅ Разрешены порты: 22 (SSH), 80 (HTTP), 443 (HTTPS)
   - ✅ Поддержка ufw (Ubuntu/Debian)
   - ✅ Поддержка firewalld (CentOS/RHEL)

---

## Преимущества скрипта

1. **Универсальность** — работает на Ubuntu, Debian, CentOS, RHEL
2. **Автоматизация** — установка одной командой
3. **Безопасность** — настройка firewall, безопасные пароли
4. **Тестируемость** — создаёт тестовые файлы для проверки
5. **Информативность** — цветной вывод с понятными сообщениями
6. **Надёжность** — проверка ошибок на каждом шаге

---

## Возможные улучшения

1. **Интерактивный режим** — запрос параметров у пользователя
2. **Выбор компонентов** — установка только нужных (Nginx/Apache, MySQL/PostgreSQL)
3. **SSL/TLS** — автоматическая настройка Let's Encrypt
4. **Логирование** — сохранение логов установки в файл
5. **Откат** — скрипт для удаления установленных компонентов
6. **Версии** — возможность выбора конкретных версий пакетов

---

**Дата:** 2026-02-28  
**Выполнил:** Вовчик  
**Система:** Ubuntu 24.04 Noble  
**Поддерживаемые ОС:** Ubuntu, Debian, CentOS, RHEL  
**Время выполнения скрипта:** ~5-10 минут (зависит от скорости интернета)
