# Задание 2: Управление зависимостями

**Дата выполнения:** 2026-02-28  
**Система:** Ubuntu 24.04 (Noble)  
**Пакетный менеджер:** APT  
**Тестовый пакет:** apache2

---

## Пункт 1: Установить пакет

### 1.1. Проверка доступности пакета

**Команда:**
```bash
apt-cache show apache2
```

**Вывод:**
```
Package: apache2
Architecture: amd64
Version: 2.4.58-1ubuntu8.10
Priority: optional
Section: web
Origin: Ubuntu
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Installed-Size: 455 kB
Provides: httpd, httpd-cgi
Pre-Depends: init-system-helpers (>= 1.54~)
Depends: apache2-bin (= 2.4.58-1ubuntu8.10), 
         apache2-data (= 2.4.58-1ubuntu8.10), 
         apache2-utils (= 2.4.58-1ubuntu8.10), 
         media-types, perl:any, procps
Recommends: ssl-cert
Suggests: apache2-doc, apache2-suexec-pristine, www-browser, ufw
```

---

### 1.2. Установка пакета

**Команда:**
```bash
sudo apt install -y apache2
```

**Вывод:**
```
Reading package lists...
Building dependency tree...
Reading state information...
The following additional packages will be installed:
  apache2-bin apache2-data apache2-utils libapr1t64 
  libaprutil1-dbd-sqlite3 libaprutil1-ldap libaprutil1t64
The following NEW packages will be installed:
  apache2 apache2-bin apache2-data apache2-utils libapr1t64 
  libaprutil1-dbd-sqlite3 libaprutil1-ldap libaprutil1t64
0 upgraded, 8 newly installed, 0 to remove and 166 not upgraded.
```

**Пояснение:**
- Основной пакет: `apache2`
- Автоматически установленные зависимости: 7 пакетов
  - `apache2-bin` — бинарные файлы Apache
  - `apache2-data` — общие файлы
  - `apache2-utils` — утилиты для веб-сервера
  - `libapr1t64` — Apache Portable Runtime Library
  - `libaprutil1-*` — утилиты APR

---

### 1.3. Проверка установки

**Команда:**
```bash
dpkg -l | grep apache2
```

**Вывод:**
```
ii  apache2           2.4.58-1ubuntu8.10  amd64  Apache HTTP Server
ii  apache2-bin       2.4.58-1ubuntu8.10  amd64  Apache (modules and binary files)
ii  apache2-data      2.4.58-1ubuntu8.10  all    Apache (common files)
ii  apache2-utils     2.4.58-1ubuntu8.10  amd64  Apache (utility programs)
```

**Расшифровка:**
- `ii` — пакет установлен и сконфигурирован

---

## Пункт 2: Проверить какие зависимости требуются для корректной работы пакета

### 2.1. Просмотр зависимостей через apt-cache depends

**Команда:**
```bash
apt-cache depends apache2
```

**Вывод:**
```
apache2
  PreDepends: init-system-helpers
  Depends: apache2-bin
  Depends: apache2-data
  Depends: apache2-utils
  Depends: media-types
  Depends: perl:any
  Depends: procps
  Recommends: ssl-cert
  Suggests: apache2-doc
  Suggests: apache2-suexec-pristine
  Suggests: apache2-suexec-custom
  Suggests: www-browser
  Suggests: ufw
```

**Типы зависимостей:**
- **PreDepends** — должны быть установлены ДО установки пакета
- **Depends** — обязательные зависимости
- **Recommends** — рекомендуемые пакеты (устанавливаются по умолчанию)
- **Suggests** — предлагаемые пакеты (не устанавливаются автоматически)

---

### 2.2. Детальный просмотр зависимостей

**Команда:**
```bash
apt show apache2 | grep -A 5 "Depends:"
```

**Вывод:**
```
Pre-Depends: init-system-helpers (>= 1.54~)
Depends: apache2-bin (= 2.4.58-1ubuntu8.10), 
         apache2-data (= 2.4.58-1ubuntu8.10), 
         apache2-utils (= 2.4.58-1ubuntu8.10), 
         media-types, perl:any, procps
Recommends: ssl-cert
Suggests: apache2-doc, apache2-suexec-pristine, www-browser, ufw
```

**Пояснение:**
- Строгие зависимости версий (`= 2.4.58-1ubuntu8.10`) для бинарных файлов
- Гибкие зависимости для библиотек (`perl:any`)
- Минимальная версия для PreDepends (`>= 1.54~`)

---

### 2.3. Обратные зависимости

**Команда:**
```bash
apt-cache rdepends apache2
```

**Вывод:**
```
apache2
Reverse Depends:
  libapache2-mod-md
  keystone
  cinder-api
  xymon
  squid-cgi
  roundcube-core
  prometheus-apache-exporter
  pagure
  nova-api-os-compute
  nagios4-cgi
  live-build-cgi
  libsoup2.4-tests
```

**Пояснение:**
Список пакетов, которые зависят от apache2. Полезно при удалении пакета — можно увидеть, какие другие пакеты перестанут работать.

---

### 2.4. Просмотр файлов, установленных пакетом

**Команда:**
```bash
dpkg -L apache2 | head -20
```

**Вывод:**
```
/.
/etc
/etc/apache2
/etc/apache2/apache2.conf
/etc/apache2/conf-available
/etc/apache2/conf-available/charset.conf
/etc/apache2/conf-available/localized-error-pages.conf
/etc/apache2/conf-available/other-vhosts-access-log.conf
/etc/apache2/conf-available/security.conf
/etc/apache2/conf-available/serve-cgi-bin.conf
/etc/apache2/conf-enabled
/etc/apache2/envvars
/etc/apache2/magic
/etc/apache2/mods-available
/etc/apache2/mods-available/access_compat.load
/etc/apache2/mods-available/actions.conf
/etc/apache2/mods-available/actions.load
/etc/apache2/mods-available/alias.conf
/etc/apache2/mods-available/alias.load
/etc/apache2/mods-available/allowmethods.load
```

