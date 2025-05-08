# Meowrch Hyprland для NixOS

Это модуль для NixOS Home Manager, который обеспечивает интеграцию конфигурации Meowrch Hyprland с системой NixOS.

## Структура модуля

```
meowrch-hyprland/
├── home.nix               # Основной файл модуля Home Manager
├── meowrch/               # Копия необходимых файлов из оригинальной конфигурации Meowrch
│   └── home/
│       ├── .config/       # Конфигурационные файлы
│       │   ├── hypr/      # Конфигурация Hyprland
│       │   ├── waybar/    # Конфигурация панели Waybar
│       │   ├── dunst/     # Конфигурация системы уведомлений
│       │   ├── rofi/      # Конфигурация лаунчера Rofi
│       │   └── meowrch/   # Утилита управления темами Meowrch
│       └── bin/           # Скрипты для панели и других компонентов
└── README.md              # Данный файл
```

## Использование модуля

1. Импортируйте модуль в вашем файле `home.nix`:

```nix
imports = [
  ./path/to/modules/meowrch-hyprland/home.nix
];
```

2. Включите модуль:

```nix
modules.meowrch-hyprland = {
  enable = true;
};
```

## Особенности модуля

- Данный модуль уже содержит все необходимые конфигурационные файлы, скрипты и зависимости для работы Meowrch Hyprland в NixOS.
- Модуль автоматически устанавливает все необходимые пакеты, включая Python модули для скриптов waybar.
- Конфигурация уже адаптирована для работы в NixOS без дополнительных модификаций.

## Устанавливаемые пакеты и зависимости

- **Оконный менеджер**: Hyprland
- **Панель**: Waybar
- **Уведомления**: Dunst
- **Лаунчер**: Rofi Wayland
- **Блокировка экрана**: Swaylock Effects, Hypridle
- **Утилиты Wayland**: grim, slurp, wl-clipboard, cliphist
- **Управление медиа**: playerctl, pamixer
- **Другие утилиты**: brightnessctl, swww
- **Python пакеты**: psutil, pillow, pyamdgpuinfo, gputil, requests, pyyaml, configparser и другие

## Настройка после установки

После включения модуля и перезагрузки системы:

1. Выберите Hyprland в меню входа в систему (SDDM или другой DM)
2. Для выбора темы используйте:
```bash
python ~/.config/meowrch/meowrch.py --action select-theme
```

3. Настройте положение мониторов в файле `~/.config/hypr/monitors.conf`

## Устранение неполадок

- Если скрипты не работают, проверьте, что они имеют права на выполнение
- Для перезапуска XDG порталов используйте: `~/.config/hypr/resetxdgportal.sh`
- Проверьте наличие кэш-директории: `~/.cache/meowrch`

## Благодарности

Этот модуль является адаптацией конфигурации [Meowrch](https://github.com/DIMFLIX-OFFICIAL/Meowrch) для NixOS.