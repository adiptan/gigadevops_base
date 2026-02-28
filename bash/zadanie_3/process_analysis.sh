#!/bin/bash
# Анализ процессов и диагностика
# Автор: Александр Диптан

LOG_FILE="./process_analysis.log"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "=== Анализ процессов системы ==="

# 1. Создание нагрузки на CPU
log "Запуск процесса нагрузки CPU..."
yes > /dev/null &
CPU_PID=$!
log "CPU процесс: PID=$CPU_PID"

# 2. Анализ через /proc
log "Информация из /proc/$CPU_PID/status:"
cat /proc/$CPU_PID/status | head -10 >> "$LOG_FILE"

# 3. strace анализ
log "Анализ системных вызовов ls..."
strace -c ls / 2>&1 | tail -20 >> "$LOG_FILE"

# 4. Изменение приоритета
log "Изменение nice для PID=$CPU_PID..."
renice +10 $CPU_PID 2>&1 | tee -a "$LOG_FILE"

# 5. Топ процессов
log "Топ процессов по CPU:"
ps aux --sort=-%cpu | head -10 >> "$LOG_FILE"

# Остановка тестового процесса
kill $CPU_PID 2>/dev/null
log "Анализ завершён"
