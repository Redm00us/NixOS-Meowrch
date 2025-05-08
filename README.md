# Meowrch Hyprland для NixOS

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Hyprland](https://img.shields.io/badge/Hyprland-DYNAMIC-blue)
![NixOS](https://img.shields.io/badge/NixOS-24.11-skyblue)

Модуль для NixOS, обеспечивающий красивую и функциональную настройку рабочего окружения Hyprland с темой Meowrch.

![Meowrch Hyprland](https://raw.githubusercontent.com/DIMFLIX-OFFICIAL/Meowrch/master/.meta/screenshot.png)

## Установка одной командой

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Redm00us/NixOS-Meowrch/main/install.sh)"
```

Скрипт установки автоматически:
1. Клонирует репозиторий
2. Настраивает модуль meowrch-hyprland
3. Интегрирует его с вашей конфигурацией NixOS
4. Предложит внести необходимые изменения в configuration.nix и home.nix
5. Выполнит rebuild системы с новой конфигурацией

## Ручная установка

### Необходимые условия

- NixOS 24.11 или новее
- Настроенный Home Manager
- Поддержка flakes

### Шаги установки

1. Клонировать репозиторий:
   ```bash
   git clone https://github.com/Redm00us/NixOS-Meowrch.git
   ```

2. Скопировать модуль в вашу конфигурацию NixOS:
   ```bash
   sudo cp -r NixOS-Meowrch/modules/meowrch-hyprland /etc/nixos/modules/
   ```

3. Добавить импорт модуля в ваш `home.nix`:
   ```nix
   imports = [
     ./modules/meowrch-hyprland/home.nix
     # другие импорты...
   ];
   
   modules.meowrch-hyprland = {
     enable = true;
   };
   ```

4. Включить Hyprland в `configuration.nix`:
   ```nix
   programs.hyprland = {
     enable = true;
     xwayland.enable = true;
   };
   
   xdg.portal = {
     enable = true;
     extraPortals = with pkgs; [
       xdg-desktop-portal-hyprland
       xdg-desktop-portal-gtk
     ];
   };
   ```

5. Перестроить систему:
   ```bash
   sudo nixos-rebuild switch
   ```

## Компоненты конфигурации

- **Hyprland**: Современный тайловый менеджер окон для Wayland
- **Waybar**: Настроенная панель с красивыми виджетами
- **Rofi**: Стильный лаунчер приложений
- **Dunst**: Система уведомлений
- **Swaylock**: Экран блокировки с эффектами
- **Swww**: Менеджер обоев

## Дополнительные компоненты

В репозитории также есть:
- **Zen Browser** (последняя версия, билдится автоматически)
- **Yandex Music** (последняя версия, билдится автоматически)
- **Catppuccin тема для Spotify** (тема mocha)
- **Zed Editor** (версия 0.184.0)

## Настройка после установки

После первого входа в Hyprland выполните:
```bash
python ~/.config/meowrch/meowrch.py --action select-theme
```
для выбора темы оформления.

### Горячие клавиши

- `SUPER + Enter` - Открыть терминал
- `SUPER + Q` - Закрыть окно
- `SUPER + Space` - Открыть лаунчер
- `SUPER + Shift + R` - Перезапустить Hyprland
- `SUPER + 1-9` - Переключение между рабочими столами
- `SUPER + Shift + 1-9` - Переместить окно на рабочий стол
- `SUPER + F` - Полноэкранный режим
- `SUPER + V` - Плавающий режим

## Возможные проблемы

Если скрипты панели не работают:
```bash
# Проверить наличие кэш-директории
mkdir -p ~/.cache/meowrch

# Перезапустить XDG порталы
~/.config/hypr/resetxdgportal.sh
```

## Благодарности

Этот модуль основан на конфигурации [Meowrch](https://github.com/DIMFLIX-OFFICIAL/Meowrch) от DIMFLIX.
