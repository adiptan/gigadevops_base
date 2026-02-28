# Задание 3: Развёртывание LEMP стека

**Дата выполнения:** 2026-02-28  
**Система:** Ubuntu 24.04 (Noble)  
**Стек:** LEMP (Linux + Nginx + MariaDB + PHP)

---

## Содержание

1. [Установка LEMP стека](#1-установка-lemp-стека)
2. [Настройка phpMyAdmin](#2-настройка-phpmyadmin)
3. [Запуск демо-проекта](#3-запуск-демо-проекта)
4. [Пошаговая инструкция](#4-пошаговая-инструкция-по-установке)

---

## 1. Установка LEMP стека

### 1.1. Обновление системы

**Команда:**
```bash
sudo apt update
```

**Вывод:**
```
Hit:1 http://ru.archive.ubuntu.com/ubuntu noble InRelease
Get:2 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
...
Reading package lists... Done
Building dependency tree... Done
```

---

### 1.2. Установка Nginx

**Команда:**
```bash
sudo apt install -y nginx
```

**Проверка установки:**
```bash
nginx -v
systemctl status nginx
```

**Вывод:**
```
nginx version: nginx/1.24.0 (Ubuntu)

● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled)
     Active: active (running) since Sat 2026-02-28 13:28:45 MSK
       Docs: man:nginx(8)
   Main PID: 503669 (nginx)
      Tasks: 9 (limit: 62271)
     Memory: 9.2M
        CPU: 45ms
```

**Проверка работы:**
```bash
curl -I http://localhost
```

**Результат:**
```
HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)
```

---

### 1.3. Установка MariaDB

**Команда:**
```bash
sudo apt install -y mariadb-server mariadb-client
```

**Версия:**
```bash
mysql --version
```

**Вывод:**
```
mysql  Ver 15.1 Distrib 10.11.14-MariaDB, for debian-linux-gnu (x86_64) using EditLine wrapper
```

**Проверка статуса:**
```bash
systemctl status mariadb
```

**Вывод:**
```
● mariadb.service - MariaDB 10.11.14 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled)
     Active: active (running) since Sat 2026-02-28 13:29:17 MSK
   Main PID: 505121 (mariadbd)
     Status: "Taking your SQL requests now..."
      Tasks: 14
     Memory: 78.9M
```

---

### 1.4. Настройка MariaDB

**Создание тестовой базы данных:**
```bash
sudo mysql -e "CREATE DATABASE IF NOT EXISTS testdb;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'testuser'@'localhost' IDENTIFIED BY 'testpass123';"
sudo mysql -e "GRANT ALL PRIVILEGES ON testdb.* TO 'testuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
```

**Проверка:**
```bash
sudo mysql -e "SHOW DATABASES;"
```

**Вывод:**
```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| testdb             |
+--------------------+
```

**Проверка подключения:**
```bash
mysql -u testuser -p'testpass123' -e "SELECT DATABASE();"
```

---

### 1.5. Установка PHP 8.3 и модулей

**Команда:**
```bash
sudo apt install -y php-fpm php-mysql php-cli php-curl php-gd \
                     php-mbstring php-xml php-zip php-json
```

**Установленные пакеты:**
- `php8.3-fpm` — FastCGI Process Manager для PHP
- `php8.3-mysql` — модуль для работы с MySQL/MariaDB
- `php8.3-cli` — интерфейс командной строки PHP
- `php8.3-curl` — модуль для HTTP запросов
- `php8.3-gd` — библиотека для работы с изображениями
- `php8.3-mbstring` — многобайтовые строки (UTF-8)
- `php8.3-xml` — обработка XML
- `php8.3-zip` — работа с ZIP архивами

**Версия PHP:**
```bash
php -v
```

**Вывод:**
```
PHP 8.3.6 (cli) (built: Jan  7 2026 08:40:32) (NTS)
Copyright (c) The PHP Group
Zend Engine v4.3.6, Copyright (c) Zend Technologies
    with Zend OPcache v8.3.6, Copyright (c), by Zend Technologies
```

**Статус PHP-FPM:**
```bash
systemctl status php8.3-fpm
```

**Вывод:**
```
● php8.3-fpm.service - The PHP 8.3 FastCGI Process Manager
     Loaded: loaded (/usr/lib/systemd/system/php8.3-fpm.service; enabled)
     Active: active (running) since Sat 2026-02-28 13:29:35 MSK
   Main PID: 516113 (php-fpm8.3)
     Status: "Ready to handle connections"
      Tasks: 3
     Memory: 10.3M
```

---

### 1.6. Настройка Nginx для работы с PHP

**Создание конфигурации:**
```bash
sudo nano /etc/nginx/sites-available/test
```

**Содержимое файла:**
```nginx
server {
    listen 80;
    listen [::]:80;
    
    root /var/www/html/test;
    index index.php index.html index.htm;
    
    server_name localhost;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Обработка PHP файлов
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    }
    
    # Запрет доступа к .htaccess
    location ~ /\.ht {
        deny all;
    }
}
```

**Активация конфигурации:**
```bash
sudo ln -s /etc/nginx/sites-available/test /etc/nginx/sites-enabled/test
sudo rm /etc/nginx/sites-enabled/default
```

**Проверка конфигурации:**
```bash
sudo nginx -t
```

**Вывод:**
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

**Перезагрузка Nginx:**
```bash
sudo systemctl reload nginx
```

---

### 1.7. Создание тестового PHP файла

**Создание директории:**
```bash
sudo mkdir -p /var/www/html/test
```

**Файл info.php:**
```bash
sudo nano /var/www/html/test/info.php
```

**Содержимое:**
```php
<?php
phpinfo();
?>
```

**Файл db_test.php (тест подключения к БД):**
```bash
sudo nano /var/www/html/test/db_test.php
```

**Содержимое:**
```php
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
```

**Установка прав:**
```bash
sudo chown -R www-data:www-data /var/www/html/test
```

**Проверка работы:**
```bash
curl http://localhost/info.php | grep "PHP Version"
curl http://localhost/db_test.php
```

**Результат:**
```
<h1 class="p">PHP Version 8.3.6</h1>
Connected successfully to database: testdb
```

---

### 1.8. Проверка установленных сервисов

**Команда:**
```bash
systemctl is-active nginx mariadb php8.3-fpm
```

**Вывод:**
```
active
active
active
```

✅ **LEMP стек успешно установлен!**

---

## 2. Настройка phpMyAdmin

### 2.1. Установка зависимостей

**Команда:**
```bash
sudo apt install -y wget unzip php-mbstring php-zip php-gd php-json php-curl
```

Эти пакеты уже были установлены на предыдущем шаге.

---

### 2.2. Скачивание phpMyAdmin

**Команда:**
```bash
cd /tmp
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O phpmyadmin.zip
```

**Вывод:**
```
--2026-02-28 13:30:04--  https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip
...
Location: https://files.phpmyadmin.net/phpMyAdmin/5.2.3/phpMyAdmin-5.2.3-all-languages.zip
...
2026-02-28 13:30:07 (9.36 MB/s) - 'phpmyadmin.zip' saved [16431330/16431330]
```

**Версия:** phpMyAdmin 5.2.3

---

### 2.3. Распаковка и установка

**Команды:**
```bash
unzip -q phpmyadmin.zip
sudo mv phpMyAdmin-5.2.3-all-languages /var/www/html/phpmyadmin
cd /var/www/html/phpmyadmin
```

**Создание конфигурации:**
```bash
sudo cp config.sample.inc.php config.inc.php
```

**Генерация секретного ключа:**
```bash
BLOWFISH_SECRET=$(openssl rand -base64 32)
echo "\$cfg['blowfish_secret'] = '$BLOWFISH_SECRET';" | sudo tee -a config.inc.php
```

**Создание директории для временных файлов:**
```bash
sudo mkdir -p tmp
sudo chown -R www-data:www-data /var/www/html/phpmyadmin
sudo chmod 755 tmp
```

---

### 2.4. Настройка Nginx для phpMyAdmin

**Создание конфигурации:**
```bash
sudo nano /etc/nginx/sites-available/phpmyadmin
```

**Содержимое:**
```nginx
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
    
    # Защита служебных директорий
    location ~ /(libraries|setup/frames|setup/libs) {
        deny all;
        return 404;
    }
}
```

**Активация:**
```bash
sudo ln -s /etc/nginx/sites-available/phpmyadmin /etc/nginx/sites-enabled/phpmyadmin
sudo nginx -t
sudo systemctl reload nginx
```

---

### 2.5. Доступ к phpMyAdmin

**URL:** http://localhost:8080

**Данные для входа:**
- **Пользователь:** testuser
- **Пароль:** testpass123
- **База данных:** testdb

✅ **phpMyAdmin успешно установлен и настроен!**

---

## 3. Запуск демо-проекта

### 3.1. Описание проекта

Простое TODO приложение на PHP с использованием MariaDB для хранения данных.

**Функционал:**
- Добавление задач
- Удаление задач
- Отображение информации о стеке (PHP версия, сервер, БД)

---

### 3.2. Создание приложения

**Создание директории:**
```bash
sudo mkdir -p /var/www/html/demo
cd /var/www/html/demo
```

**Создание файла index.php:**

<details>
<summary>Код приложения (index.php)</summary>

```php
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LEMP Demo - Список задач</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f4f4f4;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .form-group {
            margin-bottom: 15px;
        }
        input[type="text"] {
            width: 70%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        button {
            padding: 10px 20px;
            background: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        button:hover {
            background: #45a049;
        }
        .task-list {
            margin-top: 20px;
        }
        .task-item {
            background: #f9f9f9;
            padding: 10px;
            margin: 5px 0;
            border-radius: 5px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .delete-btn {
            background: #f44336;
            padding: 5px 10px;
            font-size: 12px;
        }
        .delete-btn:hover {
            background: #da190b;
        }
        .info {
            background: #e7f3ff;
            padding: 15px;
            border-left: 4px solid #2196F3;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .info strong {
            color: #2196F3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📝 LEMP Stack Demo</h1>
        
        <div class="info">
            <strong>Стек:</strong> Linux + Nginx + MariaDB + PHP<br>
            <strong>База данных:</strong> testdb<br>
            <strong>Версия PHP:</strong> <?php echo phpversion(); ?><br>
            <strong>Сервер:</strong> <?php echo $_SERVER['SERVER_SOFTWARE']; ?>
        </div>

        <h2>Добавить задачу</h2>
        <form method="POST" action="">
            <div class="form-group">
                <input type="text" name="task" placeholder="Введите задачу..." required>
                <button type="submit" name="add">Добавить</button>
            </div>
        </form>

        <h2>Список задач</h2>
        <div class="task-list">
            <?php
            // Подключение к БД
            $conn = new mysqli("localhost", "testuser", "testpass123", "testdb");
            
            if ($conn->connect_error) {
                die("Ошибка подключения: " . $conn->connect_error);
            }
            
            // Создание таблицы, если не существует
            $conn->query("CREATE TABLE IF NOT EXISTS tasks (
                id INT AUTO_INCREMENT PRIMARY KEY,
                task TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )");
            
            // Добавление задачи
            if (isset($_POST['add'])) {
                $task = $conn->real_escape_string($_POST['task']);
                $conn->query("INSERT INTO tasks (task) VALUES ('$task')");
                header("Location: " . $_SERVER['PHP_SELF']);
                exit;
            }
            
            // Удаление задачи
            if (isset($_GET['delete'])) {
                $id = intval($_GET['delete']);
                $conn->query("DELETE FROM tasks WHERE id = $id");
                header("Location: " . $_SERVER['PHP_SELF']);
                exit;
            }
            
            // Получение всех задач
            $result = $conn->query("SELECT * FROM tasks ORDER BY created_at DESC");
            
            if ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
                    echo '<div class="task-item">';
                    echo '<span>' . htmlspecialchars($row['task']) . '</span>';
                    echo '<button class="delete-btn" onclick="location.href=\'?delete=' . $row['id'] . '\'">Удалить</button>';
                    echo '</div>';
                }
            } else {
                echo '<p style="text-align: center; color: #999;">Задач пока нет. Добавьте первую!</p>';
            }
            
            $conn->close();
            ?>
        </div>
    </div>
</body>
</html>
```

</details>

**Установка прав:**
```bash
sudo chown -R www-data:www-data /var/www/html/demo
```

---

### 3.3. Настройка Nginx для демо-приложения

**Создание конфигурации:**
```bash
sudo nano /etc/nginx/sites-available/demo
```

**Содержимое:**
```nginx
server {
    listen 9090;
    listen [::]:9090;
    
    root /var/www/html/demo;
    index index.php index.html;
    
    server_name localhost;
    
    access_log /var/log/nginx/demo_access.log;
    error_log /var/log/nginx/demo_error.log;
    
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
```

**Активация:**
```bash
sudo ln -s /etc/nginx/sites-available/demo /etc/nginx/sites-enabled/demo
sudo nginx -t
sudo systemctl reload nginx
```

---

### 3.4. Доступ к демо-приложению

**URL:** http://localhost:9090

**Возможности:**
- Добавление задач через форму
- Удаление задач
- Автоматическое создание таблицы в БД
- Отображение информации о стеке

✅ **Демо-приложение успешно запущено!**

---

## 4. Пошаговая инструкция по установке

### Шаг 1: Подготовка системы

```bash
# Обновление списка пакетов
sudo apt update

# Установка базовых утилит (если нужно)
sudo apt install -y curl wget git
```

---

### Шаг 2: Установка Nginx

```bash
# Установка Nginx
sudo apt install -y nginx

# Проверка статуса
systemctl status nginx

# Проверка версии
nginx -v
```

**Результат:** Nginx установлен и запущен на порту 80.

---

### Шаг 3: Установка MariaDB

```bash
# Установка MariaDB
sudo apt install -y mariadb-server mariadb-client

# Проверка версии
mysql --version

# Проверка статуса
systemctl status mariadb
```

---

### Шаг 4: Настройка MariaDB

```bash
# Создание базы данных
sudo mysql -e "CREATE DATABASE testdb;"

# Создание пользователя
sudo mysql -e "CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'testpass123';"

# Предоставление прав
sudo mysql -e "GRANT ALL PRIVILEGES ON testdb.* TO 'testuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Проверка
sudo mysql -e "SHOW DATABASES;"
```

**Опционально (для продакшн):**
```bash
sudo mysql_secure_installation
```

---

### Шаг 5: Установка PHP

```bash
# Установка PHP 8.3 и необходимых модулей
sudo apt install -y php-fpm php-mysql php-cli php-curl \
                     php-gd php-mbstring php-xml php-zip php-json

# Проверка версии
php -v

# Проверка статуса PHP-FPM
systemctl status php8.3-fpm
```

---

### Шаг 6: Настройка Nginx для PHP

**Создание конфигурации:**
```bash
sudo nano /etc/nginx/sites-available/default
```

**Минимальная конфигурация:**
```nginx
server {
    listen 80;
    root /var/www/html;
    index index.php index.html;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    }
}
```

**Перезагрузка:**
```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

### Шаг 7: Тестирование PHP

```bash
# Создание тестового файла
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

# Проверка через curl
curl http://localhost/info.php | grep "PHP Version"

# Или открыть в браузере
# http://localhost/info.php
```

**После проверки удалить:**
```bash
sudo rm /var/www/html/info.php
```

---

### Шаг 8: Установка phpMyAdmin

```bash
# Скачивание
cd /tmp
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O phpmyadmin.zip

# Распаковка
unzip -q phpmyadmin.zip
sudo mv phpMyAdmin-* /var/www/html/phpmyadmin

# Настройка
cd /var/www/html/phpmyadmin
sudo cp config.sample.inc.php config.inc.php

# Генерация секретного ключа
BLOWFISH=$(openssl rand -base64 32)
echo "\$cfg['blowfish_secret'] = '$BLOWFISH';" | sudo tee -a config.inc.php

# Права
sudo mkdir tmp
sudo chown -R www-data:www-data /var/www/html/phpmyadmin
sudo chmod 755 tmp
```

**Настройка Nginx для phpMyAdmin:**
```bash
sudo nano /etc/nginx/sites-available/phpmyadmin
```

```nginx
server {
    listen 8080;
    root /var/www/html/phpmyadmin;
    index index.php;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/phpmyadmin /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

**Доступ:** http://localhost:8080

---

### Шаг 9: Развёртывание приложения

```bash
# Создание директории проекта
sudo mkdir -p /var/www/html/myapp

# Копирование файлов проекта
# (git clone, rsync, или копирование вручную)

# Настройка прав
sudo chown -R www-data:www-data /var/www/html/myapp

# Создание конфигурации Nginx для приложения
# (аналогично phpMyAdmin, с нужным портом)

# Перезагрузка Nginx
sudo systemctl reload nginx
```

---

## Итоги выполнения задания

✅ **Выполнено:**

1. **Установлен LEMP стек:**
   - ✅ Linux: Ubuntu 24.04
   - ✅ Nginx: 1.24.0
   - ✅ MariaDB: 10.11.14
   - ✅ PHP: 8.3.6 + FPM

2. **Настроен phpMyAdmin:**
   - ✅ Версия 5.2.3
   - ✅ Работает на порту 8080
   - ✅ Доступ через testuser/testpass123

3. **Запущен демо-проект:**
   - ✅ TODO приложение на PHP
   - ✅ Работа с БД MariaDB
   - ✅ Работает на порту 9090
   - ✅ Полнофункциональное CRUD приложение

4. **Написана пошаговая инструкция:**
   - ✅ 9 шагов от начала до конца
   - ✅ Все команды с выводом
   - ✅ Готово к воспроизведению

---

## Структура сервисов

| Сервис | Порт | URL | Описание |
|--------|------|-----|----------|
| Nginx (test) | 80 | http://localhost | Тестовые PHP файлы |
| phpMyAdmin | 8080 | http://localhost:8080 | Веб-интерфейс для БД |
| Demo App | 9090 | http://localhost:9090 | TODO приложение |

---

## Полезные команды

### Управление сервисами

```bash
# Перезапуск Nginx
sudo systemctl restart nginx

# Перезапуск MariaDB
sudo systemctl restart mariadb

# Перезапуск PHP-FPM
sudo systemctl restart php8.3-fpm

# Проверка логов Nginx
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# Проверка логов PHP
sudo tail -f /var/log/php8.3-fpm.log
```

### Работа с БД

```bash
# Вход в MySQL как root
sudo mysql

# Вход под пользователем
mysql -u testuser -p

# Просмотр баз данных
mysql -u testuser -p -e "SHOW DATABASES;"

# Просмотр таблиц
mysql -u testuser -p testdb -e "SHOW TABLES;"
```

### Проверка конфигурации Nginx

```bash
# Проверка синтаксиса
sudo nginx -t

# Просмотр активных сайтов
ls -la /etc/nginx/sites-enabled/

# Просмотр конфигурации
cat /etc/nginx/sites-available/default
```

---

**Дата:** 2026-02-28  
**Выполнил:** Вовчик  
**Система:** Ubuntu 24.04 Noble  
**Время выполнения:** ~15 минут
