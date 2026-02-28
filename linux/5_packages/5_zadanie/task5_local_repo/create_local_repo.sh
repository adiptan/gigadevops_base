#!/bin/bash
# Создание локального APT репозитория

REPO_NAME="myrepo"
REPO_DIR="/var/www/html/${REPO_NAME}"
DIST="stable"
COMPONENT="main"
ARCH="amd64"

echo "=== Шаг 1: Установка необходимых пакетов ==="
apt install -y dpkg-dev apt-utils

echo ""
echo "=== Шаг 2: Создание структуры репозитория ==="
mkdir -p "${REPO_DIR}"
mkdir -p "${REPO_DIR}/pool/${COMPONENT}"
mkdir -p "${REPO_DIR}/dists/${DIST}/${COMPONENT}/binary-${ARCH}"
mkdir -p "${REPO_DIR}/dists/${DIST}/${COMPONENT}/binary-all"

echo "Структура создана:"
tree "${REPO_DIR}" || find "${REPO_DIR}" -type d

echo ""
echo "=== Шаг 3: Копирование пакетов в репозиторий ==="
# Копируем наш созданный пакет
cp /root/.openclaw/workspace/gigadevops_base/linux/5_packages/task4_package_build/myapp-config_1.0.0_all.deb \
   "${REPO_DIR}/pool/${COMPONENT}/"

echo "Пакеты в репозитории:"
ls -lh "${REPO_DIR}/pool/${COMPONENT}/"

echo ""
echo "=== Шаг 4: Генерация метаданных Packages ==="
cd "${REPO_DIR}"

# Генерация Packages файла для binary-all (наш пакет all архитектуры)
dpkg-scanpackages --arch all pool/${COMPONENT} > dists/${DIST}/${COMPONENT}/binary-all/Packages
gzip -9c dists/${DIST}/${COMPONENT}/binary-all/Packages > dists/${DIST}/${COMPONENT}/binary-all/Packages.gz

echo "Packages файл создан для binary-all"

# Также создаём для amd64 (для совместимости)
dpkg-scanpackages --arch amd64 pool/${COMPONENT} > dists/${DIST}/${COMPONENT}/binary-${ARCH}/Packages 2>/dev/null || touch dists/${DIST}/${COMPONENT}/binary-${ARCH}/Packages
gzip -9c dists/${DIST}/${COMPONENT}/binary-${ARCH}/Packages > dists/${DIST}/${COMPONENT}/binary-${ARCH}/Packages.gz

echo "Packages файл создан для binary-amd64"

echo ""
echo "=== Шаг 5: Создание Release файла ==="
cat > dists/${DIST}/Release << RELEASE
Origin: MyLocalRepo
Label: MyLocalRepo
Suite: ${DIST}
Codename: ${DIST}
Architectures: amd64 all
Components: ${COMPONENT}
Description: Локальный APT репозиторий
Date: $(date -R)
RELEASE

echo "Release файл создан:"
cat dists/${DIST}/Release

echo ""
echo "=== Шаг 6: Генерация файла MD5SUMS для Release ==="
cd dists/${DIST}
cat > MD5SUMS << EOF_MD5
$(md5sum ${COMPONENT}/binary-${ARCH}/Packages | awk '{print $1, $2}')
$(md5sum ${COMPONENT}/binary-${ARCH}/Packages.gz | awk '{print $1, $2}')
$(md5sum ${COMPONENT}/binary-all/Packages | awk '{print $1, $2}')
$(md5sum ${COMPONENT}/binary-all/Packages.gz | awk '{print $1, $2}')
EOF_MD5

echo "MD5SUMS создан:"
cat MD5SUMS

cd "${REPO_DIR}"

echo ""
echo "=== Шаг 7: Настройка доступа к репозиторию через HTTP ==="
# Nginx уже установлен из предыдущего задания
# Репозиторий доступен по http://localhost/myrepo

echo "URL репозитория: http://localhost/${REPO_NAME}"

echo ""
echo "=== Шаг 8: Добавление репозитория в sources.list ==="
cat > /etc/apt/sources.list.d/myrepo.list << SOURCES
deb [trusted=yes] http://localhost/${REPO_NAME} ${DIST} ${COMPONENT}
SOURCES

echo "Файл /etc/apt/sources.list.d/myrepo.list создан:"
cat /etc/apt/sources.list.d/myrepo.list

echo ""
echo "=== Шаг 9: Обновление списка пакетов ==="
apt update 2>&1 | grep -A 5 "localhost/${REPO_NAME}" || apt update

echo ""
echo "=== Шаг 10: Проверка доступности пакета из репозитория ==="
apt-cache policy myapp-config

echo ""
echo "=== Локальный репозиторий создан! ==="
echo "Репозиторий: ${REPO_DIR}"
echo "URL: http://localhost/${REPO_NAME}"
echo "Пакеты в репозитории:"
ls -lh "${REPO_DIR}/pool/${COMPONENT}/"

