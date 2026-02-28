#!/bin/bash
# Система резервного копирования
# Автор: Александр Диптан

BACKUP_DIR="./backups"
SOURCE_DIR="${1:-.}"
LOG_FILE="./backup.log"
CHECKSUM_FILE="./checksums.md5"

mkdir -p "$BACKUP_DIR"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" >&2; }

# Создание инкрементального архива
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

log "Создание архива: $ARCHIVE_NAME"
tar -czf "$ARCHIVE_PATH" -C "$SOURCE_DIR" . 2>&1 | tee -a "$LOG_FILE"

if [ $? -eq 0 ]; then
    log "Архив создан успешно: $ARCHIVE_PATH"
    
    # Проверка целостности
    log "Проверка целостности архива..."
    CHECKSUM=$(md5sum "$ARCHIVE_PATH" | awk '{print $1}')
    echo "$CHECKSUM  $ARCHIVE_NAME" >> "$CHECKSUM_FILE"
    log "MD5: $CHECKSUM"
    
    # Проверка архива
    tar -tzf "$ARCHIVE_PATH" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log "✅ Архив прошёл проверку целостности"
    else
        error "❌ Архив повреждён!"
        exit 1
    fi
else
    error "❌ Ошибка создания архива"
    exit 1
fi

# Удаление старых архивов (старше 7 дней)
log "Очистка старых архивов..."
find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete
log "Резервное копирование завершено"
