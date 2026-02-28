# Задание 1: Базовая работа с пакетами

**Дата выполнения:** 2026-02-28  
**Система:** Ubuntu 24.04 (Noble)  
**Пакетный менеджер:** APT

---

## Пункт 1: Найти определенный пакет по имени или по описанию

### 1.1. Поиск пакета по имени

**Команда:**
```bash
apt search htop
```

**Вывод:**
```
WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Sorting...
Full Text Search...
aha/noble 0.5.1-3build1 amd64
  ANSI color to HTML converter

bashtop/noble 0.9.25-1 all
  Resource monitor that shows usage and stats

bpytop/noble 1.0.68-2 all
  Resource monitor that shows usage and stats

btm/noble 0.9.6-4 amd64
  customizable graphical process/system monitor for the terminal

btop/noble 1.3.0-1 amd64
  Modern and colorful command line resource monitor that shows usage and stats

htop/noble 3.3.0-4build1 amd64
  interactive processes viewer
```

---

### 1.2. Поиск пакета по описанию

**Команда:**
```bash
apt-cache search "system monitor"
```

**Вывод:**
```
erlang-os-mon - Erlang/OTP operating system monitor
gir1.2-gtop-2.0 - gtop system monitoring library (gir bindings)
libgtop-2.0-11 - gtop system monitoring library (shared)
libgtop2-common - gtop system monitoring library (common)
libgtop2-doc - gtop system monitoring library (documentation)
arm-trusted-firmware-tools - "secure world" software for ARM SoCs - tools
beep - advanced PC-speaker beeper
btm - customizable graphical process/system monitor for the terminal
cairo-dock-system-monitor-plug-in - System Monitor plug-in for Cairo-dock
conky-all - highly configurable system monitor (all features enabled)
```

---

### 1.3. Детальная информация о пакете

**Команда:**
```bash
apt show htop
```

**Вывод:**
```
Package: htop
Version: 3.3.0-4build1
Priority: optional
Section: utils
Origin: Ubuntu
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Original-Maintainer: Daniel Lange <DLange@debian.org>
Bugs: https://bugs.launchpad.net/ubuntu/+filebug
Installed-Size: 434 kB
Depends: libc6 (>= 2.38), libncursesw6 (>= 6), libnl-3-200 (>= 3.2.7), 
         libnl-genl-3-200 (>= 3.2.7), libtinfo6 (>= 6)
Suggests: lm-sensors, lsof, strace
Homepage: https://htop.dev/
Download-Size: 171 kB
APT-Manual-Installed: yes
APT-Sources: http://ru.archive.ubuntu.com/ubuntu noble/main amd64 Packages
Description: interactive processes viewer
 Htop is an ncursed-based process viewer similar to top, but it
 allows one to scroll the list vertically and horizontally to see
 all processes and their full command lines.
```

---

## Пункт 2: Установка/удаление пакетов

### 2.1. Проверка наличия пакета

**Команда:**
```bash
dpkg -l | grep htop
```

**Вывод:**
```
ii  htop  3.3.0-4build1  amd64  interactive processes viewer
```
*(ii означает, что пакет установлен)*

---

### 2.2. Установка пакета

**Команда:**
```bash
sudo apt install -y htop
```

**Вывод:**
```
Reading package lists...
Building dependency tree...
Reading state information...
htop is already the newest version (3.3.0-4build1).
0 upgraded, 0 newly installed, 0 to remove and 166 not upgraded.
```

---

### 2.3. Проверка установленной версии

**Команда:**
```bash
htop --version
```

**Вывод:**
```
htop 3.3.0
```

---

### 2.4. Обновление установленного пакета

**Команда:**
```bash
sudo apt upgrade htop
```

или для проверки доступных обновлений:
```bash
apt list --upgradable | grep htop
```

**Вывод:**
```
Нет доступных обновлений для htop
```
*(Пакет уже последней версии)*

---

### 2.5. Удаление пакета

**Команда:**
```bash
sudo apt remove -y htop
```

**Вывод:**
```
Reading package lists...
Building dependency tree...
Reading state information...
The following packages will be REMOVED:
  htop
0 upgraded, 0 newly installed, 1 to remove and 166 not upgraded.
After this operation, 434 kB disk space will be freed.
Removing htop (3.3.0-4build1) ...
Processing triggers for hicolor-icon-theme (0.17-2) ...
Processing triggers for gnome-menus (3.36.0-1.1ubuntu3) ...
Processing triggers for man-db (2.12.0-4build2) ...
Processing triggers for desktop-file-utils (0.27-2build1) ...
```

