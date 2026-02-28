#!/bin/bash
# Тестирование автообновления через репозиторий

REPO_DIR="/var/www/html/myrepo"
DIST="stable"
COMPONENT="main"

echo "=== Шаг 1: Создание новой версии пакета (1.0.1) ==="

# Копируем структуру предыдущего пакета
cp -r ../task4_package_build/myapp-config_1.0.0_all myapp-config_1.0.1_all

# Обновляем версию в control
sed -i 's/Version: 1.0.0/Version: 1.0.1/' myapp-config_1.0.1_all/DEBIAN/control

# Добавляем новую функцию в скрипт
cat >> myapp-config_1.0.1_all/usr/local/bin/myapp-monitor << 'SCRIPT'
echo ""
echo "Версия: 1.0.1 (обновлённая)"
SCRIPT

# Пересобираем пакет
dpkg-deb --build myapp-config_1.0.1_all

echo ""
echo "=== Шаг 2: Добавление нового пакета в репозиторий ==="
cp myapp-config_1.0.1_all.deb "${REPO_DIR}/pool/${COMPONENT}/"

echo "Пакеты в репозитории:"
ls -lh "${REPO_DIR}/pool/${COMPONENT}/"

echo ""
echo "=== Шаг 3: Обновление метаданных репозитория ==="
cd "${REPO_DIR}"

# Регенерация Packages файлов
dpkg-scanpackages --arch all pool/${COMPONENT} > dists/${DIST}/${COMPONENT}/binary-all/Packages
gzip -9fc dists/${DIST}/${COMPONENT}/binary-all/Packages > dists/${DIST}/${COMPONENT}/binary-all/Packages.gz

dpkg-scanpackages --arch amd64 pool/${COMPONENT} > dists/${DIST}/${COMPONENT}/binary-${ARCH}/Packages 2>/dev/null || touch dists/${DIST}/${COMPONENT}/binary-${ARCH}/Packages
gzip -9fc dists/${DIST}/${COMPONENT}/binary-${ARCH}/Packages > dists/${DIST}/${COMPONENT}/binary-${ARCH}/Packages.gz

# Регенерация Release файла
cd dists/${DIST}
cat > Release << 'RELEASE'
Origin: MyLocalRepo
Label: MyLocalRepo
Suite: stable
Codename: stable
Architectures: amd64 all
Components: main
Description: Локальный APT репозиторий
RELEASE

apt-ftparchive release . >> Release

echo "Release файл обновлён"

echo ""
echo "=== Шаг 4: Обновление списка пакетов ==="
apt update

echo ""
echo "=== Шаг 5: Проверка доступных обновлений ==="
apt list --upgradable 2>/dev/null | grep myapp

echo ""
echo "=== Шаг 6: Обновление пакета ==="
apt upgrade -y myapp-config

echo ""
echo "=== Шаг 7: Проверка версии после обновления ==="
dpkg -l | grep myapp-config
myapp-monitor | tail -2

