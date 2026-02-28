#!/bin/bash

#######################################
# Скрипт мониторинга системы
# Автор: Александр Диптан
# Дата: 2026-02-28
#######################################

# Настройки
LOG_DIR="./logs"
LOG_FILE="${LOG_DIR}/system_monitor.log"
ERROR_LOG="${LOG_DIR}/system_monitor.err"
MAX_LOG_DAYS=3
DEBUG_MODE=${DEBUG_MODE:-0}

# Включение отладки если установлена переменная
if [ "$DEBUG_MODE" = "1" ]; then
    set -x
fi

# Создание директории для логов
mkdir -p "$LOG_DIR"

# Функция логирования
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$ERROR_LOG" >&2
}

# Обработчик сигналов
cleanup() {
    log_info "Получен сигнал завершения. Останавливаю мониторинг..."
    log_info "Скрипт завершён корректно"
    exit 0
}

# Установка обработчиков сигналов
trap cleanup SIGINT SIGTERM

# Функция ротации логов
rotate_logs() {
    log_info "Запуск ротации логов (хранить последние $MAX_LOG_DAYS дней)"
    
    # Удаление логов старше MAX_LOG_DAYS дней
    find "$LOG_DIR" -name "*.log" -type f -mtime +$MAX_LOG_DAYS -delete 2>/dev/null
    find "$LOG_DIR" -name "*.err" -type f -mtime +$MAX_LOG_DAYS -delete 2>/dev/null
    
    if [ $? -eq 0 ]; then
        log_info "Ротация логов завершена успешно"
    else
        log_error "Ошибка при ротации логов"
    fi
}

# Функция мониторинга CPU
monitor_cpu() {
    log_info "=== Мониторинг CPU ==="
    
    # Получение загрузки CPU
    if command -v mpstat &> /dev/null; then
        mpstat 1 1 >> "$LOG_FILE" 2>> "$ERROR_LOG"
    else
        # Альтернатива через top
        top -bn1 | grep "Cpu(s)" >> "$LOG_FILE" 2>> "$ERROR_LOG"
    fi
    
    # Проверка высокой загрузки
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    log_info "Текущая загрузка CPU: ${cpu_usage}%"
    
    if (( $(echo "$cpu_usage > 80" | bc -l 2>/dev/null || echo 0) )); then
        log_error "ВНИМАНИЕ: Высокая загрузка CPU: ${cpu_usage}%"
    fi
}

# Функция мониторинга памяти
monitor_memory() {
    log_info "=== Мониторинг памяти ==="
    
    # Использование памяти
    free -h >> "$LOG_FILE" 2>> "$ERROR_LOG"
    
    # Процент использования памяти
    mem_usage=$(free | grep Mem | awk '{printf("%.1f"), $3/$2 * 100.0}')
    log_info "Использование памяти: ${mem_usage}%"
    
    if (( $(echo "$mem_usage > 85" | bc -l 2>/dev/null || echo 0) )); then
        log_error "ВНИМАНИЕ: Высокое использование памяти: ${mem_usage}%"
    fi
}

# Функция мониторинга диска
monitor_disk() {
    log_info "=== Мониторинг диска ==="
    
    # Использование дискового пространства
    df -h >> "$LOG_FILE" 2>> "$ERROR_LOG"
    
    # Проверка заполненности дисков
    while IFS= read -r line; do
        usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        mount=$(echo "$line" | awk '{print $6}')
        
        if [ -n "$usage" ] && [ "$usage" -gt 85 ] 2>/dev/null; then
            log_error "ВНИМАНИЕ: Диск $mount заполнен на ${usage}%"
        fi
    done < <(df -h | tail -n +2)
    
    log_info "Мониторинг дисков завершён"
}

# Функция создания отчёта
create_report() {
    local report_file="${LOG_DIR}/report_$(date +%Y%m%d_%H%M%S).log"
    
    {
        echo "================================================"
        echo "Отчёт о состоянии системы"
        echo "Дата: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Hostname: $(hostname)"
        echo "Uptime: $(uptime)"
        echo "================================================"
        echo ""
        echo "--- CPU ---"
        top -bn1 | head -5
        echo ""
        echo "--- Память ---"
        free -h
        echo ""
        echo "--- Диск ---"
        df -h
        echo ""
        echo "--- Top процессы по CPU ---"
        ps aux --sort=-%cpu | head -6
        echo ""
        echo "--- Top процессы по памяти ---"
        ps aux --sort=-%mem | head -6
        echo ""
        echo "================================================"
    } > "$report_file"
    
    log_info "Отчёт сохранён: $report_file"
}

# Главная функция
main() {
    log_info "================================================"
    log_info "Запуск мониторинга системы"
    log_info "================================================"
    
    # Ротация логов
    rotate_logs
    
    # Мониторинг компонентов
    monitor_cpu
    monitor_memory
    monitor_disk
    
    # Создание отчёта
    create_report
    
    log_info "================================================"
    log_info "Мониторинг завершён"
    log_info "================================================"
}

# Запуск
main "$@"
