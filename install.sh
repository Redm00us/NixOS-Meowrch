#!/usr/bin/env bash

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                            ║
# ║                Meowrch Hyprland для NixOS - Установка                      ║
# ║                                                                            ║
# ╚════════════════════════════════════════════════════════════════════════════╝

set -e

REPO_URL="https://github.com/Redm00us/NixOS-Meowrch.git"
TEMP_DIR="/tmp/meowrch-install"
NIXOS_CONFIG_DIR="/etc/nixos"
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

# Создаем временную директорию и клонируем репозиторий
log_msg "Клонирование репозитория Meowrch Hyprland..."
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
git clone "$REPO_URL" "$TEMP_DIR"

# Проверка успешного клонирования
if [ ! -d "$TEMP_DIR/modules" ]; then
  log_error "Не удалось клонировать репозиторий или структура репозитория не соответствует ожидаемой"
  exit 1
fi

# Создание директорий, если их нет
log_msg "Создание необходимых директорий..."
mkdir -p "$NIXOS_CONFIG_DIR/modules/meowrch-hyprland"
mkdir -p /home/$SUDO_USER/.cache/meowrch

# Копирование файлов в системные директории
log_msg "Копирование конфигурационных файлов..."
cp -r "$TEMP_DIR/modules/meowrch-hyprland" "$NIXOS_CONFIG_DIR/modules/"

# Проверяем наличие файла flake.nix
if [ -f "$NIXOS_CONFIG_DIR/flake.nix" ]; then
  log_msg "Обнаружен существующий flake.nix, создаем резервную копию..."
  cp "$NIXOS_CONFIG_DIR/flake.nix" "$NIXOS_CONFIG_DIR/flake.nix.backup.$(date +%Y%m%d%H%M%S)"
  
  # Проверяем, есть ли уже включение hyprland
  if grep -q "hyprland" "$NIXOS_CONFIG_DIR/flake.nix"; then
    log_msg "Hyprland уже настроен в flake.nix"
  else
    log_warn "Необходимо добавить hyprland в ваш flake.nix:"
    echo -e "  inputs.hyprland = {
    url = \"github:hyprwm/Hyprland\";
    inputs.nixpkgs.follows = \"nixpkgs-unstable\";
  };"
    echo
    echo -e "  И не забудьте добавить в outputs.nixosConfigurations.*.modules:"
    echo -e "  inputs.hyprland.nixosModules.default"
  fi
else
  log_msg "Копирование примера flake.nix..."
  cp "$TEMP_DIR/flake.nix" "$NIXOS_CONFIG_DIR/flake.nix"
fi

# Интеграция с home-manager
log_msg "Настройка Home Manager..."
if [ -f "$NIXOS_CONFIG_DIR/home.nix" ]; then
  log_msg "Обнаружен существующий home.nix, создаем резервную копию..."
  cp "$NIXOS_CONFIG_DIR/home.nix" "$NIXOS_CONFIG_DIR/home.nix.backup.$(date +%Y%m%d%H%M%S)"
  
  # Проверяем, есть ли уже импорт модуля meowrch-hyprland
  if grep -q "meowrch-hyprland" "$NIXOS_CONFIG_DIR/home.nix"; then
    log_msg "Модуль meowrch-hyprland уже импортирован в home.nix"
  else
    log_warn "Необходимо добавить следующий импорт в ваш home.nix:"
    echo -e "  imports = [
    ./modules/meowrch-hyprland/home.nix
    # ваши другие импорты...
  ];
  
  modules.meowrch-hyprland = {
    enable = true;
  };"
  fi
else
  log_msg "Копирование примера home.nix..."
  cp "$TEMP_DIR/home.nix" "$NIXOS_CONFIG_DIR/home.nix"
fi

# Настройка конфигурации NixOS
if [ -f "$NIXOS_CONFIG_DIR/configuration.nix" ]; then
  log_msg "Обнаружен существующий configuration.nix, создаем резервную копию..."
  cp "$NIXOS_CONFIG_DIR/configuration.nix" "$NIXOS_CONFIG_DIR/configuration.nix.backup.$(date +%Y%m%d%H%M%S)"
  
  # Проверяем, включен ли уже hyprland
  if grep -q "programs.hyprland.enable" "$NIXOS_CONFIG_DIR/configuration.nix"; then
    log_msg "Hyprland уже включен в configuration.nix"
  else
    log_warn "Необходимо добавить следующие строки в ваш configuration.nix:"
    echo -e "  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };"
    
    echo -e "  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };"
  fi
else
  log_error "Не найден файл configuration.nix. Установка не может быть завершена."
  exit 1
fi

