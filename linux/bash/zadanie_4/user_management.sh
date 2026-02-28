#!/bin/bash
# Управление пользователями
# Автор: Александр Диптан

LOG_FILE="./user_management.log"
CSV_FILE="${1:-users.csv}"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" >&2; }

create_user() {
    local username=$1
    local group=$2
    local password=$3
    
    log "Создание пользователя: $username, группа: $group"
    
    if id "$username" &>/dev/null; then
        log "Пользователь $username уже существует"
        return 1
    fi
    
    useradd -m -s /bin/bash -G "$group" "$username" 2>&1 | tee -a "$LOG_FILE"
    echo "$username:$password" | chpasswd 2>&1 | tee -a "$LOG_FILE"
    
    # Генерация SSH ключа
    sudo -u "$username" ssh-keygen -t ed25519 -f "/home/$username/.ssh/id_ed25519" -N "" 2>&1 | tee -a "$LOG_FILE"
    
    log "✅ Пользователь $username создан"
}

# Чтение CSV и создание пользователей
if [ ! -f "$CSV_FILE" ]; then
    log "CSV файл не найден. Создаю пример..."
    echo "username,group,password" > "$CSV_FILE"
    echo "testuser1,developers,pass123" >> "$CSV_FILE"
    echo "testuser2,admins,pass456" >> "$CSV_FILE"
fi

log "=== Начало обработки пользователей ==="
while IFS=, read -r username group password; do
    [ "$username" = "username" ] && continue
    create_user "$username" "$group" "$password"
done < "$CSV_FILE"

log "=== Обработка завершена ==="
log "Список созданных пользователей:"
grep "/home" /etc/passwd | tail -5 >> "$LOG_FILE"
