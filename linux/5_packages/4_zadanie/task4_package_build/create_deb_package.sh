#!/bin/bash
# Создание .deb пакета с конфигурационными файлами

PACKAGE_NAME="myapp-config"
VERSION="1.0.0"
ARCH="all"
BUILD_DIR="${PACKAGE_NAME}_${VERSION}_${ARCH}"

echo "=== Создание структуры пакета ==="
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$BUILD_DIR/usr/local/bin"
mkdir -p "$BUILD_DIR/etc/myapp"
mkdir -p "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME"

echo ""
echo "=== Создание control файла ==="
cat > "$BUILD_DIR/DEBIAN/control" << CONTROL
Package: $PACKAGE_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: Vovchik <vovchik@openclaw.ai>
Description: Конфигурационные файлы и скрипты для MyApp
 Этот пакет содержит:
  - Скрипт мониторинга системы
  - Конфигурационные файлы
  - Документацию
CONTROL

echo ""
echo "=== Создание postinst скрипта ==="
cat > "$BUILD_DIR/DEBIAN/postinst" << 'POSTINST'
#!/bin/bash
set -e

echo "MyApp Config: Настройка после установки..."

# Создание логов
mkdir -p /var/log/myapp
chmod 755 /var/log/myapp

echo "MyApp Config установлен успешно!"
exit 0
POSTINST

chmod 755 "$BUILD_DIR/DEBIAN/postinst"

echo ""
echo "=== Создание prerm скрипта ==="
cat > "$BUILD_DIR/DEBIAN/prerm" << 'PRERM'
#!/bin/bash
set -e

echo "MyApp Config: Подготовка к удалению..."
exit 0
PRERM

chmod 755 "$BUILD_DIR/DEBIAN/prerm"

echo ""
echo "=== Создание исполняемого скрипта ==="
cat > "$BUILD_DIR/usr/local/bin/myapp-monitor" << 'SCRIPT'
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
SCRIPT

chmod 755 "$BUILD_DIR/usr/local/bin/myapp-monitor"

echo ""
echo "=== Создание конфигурационного файла ==="
cat > "$BUILD_DIR/etc/myapp/config.conf" << 'CONFIG'
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
CONFIG

echo ""
echo "=== Создание README ==="
cat > "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME/README" << 'README'
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
README

echo ""
echo "=== Создание changelog ==="
cat > "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME/changelog" << 'CHANGELOG'
myapp-config (1.0.0) stable; urgency=low

  * Initial release
  * Added system monitoring script
  * Added configuration files
  * Added documentation

 -- Vovchik <vovchik@openclaw.ai>  Sat, 28 Feb 2026 13:35:00 +0300
CHANGELOG

gzip -9 "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME/changelog"

echo ""
echo "=== Структура пакета ==="
tree "$BUILD_DIR" || find "$BUILD_DIR" -type f

echo ""
echo "=== Сборка .deb пакета ==="
dpkg-deb --build "$BUILD_DIR"

echo ""
echo "=== Информация о пакете ==="
dpkg-deb --info "${BUILD_DIR}.deb"

echo ""
echo "=== Содержимое пакета ==="
dpkg-deb --contents "${BUILD_DIR}.deb"

echo ""
echo "=== Пакет создан: ${BUILD_DIR}.deb ==="
ls -lh "${BUILD_DIR}.deb"

