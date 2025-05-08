{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.python-environment;
  
  # Python with packages for system scripts
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

in {
  options.modules.python-environment = {
    enable = mkEnableOption "Python environment for system scripts";
    
    installGlobally = mkOption {
      type = types.bool;
      default = true;
      description = "Install Python globally in the system path";
    };
  };

  config = mkIf cfg.enable {
    # Добавление Python в системные пакеты
    environment.systemPackages = with pkgs; [
      pythonWithPackages
    ];
    
    # Добавление Python в пользовательские пакеты через Home Manager
    home-manager.users.redm00us = mkIf config.home-manager.enable {
      home.packages = [
        pythonWithPackages
      ];
    };
    
    # Создание символьной ссылки для Python
    system.userActivationScripts = mkIf cfg.installGlobally {
      pythonSetup = {
        text = ''
          # Создаем директорию для скриптов, если её нет
          mkdir -p $HOME/.local/bin
          
          # Создаем кеш-директорию для Meowrch скриптов
          mkdir -p $HOME/.cache/meowrch
          
          echo "Python environment setup complete"
        '';
      };
    };
  };
}