# Автоматическое редактирование home.nix, если пользователь согласен
read -p "Хотите автоматически обновить home.nix для включения модуля meowrch-hyprland? (y/n): " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  if ! grep -q "imports = \[" "$NIXOS_CONFIG_DIR/home.nix"; then
    # Если нет секции imports, добавляем её
    awk 'NR==1{print $0 "\nimports = [\n  ./modules/meowrch-hyprland/home.nix\n];\n\nmodules.meowrch-hyprland = {\n  enable = true;\n};\n"}NR!=1{print}' "$NIXOS_CONFIG_DIR/home.nix" > "$NIXOS_CONFIG_DIR/home.nix.tmp"
    mv "$NIXOS_CONFIG_DIR/home.nix.tmp" "$NIXOS_CONFIG_DIR/home.nix"
  elif ! grep -q "meowrch-hyprland" "$NIXOS_CONFIG_DIR/home.nix"; then
    # Если есть imports, но нет модуля
    awk '/imports = \[/{print $0"\n  ./modules/meowrch-hyprland/home.nix";next}1' "$NIXOS_CONFIG_DIR/home.nix" > "$NIXOS_CONFIG_DIR/home.nix.tmp"
    
    # Также добавляем включение модуля
    if ! grep -q "modules.meowrch-hyprland" "$NIXOS_CONFIG_DIR/home.nix.tmp"; then
      awk '/{/{i++}i==1 && /}/{print "\nmodules.meowrch-hyprland = {\n  enable = true;\n};\n"$0;next}1' "$NIXOS_CONFIG_DIR/home.nix.tmp" > "$NIXOS_CONFIG_DIR/home.nix.tmp2"
      mv "$NIXOS_CONFIG_DIR/home.nix.tmp2" "$NIXOS_CONFIG_DIR/home.nix.tmp"
    fi
    
    mv "$NIXOS_CONFIG_DIR/home.nix.tmp" "$NIXOS_CONFIG_DIR/home.nix"
  fi
  log_msg "home.nix обновлен успешно!"
fi

# Автоматическое редактирование configuration.nix, если пользователь согласен
read -p "Хотите автоматически обновить configuration.nix для включения Hyprland? (y/n): " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  if ! grep -q "programs.hyprland.enable" "$NIXOS_CONFIG_DIR/configuration.nix"; then
    # Добавляем настройки Hyprland
    awk '/{/{i++}i==1 && /}/{print "\n  programs.hyprland = {\n    enable = true;\n    xwayland.enable = true;\n  };\n\n  xdg.portal = {\n    enable = true;\n    extraPortals = with pkgs; [\n      xdg-desktop-portal-hyprland\n      xdg-desktop-portal-gtk\n    ];\n  };\n"$0;next}1' "$NIXOS_CONFIG_DIR/configuration.nix" > "$NIXOS_CONFIG_DIR/configuration.nix.tmp"
    mv "$NIXOS_CONFIG_DIR/configuration.nix.tmp" "$NIXOS_CONFIG_DIR/configuration.nix"
  fi
  log_msg "configuration.nix обновлен успешно!"
fi

# Установка правильных разрешений
log_msg "Установка правильных разрешений на файлы..."
chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.cache/meowrch
find "$NIXOS_CONFIG_DIR/modules/meowrch-hyprland/meowrch/home/bin" -type f -name "*.sh" -exec chmod +x {} \;
find "$NIXOS_CONFIG_DIR/modules/meowrch-hyprland/meowrch/home/bin" -type f -name "*.py" -exec chmod +x {} \;

# Запрашиваем согласие на перестройку системы
read -p "Хотите выполнить nixos-rebuild switch прямо сейчас? (y/n): " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  log_msg "Перестройка системы..."
  cd "$NIXOS_CONFIG_DIR"
  
  # Проверяем, используется ли flake
  if [ -f "$NIXOS_CONFIG_DIR/flake.nix" ]; then
    log_msg "Обнаружен flake.nix, выполняем nix flake update и nixos-rebuild switch --flake..."
    nix flake update
    NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake ".#nixos" --impure
  else
    log_msg "Выполняем стандартный nixos-rebuild switch..."
    NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch
  fi
  
  log_msg "Система обновлена успешно!"
else
  log_msg "Не забудьте выполнить nixos-rebuild switch после внесения необходимых изменений!"
fi

# Очистка
rm -rf "$TEMP_DIR"

log_msg "Установка Meowrch Hyprland завершена!"
log_msg "Вы можете перезагрузить систему и выбрать Hyprland при входе в систему."
log_msg "После входа выполните команду: python ~/.config/meowrch/meowrch.py --action select-theme"
log_msg "для выбора темы оформления."