# Задание 4: Создание пакета

**Дата выполнения:** 2026-02-28  
**Система:** Ubuntu 24.04 (Noble)  
**Формат пакета:** .deb (Debian/Ubuntu)

---

## Содержание

1. [Теория упаковки пакетов](#1-теория-упаковки-пакетов)
2. [Создание структуры пакета](#2-создание-структуры-пакета)
3. [Сборка пакета](#3-сборка-пакета)
4. [Тестирование пакета](#4-тестирование-пакета)
5. [Полная инструкция](#5-полная-инструкция-по-созданию-deb-пакета)

---

## 1. Теория упаковки пакетов

### 1.1. Что такое .deb пакет?

**.deb** — формат пакетов для систем на базе Debian (Ubuntu, Linux Mint, Debian и др.).

**Структура .deb пакета:**
- **Метаданные** (control файл) — информация о пакете
- **Файлы** — программы, конфигурации, документация
- **Скрипты** — pre/postinst, pre/postrm (выполняются при установке/удалении)

---

### 1.2. Минимальная структура пакета

```
package-name_version_architecture/
├── DEBIAN/
│   ├── control           # Обязательный файл с метаданными
│   ├── postinst          # Скрипт после установки (опционально)
│   ├── prerm             # Скрипт перед удалением (опционально)
│   ├── postrm            # Скрипт после удаления (опционально)
│   └── preinst           # Скрипт перед установкой (опционально)
├── usr/
│   ├── local/bin/        # Исполняемые файлы
│   └── share/doc/        # Документация
└── etc/                  # Конфигурационные файлы
```

---

### 1.3. Control файл

Обязательные поля:
- **Package** — имя пакета
- **Version** — версия
- **Architecture** — архитектура (amd64, i386, all)
- **Maintainer** — автор
- **Description** — описание

Опциональные поля:
- **Section** — категория (utils, admin, web, etc.)
- **Priority** — приоритет (optional, required, important)
- **Depends** — зависимости
- **Recommends** — рекомендуемые пакеты
- **Suggests** — предлагаемые пакеты

**Пример:**
```
Package: myapp-config
Version: 1.0.0
Section: utils
Priority: optional
Architecture: all
Maintainer: Vovchik <vovchik@openclaw.ai>
Description: Конфигурационные файлы для MyApp
 Этот пакет содержит конфигурационные файлы
 и скрипты для работы MyApp.
```

---

### 1.4. Скрипты maintainer

**postinst** — выполняется после установки файлов:
```bash
#!/bin/bash
set -e
echo "Настройка после установки..."
# Создание директорий, пользователей, настройка прав
exit 0
```

**prerm** — выполняется перед удалением:
```bash
#!/bin/bash
set -e
echo "Подготовка к удалению..."
# Остановка сервисов, сохранение данных
exit 0
```

**Важно:**
- Скрипты должны иметь права на выполнение (chmod 755)
- Должны начинаться с `#!/bin/bash` или `#!/bin/sh`
- Должны завершаться с `exit 0` при успехе

---

## 2. Создание структуры пакета

### 2.1. Создание директорий

**Команда:**
```bash
mkdir -p myapp-config_1.0.0_all/DEBIAN
mkdir -p myapp-config_1.0.0_all/usr/local/bin
mkdir -p myapp-config_1.0.0_all/etc/myapp
mkdir -p myapp-config_1.0.0_all/usr/share/doc/myapp-config
```

**Результат:**
```
myapp-config_1.0.0_all/
├── DEBIAN/
├── etc/
│   └── myapp/
├── usr/
│   ├── local/
│   │   └── bin/
│   └── share/
│       └── doc/
│           └── myapp-config/
```

---

### 2.2. Создание control файла

**Команда:**
```bash
cat > myapp-config_1.0.0_all/DEBIAN/control << 'EOF'
Package: myapp-config
Version: 1.0.0
Section: utils
Priority: optional
Architecture: all
Maintainer: Vovchik <vovchik@openclaw.ai>
Description: Конфигурационные файлы и скрипты для MyApp
 Этот пакет содержит:
  - Скрипт мониторинга системы
  - Конфигурационные файлы
  - Документацию
EOF
```

---

### 2.3. Создание postinst скрипта

**Команда:**
```bash
cat > myapp-config_1.0.0_all/DEBIAN/postinst << 'EOF'
#!/bin/bash
set -e

echo "MyApp Config: Настройка после установки..."

# Создание директории для логов
mkdir -p /var/log/myapp
chmod 755 /var/log/myapp

echo "MyApp Config установлен успешно!"
exit 0
EOF

chmod 755 myapp-config_1.0.0_all/DEBIAN/postinst
```

**Что делает скрипт:**
- Создаёт директорию для логов `/var/log/myapp`
- Устанавливает права 755
- Выводит сообщение об успешной установке

---

### 2.4. Создание prerm скрипта

**Команда:**
```bash
cat > myapp-config_1.0.0_all/DEBIAN/prerm << 'EOF'
#!/bin/bash
set -e

echo "MyApp Config: Подготовка к удалению..."
exit 0
EOF

chmod 755 myapp-config_1.0.0_all/DEBIAN/prerm
```

---

### 2.5. Создание исполняемого скрипта

**Файл:** `/usr/local/bin/myapp-monitor`

**Команда:**
```bash
cat > myapp-config_1.0.0_all/usr/local/bin/myapp-monitor << 'EOF'
#!/bin/bash
# Скрипт мониторинга системы MyApp

echo "=== MyApp System Monitor ==="
echo "Дата: $(date)"
echo ""
echo "Использование CPU:"
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
echo ""
echo "Использование памяти:"
free -h | grep Mem | awk '{print "Использовано: "$3" из "$2}'
echo ""
echo "Использование диска:"
df -h / | tail -1 | awk '{print "Использовано: "$3" из "$2" ("$5")"}'
EOF

chmod 755 myapp-config_1.0.0_all/usr/local/bin/myapp-monitor
```

**Функционал скрипта:**
- Отображает дату и время
- Показывает загрузку CPU
- Показывает использование RAM
- Показывает использование диска

---

### 2.6. Создание конфигурационного файла

**Файл:** `/etc/myapp/config.conf`

**Команда:**
```bash
cat > myapp-config_1.0.0_all/etc/myapp/config.conf << 'EOF'
# MyApp Configuration File
# Version: 1.0.0

[General]
app_name = MyApp
version = 1.0.0
debug_mode = false

[Monitoring]
check_interval = 60
log_level = info
log_path = /var/log/myapp/monitor.log

[Alerts]
enabled = true
email = admin@example.com
EOF
```

---

### 2.7. Создание документации

**README:**
```bash
cat > myapp-config_1.0.0_all/usr/share/doc/myapp-config/README << 'EOF'
MyApp Config Package
====================

Этот пакет содержит конфигурационные файлы и утилиты для MyApp.

Файлы:
- /usr/local/bin/myapp-monitor - скрипт мониторинга
- /etc/myapp/config.conf - конфигурация
- /var/log/myapp/ - директория логов

Использование:
  myapp-monitor - запуск мониторинга

Автор: Vovchik
Версия: 1.0.0
EOF
```

**changelog:**
```bash
cat > myapp-config_1.0.0_all/usr/share/doc/myapp-config/changelog << 'EOF'
myapp-config (1.0.0) stable; urgency=low

  * Initial release
  * Added system monitoring script
  * Added configuration files
  * Added documentation

 -- Vovchik <vovchik@openclaw.ai>  Sat, 28 Feb 2026 13:35:00 +0300
EOF

gzip -9 myapp-config_1.0.0_all/usr/share/doc/myapp-config/changelog
```

**Примечание:** changelog должен быть сжат gzip для соответствия стандартам Debian.

---

## 3. Сборка пакета

### 3.1. Проверка структуры

**Команда:**
```bash
find myapp-config_1.0.0_all -type f
```

**Вывод:**
```
myapp-config_1.0.0_all/DEBIAN/postinst
myapp-config_1.0.0_all/DEBIAN/control
myapp-config_1.0.0_all/DEBIAN/prerm
myapp-config_1.0.0_all/etc/myapp/config.conf
myapp-config_1.0.0_all/usr/share/doc/myapp-config/changelog.gz
myapp-config_1.0.0_all/usr/share/doc/myapp-config/README
myapp-config_1.0.0_all/usr/local/bin/myapp-monitor
```

---

### 3.2. Сборка пакета

**Команда:**
```bash
dpkg-deb --build myapp-config_1.0.0_all
```

**Вывод:**
```
dpkg-deb: building package 'myapp-config' in 'myapp-config_1.0.0_all.deb'.
```

**Результат:** Создан файл `myapp-config_1.0.0_all.deb`

---

### 3.3. Проверка информации о пакете

**Команда:**
```bash
dpkg-deb --info myapp-config_1.0.0_all.deb
```

**Вывод:**
```
 new Debian package, version 2.0.
 size 1982 bytes: control archive=595 bytes.
     390 bytes,    11 lines      control
     238 bytes,    11 lines   *  postinst             #!/bin/bash
      92 bytes,     5 lines   *  prerm                #!/bin/bash
 Package: myapp-config
 Version: 1.0.0
 Section: utils
 Priority: optional
 Architecture: all
 Maintainer: Vovchik <vovchik@openclaw.ai>
 Description: Конфигурационные файлы и скрипты для MyApp
  Этот пакет содержит:
   - Скрипт мониторинга системы
   - Конфигурационные файлы
   - Документацию
```

---

### 3.4. Просмотр содержимого пакета

**Команда:**
```bash
dpkg-deb --contents myapp-config_1.0.0_all.deb
```

**Вывод:**
```
drwxr-xr-x root/root         0 2026-02-28 13:34 ./
drwxr-xr-x root/root         0 2026-02-28 13:34 ./etc/
drwxr-xr-x root/root         0 2026-02-28 13:34 ./etc/myapp/
-rw-r--r-- root/root       247 2026-02-28 13:34 ./etc/myapp/config.conf
drwxr-xr-x root/root         0 2026-02-28 13:34 ./usr/
drwxr-xr-x root/root         0 2026-02-28 13:34 ./usr/local/
drwxr-xr-x root/root         0 2026-02-28 13:34 ./usr/local/bin/
-rwxr-xr-x root/root       541 2026-02-28 13:34 ./usr/local/bin/myapp-monitor
drwxr-xr-x root/root         0 2026-02-28 13:34 ./usr/share/
drwxr-xr-x root/root         0 2026-02-28 13:34 ./usr/share/doc/
drwxr-xr-x root/root         0 2026-02-28 13:34 ./usr/share/doc/myapp-config/
-rw-r--r-- root/root       466 2026-02-28 13:34 ./usr/share/doc/myapp-config/README
-rw-r--r-- root/root       194 2026-02-28 13:34 ./usr/share/doc/myapp-config/changelog.gz
```

---

## 4. Тестирование пакета

### 4.1. Установка пакета

**Команда:**
```bash
sudo dpkg -i myapp-config_1.0.0_all.deb
```

**Вывод:**
```
Selecting previously unselected package myapp-config.
(Reading database ... 196292 files and directories currently installed.)
Preparing to unpack myapp-config_1.0.0_all.deb ...
Unpacking myapp-config (1.0.0) ...
Setting up myapp-config (1.0.0) ...
MyApp Config: Настройка после установки...
MyApp Config установлен успешно!
```

**Пояснение:**
- `Selecting previously unselected package` — пакет устанавливается впервые
- `Setting up myapp-config (1.0.0)...` — выполняется postinst скрипт

---

### 4.2. Проверка установки

**Команда:**
```bash
dpkg -l | grep myapp-config
```

**Вывод:**
```
ii  myapp-config  1.0.0  all  Конфигурационные файлы и скрипты для MyApp
```

**Расшифровка:**
- `ii` — пакет установлен корректно

---

### 4.3. Проверка установленных файлов

**Команда:**
```bash
dpkg -L myapp-config
```

**Вывод:**
```
/.
/etc
/etc/myapp
/etc/myapp/config.conf
/usr
/usr/local
/usr/local/bin
/usr/local/bin/myapp-monitor
/usr/share
/usr/share/doc
/usr/share/doc/myapp-config
/usr/share/doc/myapp-config/README
/usr/share/doc/myapp-config/changelog.gz
```

---

### 4.4. Проверка работы скрипта

**Команда:**
```bash
which myapp-monitor
myapp-monitor
```

**Вывод:**
```
/usr/local/bin/myapp-monitor
=== MyApp System Monitor ===
Дата: Sat Feb 28 01:35:23 PM MSK 2026

Использование CPU:
0%

Использование памяти:
Использовано: 2.2Gi из 7.8Gi

Использование диска:
Использовано: 25G из 50G (53%)
```

✅ **Скрипт работает корректно!**

---

### 4.5. Проверка конфигурации

**Команда:**
```bash
cat /etc/myapp/config.conf
```

**Вывод:**
```
# MyApp Configuration File
# Version: 1.0.0

[General]
app_name = MyApp
version = 1.0.0
debug_mode = false

[Monitoring]
check_interval = 60
log_level = info
log_path = /var/log/myapp/monitor.log

[Alerts]
enabled = true
email = admin@example.com
```

✅ **Конфигурация установлена!**

---

### 4.6. Проверка postinst скрипта

**Команда:**
```bash
ls -la /var/log/myapp/
```

**Вывод:**
```
total 8
drwxr-xr-x  2 root root   4096 Feb 28 13:35 .
drwxrwxr-x 19 root syslog 4096 Feb 28 13:35 ..
```

✅ **postinst скрипт выполнился — директория создана!**

---

### 4.7. Удаление пакета (remove)

**Команда:**
```bash
sudo dpkg -r myapp-config
```

**Вывод:**
```
(Reading database ... 196300 files and directories currently installed.)
Removing myapp-config (1.0.0) ...
MyApp Config: Подготовка к удалению...
```

**Проверка:**
```bash
dpkg -l | grep myapp-config
```

**Результат:** Пакет удалён (не отображается)

**Примечание:** При `dpkg -r` конфигурационные файлы могут остаться.

---

### 4.8. Полное удаление (purge)

**Команда:**
```bash
sudo dpkg -P myapp-config
```

**Назначение:** Удаляет пакет вместе с конфигурационными файлами.

**Разница:**
- `dpkg -r` (remove) — удаляет программу, оставляет конфигурацию
- `dpkg -P` (purge) — удаляет всё, включая конфигурацию

---

## 5. Полная инструкция по созданию .deb пакета

### Шаг 1: Создание структуры

```bash
# Переменные
PACKAGE_NAME="myapp-config"
VERSION="1.0.0"
ARCH="all"
BUILD_DIR="${PACKAGE_NAME}_${VERSION}_${ARCH}"

# Создание директорий
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$BUILD_DIR/usr/local/bin"
mkdir -p "$BUILD_DIR/etc/myapp"
mkdir -p "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME"
```

---

### Шаг 2: Создание control файла

```bash
cat > "$BUILD_DIR/DEBIAN/control" << 'EOF'
Package: myapp-config
Version: 1.0.0
Section: utils
Priority: optional
Architecture: all
Maintainer: Vovchik <vovchik@openclaw.ai>
Description: Конфигурационные файлы и скрипты для MyApp
 Этот пакет содержит:
  - Скрипт мониторинга системы
  - Конфигурационные файлы
  - Документацию
EOF
```

---

### Шаг 3: Создание maintainer скриптов

**postinst:**
```bash
cat > "$BUILD_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e
echo "MyApp Config: Настройка после установки..."
mkdir -p /var/log/myapp
chmod 755 /var/log/myapp
echo "MyApp Config установлен успешно!"
exit 0
EOF

chmod 755 "$BUILD_DIR/DEBIAN/postinst"
```

**prerm:**
```bash
cat > "$BUILD_DIR/DEBIAN/prerm" << 'EOF'
#!/bin/bash
set -e
echo "MyApp Config: Подготовка к удалению..."
exit 0
EOF

chmod 755 "$BUILD_DIR/DEBIAN/prerm"
```

---

### Шаг 4: Добавление файлов

**Скрипт:**
```bash
cat > "$BUILD_DIR/usr/local/bin/myapp-monitor" << 'EOF'
#!/bin/bash
echo "=== MyApp System Monitor ==="
echo "Дата: $(date)"
# ... (код мониторинга)
EOF

chmod 755 "$BUILD_DIR/usr/local/bin/myapp-monitor"
```

**Конфигурация:**
```bash
cat > "$BUILD_DIR/etc/myapp/config.conf" << 'EOF'
# MyApp Configuration File
# ... (содержимое конфига)
EOF
```

**Документация:**
```bash
cat > "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME/README" << 'EOF'
MyApp Config Package
# ... (описание)
EOF

cat > "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME/changelog" << 'EOF'
myapp-config (1.0.0) stable; urgency=low
  * Initial release
 -- Vovchik <vovchik@openclaw.ai>  Sat, 28 Feb 2026 13:35:00 +0300
EOF

gzip -9 "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME/changelog"
```

---

### Шаг 5: Сборка пакета

```bash
dpkg-deb --build "$BUILD_DIR"
```

**Результат:** Файл `myapp-config_1.0.0_all.deb`

---

### Шаг 6: Тестирование

```bash
# Проверка информации
dpkg-deb --info myapp-config_1.0.0_all.deb

# Просмотр содержимого
dpkg-deb --contents myapp-config_1.0.0_all.deb

# Установка
sudo dpkg -i myapp-config_1.0.0_all.deb

# Проверка
dpkg -l | grep myapp-config
myapp-monitor

# Удаление
sudo dpkg -r myapp-config
```

---

## Итоги выполнения задания

✅ **Выполнено:**

1. **Создан .deb пакет:**
   - ✅ Имя: myapp-config
   - ✅ Версия: 1.0.0
   - ✅ Размер: 2.0 KB
   - ✅ Архитектура: all (платформонезависимый)

2. **Содержимое пакета:**
   - ✅ Скрипт мониторинга системы
   - ✅ Конфигурационный файл
   - ✅ Документация (README + changelog)
   - ✅ Maintainer скрипты (postinst, prerm)

3. **Изучен процесс упаковки:**
   - ✅ Структура .deb пакета
   - ✅ Control файл и метаданные
   - ✅ Maintainer скрипты
   - ✅ Сборка через dpkg-deb
   - ✅ Тестирование установки/удаления

---

## Полезные команды

### Работа с пакетами

```bash
# Создание пакета
dpkg-deb --build package-dir

# Информация о пакете
dpkg-deb --info package.deb

# Содержимое пакета
dpkg-deb --contents package.deb

# Распаковка пакета
dpkg-deb --extract package.deb /path/to/dir

# Извлечение control файлов
dpkg-deb --control package.deb /path/to/dir
```

### Управление установленными пакетами

```bash
# Список установленных пакетов
dpkg -l

# Информация об установленном пакете
dpkg -s package-name

# Файлы установленного пакета
dpkg -L package-name

# Какой пакет установил файл
dpkg -S /path/to/file

# Установка пакета
sudo dpkg -i package.deb

# Удаление пакета
sudo dpkg -r package-name

# Полное удаление (с конфигами)
sudo dpkg -P package-name
```

### Проверка и исправление

```bash
# Проверка целостности пакетов
sudo dpkg --audit

# Настройка неполных пакетов
sudo dpkg --configure -a

# Исправление зависимостей после установки
sudo apt-get install -f
```

---

## Дополнительно: Автоматизация

Полный скрипт сборки доступен в:
- `task4_package_build/create_deb_package.sh`

Запуск:
```bash
./create_deb_package.sh
```

---

**Дата:** 2026-02-28  
**Выполнил:** Вовчик  
**Система:** Ubuntu 24.04 Noble  
**Время создания пакета:** ~5 минут
