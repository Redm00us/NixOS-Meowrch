#!/usr/bin/env bash
# Скрипт для перезапуска XDG порталов в Hyprland
# Автор: Redm00us

# Устанавливаем цвета для вывода
BLUE="\e[1;34m"
GREEN="\e[1;32m"
RED="\e[1;31m"
YELLOW="\e[1;33m"
RESET="\e[0m"

# Сообщения
echo -e "${BLUE}[*] Перезапуск XDG порталов для Hyprland...${RESET}"

# Определение директории с бинарными файлами
# NixOS использует другой путь для портальных сервисов
if [ -d "/run/current-system/sw/libexec" ]; then
    libDir="/run/current-system/sw/libexec"
else
    libDir="/usr/libexec"
fi

# Убиваем существующие экземпляры порталов
echo -e "${YELLOW}[*] Завершение работы текущих порталов...${RESET}"
killall xdg-desktop-portal-hyprland 2>/dev/null
killall xdg-desktop-portal-gnome 2>/dev/null
killall xdg-desktop-portal-kde 2>/dev/null
killall xdg-desktop-portal-wlr 2>/dev/null
killall xdg-desktop-portal-gtk 2>/dev/null
killall xdg-desktop-portal 2>/dev/null

# Даем время на выключение
sleep 1

# Проверяем, что процессы завершены
if pgrep -f "xdg-desktop-portal" > /dev/null; then
    echo -e "${RED}[!] Некоторые порталы продолжают работать. Форсированное завершение...${RESET}"
    killall -9 xdg-desktop-portal-hyprland 2>/dev/null
    killall -9 xdg-desktop-portal 2>/dev/null
    sleep 1
fi

# Запускаем порталы в правильном порядке
echo -e "${YELLOW}[*] Запуск XDG порталов...${RESET}"

# Сначала запускаем hyprland-специфичный портал
$libDir/xdg-desktop-portal-hyprland &
# Даем время на инициализацию
sleep 2
# Затем запускаем основной портал
$libDir/xdg-desktop-portal &
# Даем время на инициализацию основного портала
sleep 2

# Проверка успешного запуска
if pgrep -f "xdg-desktop-portal-hyprland" > /dev/null && pgrep -f "xdg-desktop-portal$" > /dev/null; then
    echo -e "${GREEN}[✓] XDG порталы успешно перезапущены${RESET}"
else
    echo -e "${RED}[!] Ошибка при запуске порталов. Проверьте логи и зависимости!${RESET}"
    exit 1
fi

echo -e "${GREEN}[✓] Завершено. XDG порталы должны работать корректно.${RESET}"
exit 0