**Структура:**
- `/etc/apache2/` — конфигурационные файлы
- `/etc/apache2/mods-available/` — доступные модули
- `/etc/apache2/conf-available/` — доступные конфигурации

---

### 2.5. Просмотр автоматически установленных пакетов

**Команда:**
```bash
apt-mark showauto | grep apache
```

**Вывод:**
```
apache2-bin
apache2-data
apache2-utils
```

**Пояснение:**
Эти пакеты были установлены автоматически как зависимости apache2 и будут удалены при выполнении `apt autoremove` после удаления apache2.

---

## Пункт 3: Попробовать очистить неиспользуемые зависимости

### 3.1. Проверка неиспользуемых пакетов (dry-run)

**Команда:**
```bash
apt autoremove --dry-run
```

**Вывод:**
```
Reading package lists...
Building dependency tree...
Reading state information...
0 upgraded, 0 newly installed, 0 to remove and 166 not upgraded.
```

**Пояснение:**
После установки apache2 все зависимости используются, поэтому список пуст. Для демонстрации удалим основной пакет.

---

### 3.2. Удаление основного пакета

**Команда:**
```bash
sudo apt remove -y apache2
```

**Вывод:**
```
Reading package lists...
Building dependency tree...
Reading state information...
The following packages were automatically installed and are no longer required:
  apache2-bin apache2-data apache2-utils libapr1t64 libaprutil1-dbd-sqlite3
  libaprutil1-ldap libaprutil1t64
Use 'apt autoremove' to remove them.
The following packages will be REMOVED:
  apache2
0 upgraded, 0 newly installed, 1 to remove and 166 not upgraded.
After this operation, 466 kB disk space will be freed.
Removing apache2 (2.4.58-1ubuntu8.10) ...
```

**Важно:**
После удаления основного пакета система предложила удалить 7 зависимостей, которые больше не нужны.

---

### 3.3. Очистка неиспользуемых зависимостей

**Команда:**
```bash
sudo apt autoremove -y
```

**Вывод:**
```
Reading package lists...
Building dependency tree...
Reading state information...
The following packages will be REMOVED:
  apache2-bin apache2-data apache2-utils libapr1t64 
  libaprutil1-dbd-sqlite3 libaprutil1-ldap libaprutil1t64
0 upgraded, 0 newly installed, 7 to remove and 166 not upgraded.
After this operation, 7,008 kB disk space will be freed.
Removing apache2-bin (2.4.58-1ubuntu8.10) ...
Removing apache2-data (2.4.58-1ubuntu8.10) ...
Removing apache2-utils (2.4.58-1ubuntu8.10) ...
Removing libaprutil1-dbd-sqlite3:amd64 (1.6.3-1.1ubuntu7) ...
Removing libaprutil1-ldap:amd64 (1.6.3-1.1ubuntu7) ...
Removing libaprutil1t64:amd64 (1.6.3-1.1ubuntu7) ...
Removing libapr1t64:amd64 (1.7.2-3.1ubuntu0.1) ...
```

**Результат:**
- Удалено 7 пакетов
- Освобождено 7 МБ дискового пространства

---

### 3.4. Очистка кэша пакетов

**Команда:**
```bash
sudo apt autoclean
```

**Назначение:**
Удаляет из кэша `/var/cache/apt/archives/` устаревшие версии пакетов, которые больше недоступны в репозиториях.

**Альтернативы:**
```bash
# Удалить ВСЕ пакеты из кэша
sudo apt clean

# Показать размер кэша
du -sh /var/cache/apt/archives/
```

---

### 3.5. Проверка результата очистки

**Команда:**
```bash
dpkg -l | grep apache2
```

**Вывод:**
```
rc  apache2  2.4.58-1ubuntu8.10  amd64  Apache HTTP Server
```

**Расшифровка статуса:**
- `rc` — пакет удалён (removed), но конфигурационные файлы остались (config-files)

**Полное удаление с конфигами:**
```bash
sudo apt purge apache2
```

---

## Итоги выполнения задания

✅ **Выполнено:**
1. Установлен пакет apache2 с 7 зависимостями
2. Изучены способы проверки зависимостей:
   - `apt-cache depends` — прямые зависимости
   - `apt-cache rdepends` — обратные зависимости
   - `apt-mark showauto` — автоматически установленные пакеты
   - `dpkg -L` — список файлов пакета
3. Очищены неиспользуемые зависимости:
   - `apt autoremove` — удаление лишних пакетов
   - `apt autoclean` — очистка устаревшего кэша
   - `apt clean` — полная очистка кэша

**Полезные команды:**
- `apt-cache depends <package>` — показать зависимости
- `apt-cache rdepends <package>` — показать обратные зависимости
- `apt show <package>` — детальная информация с зависимостями
- `apt-mark showauto` — список автоматически установленных пакетов
- `apt-mark showmanual` — список вручную установленных пакетов
- `apt autoremove` — удалить неиспользуемые зависимости
- `apt autoclean` — очистить устаревший кэш
- `apt clean` — полностью очистить кэш
- `dpkg -L <package>` — список файлов пакета

**Статистика:**
- Установлено пакетов: 8 (1 основной + 7 зависимостей)
- Размер установки: ~7.5 МБ
- Удалено при autoremove: 7 пакетов
- Освобождено места: ~7 МБ

---

**Дата:** 2026-02-28  
**Выполнил:** Вовчик  
**Система:** Ubuntu 24.04 Noble
