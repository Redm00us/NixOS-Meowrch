{ config, lib, pkgs, hyprland, ... }:

with lib;

let
  cfg = config.modules.meowrch-hyprland;
  
  # Скрипты Python для Waybar и других компонентов
  pythonWithPackages = pkgs.python311.withPackages (ps: with ps; [
    psutil
    pillow 
    pyamdgpuinfo 
    gputil 
    requests 
    pyyaml
    configparser
    # Дополнительные библиотеки
    setuptools
    pip
  ]);

  # Цвета и тема
  colors = {
    base = "#1e1e2e";
    mantle = "#181825";
    crust = "#11111b";
    text = "#cdd6f4";
    
    # Catppuccin Mocha
    rosewater = "#f5e0dc";
    flamingo = "#f2cdcd";
    pink = "#f5c2e7";
    mauve = "#cba6f7";
    red = "#f38ba8";
    maroon = "#eba0ac";
    peach = "#fab387";
    yellow = "#f9e2af";
    green = "#a6e3a1";
    teal = "#94e2d5";
    sky = "#89dceb";
    sapphire = "#74c7ec";
    blue = "#89b4fa";
    lavender = "#b4befe";
  };
  
  # Скрипты бинарные
  installMeowrchBin = pkgs.writeShellScriptBin "install-meowrch-bin" ''
    #!/usr/bin/env bash
    
    # Копируем скрипты в bin директорию
    mkdir -p $HOME/bin
    cp -r ${../meowrch/home/bin}/* $HOME/bin/
    chmod +x $HOME/bin/*.sh
    chmod +x $HOME/bin/*.py
    
    # Создаем кеш-директорию для конфига system-info
    mkdir -p $HOME/.cache/meowrch
    
    echo "Установка бинарных файлов Meowrch завершена!"
  '';
  
  # Перезапуск XDG порталов
  resetXdgPortals = pkgs.writeShellScriptBin "reset-xdg-portals" ''
    #!/usr/bin/env bash
    
    # Переменные для вывода
    BLUE="\e[1;34m"
    GREEN="\e[1;32m"
    RED="\e[1;31m"
    YELLOW="\e[1;33m"
    RESET="\e[0m"
    
    echo -e "$BLUE[*] Перезапуск XDG порталов для Hyprland...$RESET"
    
    # Определение директории с бинарными файлами
    # NixOS использует другой путь для портальных сервисов
    if [ -d "/run/current-system/sw/libexec" ]; then
        libDir="/run/current-system/sw/libexec"
    else
        libDir="/usr/libexec"
    fi
    
    echo -e "$YELLOW[*] Завершение работы текущих порталов...$RESET"
    killall xdg-desktop-portal-hyprland 2>/dev/null
    killall xdg-desktop-portal-gnome 2>/dev/null
    killall xdg-desktop-portal-kde 2>/dev/null
    killall xdg-desktop-portal-wlr 2>/dev/null
    killall xdg-desktop-portal-gtk 2>/dev/null
    killall xdg-desktop-portal 2>/dev/null
    
    sleep 1
    
    echo -e "$YELLOW[*] Запуск XDG порталов...$RESET"
    
    $libDir/xdg-desktop-portal-hyprland &
    sleep 2
    $libDir/xdg-desktop-portal &
    sleep 2
    
    echo -e "$GREEN[✓] Завершено. XDG порталы должны работать корректно.$RESET"
  '';
  
in {
  options.modules.meowrch-hyprland = {
    enable = mkEnableOption "Meowrch Hyprland Configuration";
    
    theme = mkOption {
      type = types.str;
      default = "catppuccin-mocha";
      description = "Тема оформления (по умолчанию: catppuccin-mocha)";
    };
    
    installBinaries = mkOption {
      type = types.bool;
      default = true;
      description = "Установить бинарные скрипты из Meowrch";
    };
    
    installConfig = mkOption {
      type = types.bool;
      default = true;
      description = "Установить конфигурацию Hyprland из Meowrch";
    };
  };

  config = mkIf cfg.enable {
    # Установка Hyprland из flake
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = hyprland.packages.${pkgs.system}.hyprland;
    };
    
    # Графические библиотеки и зависимости
    hardware.graphics.enable = true;
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    
    # XDG-порталы для интеграции приложений
    xdg.portal = {
      enable = true;
      extraPortals = [
        hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = ["hyprland" "gtk"];
    };
    
    # Wayland-переменные окружения
    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
    };
    
    # Системные пакеты для Hyprland и Meowrch
    environment.systemPackages = with pkgs; [
      # Интерпретатор Python с пакетами
      pythonWithPackages
      
      # Базовые инструменты Wayland
      wayland
      xwayland
      wl-clipboard
      cliphist
      grim
      slurp
      
      # Оконный менеджер и компоненты
      pkgs.hyprpaper
      pkgs.hyprpicker
      
      # Утилиты и скрипты
      pamixer
      playerctl
      brightnessctl
      findutils
      coreutils
      gnome.zenity
      
      # Панель и меню
      waybar
      rofi-wayland
      
      # Скрипты Meowrch
      installMeowrchBin
      resetXdgPortals
      
      # Блокировка экрана
      swaylock-effects
      
      # Уведомления
      libnotify
      dunst
      
      # Графика и темы
      catppuccin-gtk
      papirus-icon-theme
      polkit-kde-agent
    ];
    
    # Звук через PipeWire
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    
    # Bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;
    
    # Display Manager
    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        theme = "catppuccin-mocha";
      };
      defaultSession = "hyprland";
    };
    
    # Установка пользовательских конфигураций
    system.userActivationScripts = mkIf cfg.installBinaries {
      meowrchBinaries = {
        text = ''
          if [ ! -d "$HOME/bin" ]; then
            ${installMeowrchBin}/bin/install-meowrch-bin
          else 
            echo "Найдена существующая директория bin. Для переустановки скриптов запустите install-meowrch-bin"
          fi
        '';
      };
    };
    
    # Активация бинарных скриптов в Fish
    programs.fish = {
      enable = mkDefault true;
      shellAliases = {
        resetxdg = "reset-xdg-portals";
      };
    };
  };
}