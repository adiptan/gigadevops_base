#!/bin/bash
# Задание 1: Базовая работа с пакетами

echo "=== Пункт 1: Поиск пакета по имени или описанию ==="
echo ""

echo "1.1. Поиск пакета по имени 'htop':"
apt search htop 2>&1 | head -15

echo ""
echo "1.2. Поиск пакета по описанию (monitor):"
apt-cache search "system monitor" | head -10

echo ""
echo "1.3. Детальная информация о пакете htop:"
apt show htop 2>&1 | head -20

echo ""
echo "=== Пункт 2: Установка/удаление/обновление пакетов ==="
echo ""

echo "2.1. Проверка, установлен ли пакет htop:"
dpkg -l | grep htop || echo "Пакет htop не установлен"

echo ""
echo "2.2. Установка пакета htop:"
apt install -y htop 2>&1 | tail -10

echo ""
echo "2.3. Проверка установленной версии:"
htop --version

echo ""
echo "2.4. Проверка установки:"
dpkg -l | grep htop

echo ""
echo "2.5. Обновление пакета (если доступна новая версия):"
apt list --upgradable 2>&1 | grep htop || echo "Нет доступных обновлений для htop"

echo ""
echo "2.6. Удаление пакета htop:"
apt remove -y htop 2>&1 | tail -10

echo ""
echo "2.7. Проверка удаления:"
dpkg -l | grep htop || echo "Пакет htop удалён"

echo ""
echo "=== Пункт 3: Откат пакета ==="
echo ""

echo "3.1. Просмотр доступных версий пакета:"
apt-cache policy htop

echo ""
echo "3.2. Установка конкретной версии (если доступно):"
echo "Команда: apt install htop=<версия>"
echo "(Для примера установим последнюю доступную)"
apt install -y htop 2>&1 | tail -5

echo ""
echo "3.3. Проверка версии после установки:"
dpkg -l | grep htop

echo ""
echo "3.4. Откат через apt-mark hold (фиксация версии):"
apt-mark hold htop
apt-mark showhold

echo ""
echo "3.5. Снятие фиксации:"
apt-mark unhold htop
apt-mark showhold || echo "Нет зафиксированных пакетов"