**Проверка удаления:**
```bash
dpkg -l | grep htop
```
**Результат:** *Пакет отсутствует в списке установленных*

---

### 2.6. Полное удаление пакета (с конфигурационными файлами)

**Команда:**
```bash
sudo apt purge htop
```

**Разница между `remove` и `purge`:**
- `apt remove` — удаляет пакет, но оставляет конфигурационные файлы
- `apt purge` — удаляет пакет вместе с конфигурационными файлами

---

## Пункт 3: Изучить способы отката пакета в случае его некорректной установки

### 3.1. Просмотр доступных версий пакета

**Команда:**
```bash
apt-cache policy htop
```

**Вывод:**
```
htop:
  Installed: (none)
  Candidate: 3.3.0-4build1
  Version table:
     3.3.0-4build1 500
        500 http://ru.archive.ubuntu.com/ubuntu noble/main amd64 Packages
```

**Пояснение:**
- `Installed` — установленная версия
- `Candidate` — версия, которая будет установлена по умолчанию
- `Version table` — список доступных версий из репозиториев

---

### 3.2. Установка конкретной версии пакета

**Команда:**
```bash
sudo apt install htop=3.3.0-4build1
```

**Синтаксис:**
```
sudo apt install <package>=<version>
```

**Вывод:**
```
Reading package lists...
Building dependency tree...
Reading state information...
The following NEW packages will be installed:
  htop
Setting up htop (3.3.0-4build1) ...
Processing triggers for desktop-file-utils (0.27-2build1) ...
Processing triggers for hicolor-icon-theme (0.17-2) ...
Processing triggers for gnome-menus (3.36.0-1.1ubuntu3) ...
Processing triggers for man-db (2.12.0-4build2) ...
```

---

### 3.3. Фиксация версии пакета (предотвращение обновления)

**Команда:**
```bash
sudo apt-mark hold htop
```

**Вывод:**
```
htop set on hold.
```

**Проверка зафиксированных пакетов:**
```bash
apt-mark showhold
```

**Вывод:**
```
htop
```

**Пояснение:**
Команда `apt-mark hold` предотвращает автоматическое обновление пакета при выполнении `apt upgrade`. Это полезно, если нужно зафиксировать конкретную версию пакета.

---

### 3.4. Снятие фиксации версии

**Команда:**
```bash
sudo apt-mark unhold htop
```

**Вывод:**
```
Canceled hold on htop.
```

---

### 3.5. Откат через понижение версии (downgrade)

**Способ 1: Установка старой версии из кэша**

Если старая версия есть в кэше APT:
```bash
ls /var/cache/apt/archives/ | grep htop
```

Установка из .deb файла:
```bash
sudo dpkg -i /var/cache/apt/archives/htop_<old-version>.deb
```

**Способ 2: Использование snapshot.debian.org (для Debian)**

Для Ubuntu можно использовать old-releases.ubuntu.com для получения старых версий пакетов.

**Способ 3: Откат через dpkg**

1. Скачать нужную версию .deb пакета
2. Установить через dpkg:
   ```bash
   sudo dpkg -i htop_<version>.deb
   sudo apt-mark hold htop
   ```

---

## Итоги выполнения задания

✅ **Выполнено:**
1. Изучены команды поиска пакетов (`apt search`, `apt-cache search`, `apt show`)
2. Освоены операции установки, обновления и удаления пакетов
3. Изучены способы отката пакетов:
   - Установка конкретной версии
   - Фиксация версии через `apt-mark hold`
   - Понижение версии (downgrade) через dpkg

**Используемые команды:**
- `apt search <name>` — поиск по имени
- `apt-cache search "<description>"` — поиск по описанию
- `apt show <package>` — детальная информация
- `apt install <package>` — установка
- `apt upgrade <package>` — обновление
- `apt remove <package>` — удаление (с сохранением конфигов)
- `apt purge <package>` — полное удаление
- `apt-cache policy <package>` — просмотр версий
- `apt install <package>=<version>` — установка конкретной версии
- `apt-mark hold <package>` — фиксация версии
- `apt-mark unhold <package>` — снятие фиксации
- `dpkg -i <file.deb>` — установка из .deb файла

---

**Дата:** 2026-02-28  
**Выполнил:** Вовчик  
**Система:** Ubuntu 24.04 Noble
