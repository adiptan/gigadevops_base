#!/bin/bash
# Задание 2: Управление зависимостями

echo "=== Пункт 1: Установить пакет ==="
echo ""

echo "1.1. Проверка доступности пакета apache2:"
apt-cache show apache2 | head -15

echo ""
echo "1.2. Установка пакета apache2:"
apt install -y apache2 2>&1 | grep -E "(NEW|upgraded|installed|to remove)"

echo ""
echo "1.3. Проверка установки:"
dpkg -l | grep apache2 | head -10

echo ""
echo "=== Пункт 2: Проверить зависимости пакета ==="
echo ""

echo "2.1. Просмотр зависимостей apache2 (через apt-cache depends):"
apt-cache depends apache2

echo ""
echo "2.2. Просмотр зависимостей через apt show:"
apt show apache2 2>&1 | grep -A 5 "Depends:"

echo ""
echo "2.3. Обратные зависимости (какие пакеты зависят от apache2):"
apt-cache rdepends apache2 | head -15

echo ""
echo "2.4. Детальный просмотр установленных зависимостей (через dpkg):"
dpkg -l | grep apache2

echo ""
echo "2.5. Просмотр файлов, установленных пакетом:"
dpkg -L apache2 | head -20

echo ""
echo "=== Пункт 3: Очистка неиспользуемых зависимостей ==="
echo ""

echo "3.1. Проверка пакетов, которые больше не нужны:"
apt autoremove --dry-run 2>&1 | tail -20

echo ""
echo "3.2. Просмотр пакетов, установленных автоматически (зависимости):"
apt-mark showauto | head -20

echo ""
echo "3.3. Поиск устаревших пакетов в кэше:"
apt autoclean --dry-run 2>&1 || apt-get autoclean -s 2>&1 | tail -10

echo ""
echo "3.4. Удаление apache2 для демонстрации очистки зависимостей:"
apt remove -y apache2 2>&1 | tail -15

echo ""
echo "3.5. Очистка оставшихся зависимостей:"
apt autoremove -y 2>&1 | tail -15

echo ""
echo "3.6. Проверка результата:"
dpkg -l | grep apache2 || echo "Пакет apache2 и его зависимости удалены"

