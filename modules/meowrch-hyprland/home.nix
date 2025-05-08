{ config, lib, pkgs, hyprland, ... }:

with lib;

let
  cfg = config.modules.meowrch-hyprland;
  
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
  
in {
  options.modules.meowrch-hyprland = {
    enable = mkEnableOption "Meowrch Hyprland Home Configuration";
    
    configDir = mkOption {
      type = types.str;
      default = "${./meowrch/home/.config}";
      description = "Путь к директории конфигурации Meowrch";
    };
  };

  config = mkIf cfg.enable {
    # Поддержка Hyprland для Home Manager
    wayland.windowManager.hyprland = {
      enable = true;
      package = null; # Используем пакет из системной конфигурации
      xwayland.enable = true;
      systemd.enable = true;
      
      # Оптимизации
      settings = {
        # Это базовый миниальный конфиг, основная конфигурация будет в файлах
        monitor = ",preferred,auto,1";
        env = [
          "XCURSOR_SIZE,24"
          "QT_QPA_PLATFORM,wayland"
          "MOZ_ENABLE_WAYLAND,1"
        ];
        exec-once = [
          "waybar"
          "dunst"
          "swww init"
        ];
      };
    };
    
    # Waybar - панель
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        mainBar = builtins.fromJSON (builtins.readFile "${./meowrch/home/.config}/waybar/config.jsonc");
      };
      style = builtins.readFile "${./meowrch/home/.config}/waybar/style.css";
    };
    
    # Dunst - уведомления
    services.dunst = {
      enable = true;
      settings = {
        global = {
          width = 300;
          height = 300;
          offset = "30x50";
          origin = "top-right";
          transparency = 10;
          frame_color = "${colors.blue}";
          frame_width = 2;
          corner_radius = 10;
          timeout = 10;
        };
        
        urgency_normal = {
          background = "${colors.base}";
          foreground = "${colors.text}";
          frame_color = "${colors.blue}";
        };
        
        urgency_critical = {
          background = "${colors.base}";
          foreground = "${colors.text}";
          frame_color = "${colors.red}";
        };
      };
    };
    
    # Rofi - лаунчер
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      terminal = "${pkgs.kitty}/bin/kitty";
      theme = "catppuccin-mocha";
    };
    
    # Swaylock - блокировка экрана
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        color = "${colors.base}";
        font-size = 24;
        indicator-idle-visible = true;
        indicator-radius = 100;
        line-color = "${colors.blue}";
        show-failed-attempts = true;
      };
    };
    
    # Hypridle - автоблокировка экрана
    xdg.configFile."hypr/hypridle.conf".source = "${./meowrch/home/.config}/hypr/hypridle.conf";
    
    # Создаем кэш директорию для meowrch и копируем скрипты
    home.file.".cache/meowrch/.keep" = {
      text = "";
    };
    
    # Копируем скрипты из bin
    home.file = {
      "bin/system-info.py" = {
        source = ./meowrch/home/bin/system-info.py;
        executable = true;
      };
      "bin/battery.sh" = {
        source = ./meowrch/home/bin/battery.sh;
        executable = true;
      };
      "bin/brightness.sh" = {
        source = ./meowrch/home/bin/brightness.sh;
        executable = true;
      };
      "bin/volume.sh" = {
        source = ./meowrch/home/bin/volume.sh;
        executable = true;
      };
      "bin/do-not-disturb.sh" = {
        source = ./meowrch/home/bin/do-not-disturb.sh;
        executable = true;
      };
      "bin/system-update.sh" = {
        source = ./meowrch/home/bin/system-update.sh;
        executable = true;
      };
      "bin/polkitkdeauth.sh" = {
        source = ./meowrch/home/bin/polkitkdeauth.sh;
        executable = true;
      };
      "bin/rofi-menus" = {
        source = ./meowrch/home/bin/rofi-menus;
        recursive = true;
      };
    };
    
    # Копируем конфигурационные файлы Hyprland
    xdg.configFile = {
      # Hyprland и подключаемые файлы
      "hypr/hyprland.conf".source = "${./meowrch/home/.config}/hypr/hyprland.conf";
      "hypr/animations.conf".source = "${./meowrch/home/.config}/hypr/animations.conf";
      "hypr/keybindings.conf".source = "${./meowrch/home/.config}/hypr/keybindings.conf";
      "hypr/windowrules.conf".source = "${./meowrch/home/.config}/hypr/windowrules.conf";
      "hypr/theme.conf".source = "${./meowrch/home/.config}/hypr/theme.conf";
      "hypr/monitors.conf".source = "${./meowrch/home/.config}/hypr/monitors.conf";
      "hypr/custom-prefs.conf".source = "${./meowrch/home/.config}/hypr/custom-prefs.conf";
      
      # Скрипты для waybar и других компонентов
      "rofi".source = "${./meowrch/home/.config}/rofi";
      "dunst".source = "${./meowrch/home/.config}/dunst";
      "swww".source = "${./meowrch/home/.config}/swww";
      "meowrch".source = "${./meowrch/home/.config}/meowrch";
      
      # Скрипт для перезапуска XDG порталов
      "hypr/resetxdgportal.sh" = {
        text = ''
          #!/usr/bin/env bash
          
          sleep 1
          killall xdg-desktop-portal-hyprland
          killall xdg-desktop-portal-gnome
          killall xdg-desktop-portal-kde
          killall xdg-desktop-portal-wlr
          killall xdg-desktop-portal-gtk
          killall xdg-desktop-portal
          sleep 1
          
          # Use different directory on NixOS
          if [ -d /run/current-system/sw/libexec ]; then
              libDir=/run/current-system/sw/libexec
          else
              libDir=/usr/libexec
          fi
          
          $libDir/xdg-desktop-portal-hyprland &
          sleep 2
          $libDir/xdg-desktop-portal &
        '';
        executable = true;
      };
    };
    
    # Поддержка Python скриптов в бин директории
    home.packages = with pkgs; [
      # Python для скриптов
      (python311.withPackages (ps: with ps; [
        psutil
        pillow 
        pyamdgpuinfo 
        gputil 
        requests 
        pyyaml
        configparser
        inquirer
        loguru
        python-lsp-server
        pystray
        pypresence
        pyrofi
      ]))
      
      # Wayland утилиты
      grim
      slurp
      wl-clipboard
      cliphist
      
      # Воспроизведение медиа
      playerctl
      pamixer
      
      # Менеджеры и утилиты
      brightnessctl
      swww
      
      # Блокировка экрана и управление питанием
      hypridle
      
      # Интерфейс
      rofi-wayland
    ];
    
    # Переменные окружения для Wayland
    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
    };
  };
}