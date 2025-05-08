#!/usr/bin/env bash

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                            ║
# ║                     Скрипт настройки Meowrch в NixOS                       ║
# ║                                                                            ║
# ╚════════════════════════════════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

# Проверка, что у нас NixOS
if ! command -v nixos-rebuild &> /dev/null; then
  log_error "Этот скрипт предназначен только для NixOS"
  exit 1
fi

# Создание директорий, если их нет
log_msg "Создание необходимых директорий..."
mkdir -p /etc/nixos/modules/meowrch-hyprland
mkdir -p /etc/nixos/bin
mkdir -p /home/$SUDO_USER/.cache/meowrch

# Копирование файлов в системные директории
log_msg "Копирование конфигурационных файлов..."
cp -r "$SCRIPT_DIR/modules/meowrch-hyprland" "/etc/nixos/modules/"
cp "$SCRIPT_DIR/home.nix" "/etc/nixos/"
cp "$SCRIPT_DIR/flake.nix" "/etc/nixos/"

# Проверка и обновление конфигурации, если нужно
if ! grep -q "modules.meowrch-hyprland" "/etc/nixos/home.nix"; then
  log_warn "Модуль meowrch-hyprland не найден в home.nix"
  log_warn "Пожалуйста, убедитесь, что у вас есть следующие строки в home.nix:"
  echo -e "  imports = [
    ./modules/meowrch-hyprland/home.nix
  ];
  
  modules.meowrch-hyprland = {
    enable = true;
  };"
fi

# Установка правильных разрешений
log_msg "Установка правильных разрешений на файлы..."
mkdir -p /home/$SUDO_USER/.cache/meowrch
chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.cache/meowrch
find "/etc/nixos/modules/meowrch-hyprland/meowrch/home/bin" -type f -name "*.sh" -exec chmod +x {} \;
find "/etc/nixos/modules/meowrch-hyprland/meowrch/home/bin" -type f -name "*.py" -exec chmod +x {} \;

# Обновление flake и пересборка системы
log_msg "Обновление flake и перестройка системы..."
cd /etc/nixos
nix flake update
NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake /etc/nixos#nixos --impure

log_msg "Настройка Meowrch Hyprland завершена!"
log_msg "Вы можете перезагрузить систему и выбрать Hyprland при входе в систему."
log_msg "После входа выполните команду: python ~/.config/meowrch/meowrch.py --action select-theme"
log_msg "для выбора темы оформления."