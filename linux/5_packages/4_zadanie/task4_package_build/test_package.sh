#!/bin/bash
# Тестирование .deb пакета

PACKAGE_FILE="myapp-config_1.0.0_all.deb"

echo "=== Шаг 1: Проверка пакета перед установкой ==="
dpkg-deb --info "$PACKAGE_FILE"

echo ""
echo "=== Шаг 2: Установка пакета ==="
dpkg -i "$PACKAGE_FILE"

echo ""
echo "=== Шаг 3: Проверка установки ==="
dpkg -l | grep myapp-config

echo ""
echo "=== Шаг 4: Проверка файлов ==="
echo "Файлы пакета:"
dpkg -L myapp-config

echo ""
echo "=== Шаг 5: Проверка работы скрипта ==="
which myapp-monitor
myapp-monitor

echo ""
echo "=== Шаг 6: Проверка конфигурации ==="
cat /etc/myapp/config.conf

echo ""
echo "=== Шаг 7: Проверка логов ==="
ls -la /var/log/myapp/ 2>/dev/null || echo "Директория логов не создана (postinst не выполнился?)"

echo ""
echo "=== Шаг 8: Удаление пакета ==="
dpkg -r myapp-config

echo ""
echo "=== Шаг 9: Проверка удаления ==="
dpkg -l | grep myapp-config || echo "Пакет успешно удалён"

echo ""
echo "=== Шаг 10: Проверка оставшихся файлов ==="
ls -la /etc/myapp/ 2>/dev/null && echo "Конфигурация осталась (purge для полного удаления)" || echo "Конфигурация удалена"
which myapp-monitor || echo "Скрипт удалён"

echo ""
echo "=== Шаг 11: Полное удаление (purge) ==="
dpkg -P myapp-config 2>/dev/null || echo "Пакет уже удалён"

echo ""
echo "=== Шаг 12: Повторная установка для проверки ==="
dpkg -i "$PACKAGE_FILE"
dpkg -l | grep myapp-config

echo ""
echo "=== Тестирование завершено ==="

