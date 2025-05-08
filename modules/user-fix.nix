{ config, lib, pkgs, ... }:

{
  # Define user group properly to fix ownership issues
  users.groups.redm00us = { };
  
  # Ensure the user exists with proper configuration
  users.users.redm00us = {
    isNormalUser = true;
    description = "Redm00us";
    extraGroups = [
      "networkmanager"
      "wheel"
      "lp"
      "bluetooth"
      "libvirtd"
      "users"
      "audio"
      "video"
      "cloudflare-warp"
    ];
    group = "redm00us";
  };
}