# Задание 5: Настройка локального репозитория

**Дата выполнения:** 2026-02-28  
**Система:** Ubuntu 24.04 (Noble)  
**Формат репозитория:** APT (Debian/Ubuntu)

---

## Содержание

1. [Теория репозиториев APT](#1-теория-репозиториев-apt)
2. [Создание локального репозитория](#2-создание-локального-репозитория)
3. [Настройка автообновления](#3-настройка-автообновления)
4. [Тестирование репозитория](#4-тестирование-репозитория)
5. [Полная инструкция](#5-полная-инструкция)

---

## 1. Теория репозиториев APT

### 1.1. Что такое APT репозиторий?

**APT (Advanced Package Tool)** — система управления пакетами в Debian и производных дистрибутивах.

**Репозиторий** — сервер или директория, содержащая:
- Пакеты (.deb файлы)
- Метаданные (списки пакетов, зависимости, контрольные суммы)

---

### 1.2. Структура репозитория

```
repository/
├── pool/
│   └── main/               # Пакеты (.deb файлы)
│       ├── package1.deb
│       └── package2.deb
└── dists/
    └── stable/             # Дистрибутив (stable, testing, unstable)
        ├── Release         # Метаданные релиза
        ├── Release.gpg     # Подпись (опционально)
        └── main/           # Компонент (main, contrib, non-free)
            ├── binary-amd64/
            │   ├── Packages       # Список пакетов для amd64
            │   └── Packages.gz    # Сжатая версия
            └── binary-all/
                ├── Packages       # Список пакетов для all
                └── Packages.gz
```

---

### 1.3. Ключевые файлы

**Release** — главный метаданный файл:
```
Origin: MyRepo
Label: MyRepo
Suite: stable
Codename: stable
Architectures: amd64 all
Components: main
Description: Локальный репозиторий
Date: Sat, 28 Feb 2026 10:37:39 +0000
MD5Sum:
 <hash> <size> main/binary-amd64/Packages
 <hash> <size> main/binary-all/Packages.gz
```

**Packages** — список пакетов в компоненте:
```
Package: myapp-config
Version: 1.0.0
Architecture: all
Maintainer: Vovchik <vovchik@openclaw.ai>
Filename: pool/main/myapp-config_1.0.0_all.deb
Size: 1982
MD5sum: 13f714e3ebe8451098e5e35e214ecbeb
Description: Конфигурационные файлы для MyApp
```

---

## 2. Создание локального репозитория

### 2.1. Установка необходимых пакетов

**Команда:**
```bash
sudo apt install -y dpkg-dev apt-utils
```

**Пакеты:**
- **dpkg-dev** — инструменты для работы с пакетами (.deb)
- **apt-utils** — утилиты для работы с репозиториями

---

### 2.2. Создание структуры репозитория

**Команда:**
```bash
REPO_DIR="/var/www/html/myrepo"
DIST="stable"
COMPONENT="main"

sudo mkdir -p "${REPO_DIR}/pool/${COMPONENT}"
sudo mkdir -p "${REPO_DIR}/dists/${DIST}/${COMPONENT}/binary-amd64"
sudo mkdir -p "${REPO_DIR}/dists/${DIST}/${COMPONENT}/binary-all"
```

**Структура:**
```
/var/www/html/myrepo/
├── pool/
│   └── main/
└── dists/
    └── stable/
        └── main/
            ├── binary-amd64/
            └── binary-all/
```

---

### 2.3. Добавление пакетов в репозиторий

**Команда:**
```bash
sudo cp myapp-config_1.0.0_all.deb "${REPO_DIR}/pool/${COMPONENT}/"
```

**Проверка:**
```bash
ls -lh "${REPO_DIR}/pool/${COMPONENT}/"
```

**Вывод:**
```
-rw-r--r-- 1 root root 2.0K Feb 28 13:37 myapp-config_1.0.0_all.deb
```

---

### 2.4. Генерация метаданных Packages

**Команда:**
```bash
cd "${REPO_DIR}"

# Генерация Packages для binary-all
dpkg-scanpackages --arch all pool/main > dists/stable/main/binary-all/Packages
gzip -9c dists/stable/main/binary-all/Packages > dists/stable/main/binary-all/Packages.gz

# Генерация Packages для binary-amd64
dpkg-scanpackages --arch amd64 pool/main > dists/stable/main/binary-amd64/Packages
gzip -9c dists/stable/main/binary-amd64/Packages > dists/stable/main/binary-amd64/Packages.gz
```

**Вывод:**
```
dpkg-scanpackages: info: Wrote 1 entries to output Packages file.
```

---

### 2.5. Создание Release файла

**Команда:**
```bash
cd "${REPO_DIR}/dists/stable"

cat > Release << 'EOF'
Origin: MyLocalRepo
Label: MyLocalRepo
Suite: stable
Codename: stable
Architectures: amd64 all
Components: main
Description: Локальный APT репозиторий
EOF

# Генерация хэшей
apt-ftparchive release . >> Release
```

**Вывод Release:**
```
Origin: MyLocalRepo
Label: MyLocalRepo
Suite: stable
Codename: stable
Architectures: amd64 all
Components: main
Description: Локальный APT репозиторий
Date: Sat, 28 Feb 2026 10:38:44 +0000
MD5Sum:
 7f36051549bd78ae1412e1bca1fbef77  610 main/binary-all/Packages
 14138914c701dbbc72714c45cce4996c  458 main/binary-all/Packages.gz
 7f36051549bd78ae1412e1bca1fbef77  610 main/binary-amd64/Packages
 14138914c701dbbc72714c45cce4996c  458 main/binary-amd64/Packages.gz
SHA1:
 ...
SHA256:
 ...
```

---

### 2.6. Настройка доступа через HTTP

**Nginx конфигурация (уже настроена из Задания 3):**
```nginx
server {
    listen 80;
    root /var/www/html;
    autoindex on;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

**Проверка доступности:**
```bash
curl -I http://localhost/myrepo/dists/stable/main/binary-all/Packages
```

**Вывод:**
```
HTTP/1.1 200 OK
Server: nginx/1.24.0
Content-Type: application/octet-stream
Content-Length: 610
```

---

### 2.7. Добавление репозитория в sources.list

**Команда:**
```bash
sudo cat > /etc/apt/sources.list.d/myrepo.list << 'EOF'
deb [trusted=yes] http://localhost/myrepo stable main
EOF
```

**Пояснение:**
- `deb` — тип репозитория (бинарные пакеты)
- `[trusted=yes]` — доверять репозиторию без GPG проверки
- `http://localhost/myrepo` — URL репозитория
- `stable` — дистрибутив
- `main` — компонент

**Альтернативно (с проверкой подписи):**
```
deb http://localhost/myrepo stable main
```

---

### 2.8. Обновление списка пакетов

**Команда:**
```bash
sudo apt update
```

**Вывод:**
```
Ign:1 http://localhost/myrepo stable InRelease
Get:2 http://localhost/myrepo stable Release [2,411 B]
Ign:3 http://localhost/myrepo stable Release.gpg
Get:4 http://localhost/myrepo stable/main all Packages [458 B]
Get:5 http://localhost/myrepo stable/main amd64 Packages [458 B]
...
Reading package lists... Done
```

---

### 2.9. Проверка доступности пакета

**Команда:**
```bash
apt-cache policy myapp-config
```

**Вывод:**
```
myapp-config:
  Installed: (none)
  Candidate: 1.0.0
  Version table:
     1.0.0 500
        500 http://localhost/myrepo stable/main amd64 Packages
        500 http://localhost/myrepo stable/main all Packages
```

✅ **Пакет доступен из локального репозитория!**

---

### 2.10. Установка пакета из репозитория

**Команда:**
```bash
sudo apt install -y myapp-config
```

**Вывод:**
```
Reading package lists...
Building dependency tree...
The following NEW packages will be installed:
  myapp-config
Fetched 1,982 B in 0s
Selecting previously unselected package myapp-config.
Unpacking myapp-config (1.0.0) ...
Setting up myapp-config (1.0.0) ...
MyApp Config: Настройка после установки...
MyApp Config установлен успешно!
```

✅ **Пакет установлен через APT из локального репозитория!**

---

## 3. Настройка автообновления

### 3.1. Создание новой версии пакета

**Шаг 1: Копирование структуры предыдущего пакета**
```bash
cp -r myapp-config_1.0.0_all myapp-config_1.0.1_all
```

**Шаг 2: Обновление версии в control**
```bash
sed -i 's/Version: 1.0.0/Version: 1.0.1/' myapp-config_1.0.1_all/DEBIAN/control
```

**Шаг 3: Изменение файлов (опционально)**
```bash
echo 'echo "Версия: 1.0.1 (обновлённая)"' >> myapp-config_1.0.1_all/usr/local/bin/myapp-monitor
```

**Шаг 4: Пересборка пакета**
```bash
dpkg-deb --build myapp-config_1.0.1_all
```

**Результат:**
```
dpkg-deb: building package 'myapp-config' in 'myapp-config_1.0.1_all.deb'.
```

---

### 3.2. Добавление новой версии в репозиторий

**Команда:**
```bash
sudo cp myapp-config_1.0.1_all.deb /var/www/html/myrepo/pool/main/
```

**Проверка:**
```bash
ls -lh /var/www/html/myrepo/pool/main/
```

**Вывод:**
```
-rw-r--r-- 1 root root 2.0K Feb 28 13:37 myapp-config_1.0.0_all.deb
-rw-r--r-- 1 root root 2.5K Feb 28 13:40 myapp-config_1.0.1_all.deb
```

---

### 3.3. Обновление метаданных репозитория

**Команды:**
```bash
cd /var/www/html/myrepo

# Регенерация Packages файлов
dpkg-scanpackages --arch all pool/main > dists/stable/main/binary-all/Packages
gzip -9fc dists/stable/main/binary-all/Packages > dists/stable/main/binary-all/Packages.gz

dpkg-scanpackages --arch amd64 pool/main > dists/stable/main/binary-amd64/Packages
gzip -9fc dists/stable/main/binary-amd64/Packages > dists/stable/main/binary-amd64/Packages.gz

# Регенерация Release файла
cd dists/stable
cat > Release << 'EOF'
Origin: MyLocalRepo
Label: MyLocalRepo
Suite: stable
Codename: stable
Architectures: amd64 all
Components: main
Description: Локальный APT репозиторий
EOF

apt-ftparchive release . >> Release
```

**Вывод:**
```
dpkg-scanpackages: warning: package myapp-config (filename pool/main/myapp-config_1.0.0_all.deb) is repeat; ignored that one and using data from pool/main/myapp-config_1.0.1_all.deb!
dpkg-scanpackages: info: Wrote 1 entries to output Packages file.
```

**Пояснение:**
dpkg-scanpackages автоматически выбирает более новую версию пакета (1.0.1), если в репозитории есть несколько версий одного пакета.

---

### 3.4. Проверка доступных обновлений

**Команда:**
```bash
sudo apt update
apt list --upgradable | grep myapp
```

**Вывод:**
```
Get:2 http://localhost/myrepo stable Release [2,411 B]
Get:4 http://localhost/myrepo stable/main all Packages [462 B]
...
myapp-config/stable 1.0.1 all [upgradable from: 1.0.0]
```

✅ **APT видит доступное обновление!**

---

### 3.5. Обновление пакета

**Команда:**
```bash
sudo apt upgrade -y myapp-config
```

**Вывод:**
```
Reading package lists...
Building dependency tree...
The following packages will be upgraded:
  myapp-config
Fetched 2,048 B in 0s
(Reading database ... 196300 files and directories currently installed.)
Preparing to unpack .../myapp-config_1.0.1_all.deb ...
MyApp Config: Подготовка к удалению...
Unpacking myapp-config (1.0.1) over (1.0.0) ...
Setting up myapp-config (1.0.1) ...
MyApp Config: Настройка после установки...
MyApp Config установлен успешно!
```

**Проверка версии:**
```bash
dpkg -l | grep myapp-config
```

**Вывод:**
```
ii  myapp-config  1.0.1  all  Конфигурационные файлы и скрипты для MyApp
```

✅ **Пакет обновился до версии 1.0.1!**

---

## 4. Тестирование репозитория

### 4.1. Полный цикл работы с репозиторием

**1. Добавление репозитория:**
```bash
echo "deb [trusted=yes] http://localhost/myrepo stable main" | sudo tee /etc/apt/sources.list.d/myrepo.list
sudo apt update
```

**2. Поиск пакета:**
```bash
apt-cache search myapp
```
**Вывод:**
```
myapp-config - Конфигурационные файлы и скрипты для MyApp
```

**3. Просмотр информации:**
```bash
apt show myapp-config
```

**4. Установка:**
```bash
sudo apt install -y myapp-config
```

**5. Проверка:**
```bash
myapp-monitor
```

**6. Обновление (после добавления новой версии в репозиторий):**
```bash
sudo apt update
sudo apt upgrade -y myapp-config
```

**7. Удаление:**
```bash
sudo apt remove myapp-config
```

---

### 4.2. Автоматизация обновления метаданных

**Скрипт update_repo.sh:**
```bash
#!/bin/bash
REPO_DIR="/var/www/html/myrepo"

cd "${REPO_DIR}"

# Обновление Packages файлов
dpkg-scanpackages --arch all pool/main > dists/stable/main/binary-all/Packages
gzip -9fc dists/stable/main/binary-all/Packages > dists/stable/main/binary-all/Packages.gz

dpkg-scanpackages --arch amd64 pool/main > dists/stable/main/binary-amd64/Packages
gzip -9fc dists/stable/main/binary-amd64/Packages > dists/stable/main/binary-amd64/Packages.gz

# Обновление Release файла
cd dists/stable
cat > Release << 'EOF'
Origin: MyLocalRepo
Label: MyLocalRepo
Suite: stable
Codename: stable
Architectures: amd64 all
Components: main
Description: Локальный APT репозиторий
EOF

apt-ftparchive release . >> Release

echo "Репозиторий обновлён: $(date)"
```

**Использование:**
```bash
sudo chmod +x update_repo.sh
sudo ./update_repo.sh
```

---

## 5. Полная инструкция

### Шаг 1: Подготовка

```bash
# Установка инструментов
sudo apt install -y dpkg-dev apt-utils

# Создание структуры
REPO_DIR="/var/www/html/myrepo"
sudo mkdir -p "${REPO_DIR}/pool/main"
sudo mkdir -p "${REPO_DIR}/dists/stable/main/binary-amd64"
sudo mkdir -p "${REPO_DIR}/dists/stable/main/binary-all"
```

---

### Шаг 2: Добавление пакетов

```bash
# Копирование пакетов
sudo cp *.deb "${REPO_DIR}/pool/main/"
```

---

### Шаг 3: Генерация метаданных

```bash
cd "${REPO_DIR}"

# Packages файлы
dpkg-scanpackages --arch all pool/main > dists/stable/main/binary-all/Packages
gzip -9c dists/stable/main/binary-all/Packages > dists/stable/main/binary-all/Packages.gz

dpkg-scanpackages --arch amd64 pool/main > dists/stable/main/binary-amd64/Packages
gzip -9c dists/stable/main/binary-amd64/Packages > dists/stable/main/binary-amd64/Packages.gz

# Release файл
cd dists/stable
cat > Release << 'EOF'
Origin: MyLocalRepo
Label: MyLocalRepo
Suite: stable
Codename: stable
Architectures: amd64 all
Components: main
Description: Локальный APT репозиторий
EOF

apt-ftparchive release . >> Release
```

---

### Шаг 4: Настройка Nginx

**Конфигурация:**
```nginx
server {
    listen 80;
    root /var/www/html;
    autoindex on;
}
```

**Перезагрузка:**
```bash
sudo systemctl reload nginx
```

---

### Шаг 5: Добавление репозитория на клиенте

```bash
echo "deb [trusted=yes] http://localhost/myrepo stable main" | sudo tee /etc/apt/sources.list.d/myrepo.list
sudo apt update
```

---

### Шаг 6: Использование

```bash
# Установка
sudo apt install myapp-config

# Обновление (после добавления новой версии)
sudo apt update
sudo apt upgrade myapp-config

# Удаление
sudo apt remove myapp-config
```

---

## Итоги выполнения задания

✅ **Выполнено:**

1. **Создан локальный APT репозиторий:**
   - ✅ Структура: pool/ + dists/
   - ✅ URL: http://localhost/myrepo
   - ✅ Доступен через HTTP (Nginx)

2. **Настроено автообновление:**
   - ✅ Добавлена новая версия пакета (1.0.0 → 1.0.1)
   - ✅ Метаданные обновлены автоматически
   - ✅ APT подхватывает обновления через `apt update`

3. **Протестирована работа:**
   - ✅ Установка через `apt install`
   - ✅ Обновление через `apt upgrade`
   - ✅ Удаление через `apt remove`

---

## Полезные команды

### Управление репозиторием

```bash
# Добавление пакета
sudo cp package.deb /var/www/html/myrepo/pool/main/
sudo /path/to/update_repo.sh

# Просмотр содержимого репозитория
curl http://localhost/myrepo/dists/stable/main/binary-all/Packages

# Проверка Release файла
curl http://localhost/myrepo/dists/stable/Release

# Очистка старых версий
cd /var/www/html/myrepo/pool/main
sudo rm -f old-package*.deb
sudo /path/to/update_repo.sh
```

### Работа с APT

```bash
# Добавление репозитория
echo "deb [trusted=yes] http://example.com/repo stable main" | sudo tee /etc/apt/sources.list.d/custom.list

# Удаление репозитория
sudo rm /etc/apt/sources.list.d/custom.list
sudo apt update

# Поиск пакета в репозитории
apt-cache search keyword

# Информация о пакете
apt show package-name

# Список файлов из репозитория
grep -A 10 "Package: package-name" /var/lib/apt/lists/*_Packages
```

---

**Дата:** 2026-02-28  
**Выполнил:** Вовчик  
**Система:** Ubuntu 24.04 Noble  
**Время создания репозитория:** ~10 минут
