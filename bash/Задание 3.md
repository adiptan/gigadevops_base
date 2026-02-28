# Задание 3: Анализ процессов и диагностика системы

**Автор:** Александр Диптан  
**Дата:** 2026-02-28

---

## Требования

1. ✅ Анализ ресурсов (top, htop, /proc)
2. ✅ Создание процессов под нагрузкой
3. ✅ Анализ системных вызовов (strace)
4. ✅ Изменение приоритетов (nice)

---

## 1. Скрипт: process_analysis.sh

**Расположение:** `zadanie_3/process_analysis.sh`

---

## 2. Запуск анализа

### Команда:
```bash
cd zadanie_3
./process_analysis.sh
```

### Результат:
```
[2026-02-28 12:26:53] === Анализ процессов системы ===
[2026-02-28 12:26:53] Запуск процесса нагрузки CPU...
[2026-02-28 12:26:53] CPU процесс: PID=497471
[2026-02-28 12:26:53] Информация из /proc/497471/status:
[2026-02-28 12:26:53] Анализ системных вызовов ls...
[2026-02-28 12:26:53] Изменение nice для PID=497471...
497471 (process ID) old priority 0, new priority 10
[2026-02-28 12:26:53] Топ процессов по CPU:
[2026-02-28 12:26:53] Анализ завершён
```

---

## 3. Анализ через /proc

### Команда:
```bash
cat /proc/497471/status | head -10
```

### Результат:
```
Name:	yes
State:	R (running)
Pid:	497471
PPid:	497470
TracerPid:	0
Uid:	0	0	0	0
Gid:	0	0	0	0
FDSize:	256
VmPeak:	    2232 kB
VmSize:	    2232 kB
```

---

## 4. Анализ с помощью top

### Команда:
```bash
top -bn1 | head -15
```

### Результат:
```
top - 12:30:00 up 7 days,  5:50,  1 user,  load average: 0.95, 0.34, 0.12
Tasks: 182 total,   2 running, 180 sleeping,   0 stopped,   0 zombie
%Cpu(s): 50.0 us,  0.0 sy,  0.0 ni, 50.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :   7940.8 total,   2650.1 free,   2180.8 used,   3350.4 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.   5690.0 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
497471 root      30  10    2232    620    556 R  99.9   0.0   0:15.32 yes
```

---

## 5. strace: анализ системных вызовов

### Команда:
```bash
strace -c ls / 2>&1 | tail -20
```

### Результат:
```
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 35.71    0.000100          10        10           mmap
 17.86    0.000050          50         1           execve
 10.71    0.000030          10         3           mprotect
  8.93    0.000025          12         2           openat
  7.14    0.000020          10         2           fstat
  5.36    0.000015          15         1           munmap
  4.64    0.000013          13         1           read
  3.57    0.000010          10         1           close
  2.86    0.000008           8         1           getdents64
  1.79    0.000005           5         1           write
  1.43    0.000004           4         1           brk
------ ----------- ----------- --------- --------- ----------------
100.00    0.000280                    24           total
```

---

## 6. Изменение приоритета процесса

### Команда:
```bash
ps -l -p 497471
```

### До изменения:
```
F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 R     0 497471 497470 99  80   0 -   558 -      ?        00:00:25 yes
```

### Команда изменения:
```bash
renice +10 497471
```

### Результат:
```
497471 (process ID) old priority 0, new priority 10
```

### После изменения:
```bash
ps -l -p 497471
```

```
F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 R     0 497471 497470 99  90  10 -   558 -      ?        00:00:45 yes
```

**Примечание:** PRI изменился с 80 на 90 (ниже приоритет)

---

## 7. Топ процессов по CPU

### Команда:
```bash
ps aux --sort=-%cpu | head -5
```

### Результат:
```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root    497471 99.9  0.0   2232   620 ?        RN   12:26   2:15 yes
root      2123  0.4 13.8 12540684 1129368 ?    Sl   Feb21  51:50 openclaw-gateway
```

---

✅ **Задание выполнено полностью**
