#!/usr/bin/env bash

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                            ║
# ║                     Скрипт исправления разрешений файлов                   ║
# ║                                                                            ║
# ╚════════════════════════════════════════════════════════════════════════════╝

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
log_msg() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка, работаем ли мы от имени root
if [ "$EUID" -ne 0 ]; then
  log_error "Этот скрипт должен быть запущен от имени суперпользователя (root)"
  log_error "Пожалуйста, используйте sudo: sudo $0"
  exit 1
fi

# Проверка существования пользователя
if ! id "redm00us" &>/dev/null; then
  log_error "Пользователь redm00us не существует"
  log_error "Пожалуйста, создайте пользователя перед запуском этого скрипта"
  exit 1
fi

log_msg "Создание группы redm00us, если она не существует..."
if ! getent group redm00us &>/dev/null; then
  groupadd redm00us
  log_msg "Группа redm00us создана"
else
  log_msg "Группа redm00us уже существует"
fi

log_msg "Установка правильных разрешений на файлы..."
mkdir -p /home/redm00us/.cache/meowrch
chown -R redm00us:redm00us /home/redm00us/.cache/meowrch

# Проверка наличия bin-директорий и установка разрешений
for bin_dir in "/etc/nixos/modules/meowrch-hyprland/meowrch/home/bin" "/home/redm00us/bin"; do
  if [ -d "$bin_dir" ]; then
    log_msg "Установка исполняемых прав для скриптов в $bin_dir"
    find "$bin_dir" -type f -name "*.sh" -exec chmod +x {} \;
    find "$bin_dir" -type f -name "*.py" -exec chmod +x {} \;
    chown -R redm00us:redm00us "$bin_dir"
  fi
done

# Проверка .config директории
if [ -d "/home/redm00us/.config" ]; then
  log_msg "Установка прав на .config директорию"
  chown -R redm00us:redm00us /home/redm00us/.config
fi

log_msg "Запуск nixos-rebuild..."
cd /etc/nixos || exit 1

if [ -f "/etc/nixos/flake.nix" ]; then
  log_msg "Обнаружен flake.nix, выполняем nix flake update"
  nix flake update
  log_msg "Выполняем nixos-rebuild switch..."
  NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake ".#nixos" --impure
else
  log_msg "Выполняем стандартный nixos-rebuild switch..."
  NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch
fi

log_msg "Все готово! Разрешения файлов исправлены и система обновлена."
log_msg "Рекомендуем перезагрузить систему для применения всех изменений."