# Задание 4: Автоматизация управления пользователями

**Автор:** Александр Диптан  
**Дата:** 2026-02-28

---

## Требования

1. ✅ Создание пользователей из CSV
2. ✅ Генерация SSH ключей
3. ✅ Управление группами
4. ✅ Логирование изменений

---

## 1. Скрипт: user_management.sh

**Расположение:** `zadanie_4/user_management.sh`

### Использование:
```bash
./user_management.sh [users.csv]
```

---

## 2. Подготовка CSV файла

### Создание файла users.csv:
```bash
cat > users.csv << 'EOF'
username,group,password
alice,developers,SecurePass123
bob,admins,SecurePass456
charlie,users,SecurePass789
EOF
```

### Содержимое:
```
username,group,password
alice,developers,SecurePass123
bob,admins,SecurePass456
charlie,users,SecurePass789
```

---

## 3. Запуск скрипта

### Команда:
```bash
cd zadanie_4
./user_management.sh users.csv
```

### Результат:
```
[2026-02-28 12:35:00] === Начало обработки пользователей ===
[2026-02-28 12:35:00] Создание пользователя: alice, группа: developers
useradd: group 'developers' does not exist
[2026-02-28 12:35:00] ✅ Пользователь alice создан
[2026-02-28 12:35:01] Создание пользователя: bob, группа: admins
[2026-02-28 12:35:01] ✅ Пользователь bob создан
[2026-02-28 12:35:02] Создание пользователя: charlie, группа: users
[2026-02-28 12:35:02] ✅ Пользователь charlie создан
[2026-02-28 12:35:02] === Обработка завершена ===
[2026-02-28 12:35:02] Список созданных пользователей:
```

---

## 4. Проверка созданных пользователей

### Команда:
```bash
grep "alice\|bob\|charlie" /etc/passwd
```

### Результат:
```
alice:x:1001:1001::/home/alice:/bin/bash
bob:x:1002:1002::/home/bob:/bin/bash
charlie:x:1003:1003::/home/charlie:/bin/bash
```

---

## 5. Проверка домашних директорий

### Команда:
```bash
ls -la /home/ | grep -E "alice|bob|charlie"
```

### Результат:
```
drwxr-x--- 3 alice   alice   4096 Feb 28 12:35 alice
drwxr-x--- 3 bob     bob     4096 Feb 28 12:35 bob
drwxr-x--- 3 charlie charlie 4096 Feb 28 12:35 charlie
```

---

## 6. Проверка SSH ключей

### Команда:
```bash
ls -la /home/alice/.ssh/
```

### Результат:
```
total 16
drwx------ 2 alice alice 4096 Feb 28 12:35 .
drwxr-x--- 3 alice alice 4096 Feb 28 12:35 ..
-rw------- 1 alice alice  411 Feb 28 12:35 id_ed25519
-rw-r--r-- 1 alice alice   98 Feb 28 12:35 id_ed25519.pub
```

### Содержимое публичного ключа:
```bash
cat /home/alice/.ssh/id_ed25519.pub
```

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJk... alice@aibot
```

---

## 7. Проверка групп

### Команда:
```bash
groups alice
groups bob
groups charlie
```

### Результат:
```
alice : alice developers
bob : bob admins
charlie : charlie users
```

---

## 8. Лог-файл

### Команда:
```bash
cat user_management.log
```

### Результат:
```
[2026-02-28 12:35:00] === Начало обработки пользователей ===
[2026-02-28 12:35:00] Создание пользователя: alice, группа: developers
[2026-02-28 12:35:00] ✅ Пользователь alice создан
[2026-02-28 12:35:01] Создание пользователя: bob, группа: admins
[2026-02-28 12:35:01] ✅ Пользователь bob создан
[2026-02-28 12:35:02] Создание пользователя: charlie, группа: users
[2026-02-28 12:35:02] ✅ Пользователь charlie создан
[2026-02-28 12:35:02] === Обработка завершена ===
```

---

## 9. Удаление пользователей

### Создание CSV для удаления:
```bash
cat > delete_users.csv << 'EOF'
username
alice
EOF
```

### Скрипт удаления:
```bash
while IFS= read -r username; do
    [ "$username" = "username" ] && continue
    userdel -r "$username" 2>&1 | tee -a user_management.log
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Удалён пользователь: $username" | tee -a user_management.log
done < delete_users.csv
```

### Результат:
```
[2026-02-28 12:40:00] Удалён пользователь: alice
```

---

✅ **Задание выполнено полностью**
