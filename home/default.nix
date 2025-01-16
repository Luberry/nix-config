{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  programs = {
    home-manager.enable = true;
    git.enable = true;
    zsh.oh-my-zsh.custom = "${config.home.homeDirectory}/.oh-my-zsh-custom";
    waybar = {
      enable = true;
    };

  };
  xresources = {
    path = null;
    properties = null;
  };
  xdg.configFile = {
    "nvim/init.vim" = {
      enable = true;
      source = ./dotfiles/init.vim;
    };
    "sway/wallpaper.jpg" = {
      enable = true;
      source = ./sway/wallpaper.jpg;
    };
    "touchegg/touchegg.conf" = {
      enable = true;
      source = ./dotfiles/touchegg.conf;
    };
    "ulauncher/extensions.json" = {
      enable = true;
      source = ./dotfiles/ulauncher/extensions.json;
    };
    "ulauncher/settings.json" = {
      enable = true;
      source = ./dotfiles/ulauncher/settings.json;
    };
    "ulauncher/shortcuts.json" = {
      enable = true;
      source = ./dotfiles/ulauncher/shortcuts.json;
    };
    "ulauncher/ext_preferences/com.github.rdnetto.ulauncher-sway.db" = {
      enable = true;
      source = ./dotfiles/ulauncher/ext_preferences/com.github.rdnetto.ulauncher-sway.db;
    };
  };
  home = {
    username = "dkozicki";
    stateVersion = "24.11";
    homeDirectory =
      if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";
    sessionVariables = {
      EDITOR = "nvim";
    };
    file = {
      ".Xresources" = {
        source = ./sway/Xresources;
      };
      ".zshrc" = {
        source = ./dotfiles/zsh/.zshrc;
      };
      ".oh-my-zsh-custom/themes/agnoster-newline.zsh-theme" = {
        source = ./dotfiles/zsh/agnoster-newline.zsh-theme;
      };
      ".local/bin/teamsfix" = {
        source = ./dotfiles/teamsfix;
      };
    };
  };
  fonts = {
    fontconfig.enable = true;
  };

  wayland.windowManager.sway = {
    enable = true;
    config = null;
    extraConfig = lib.fileContents ./sway/config;
    package = null;
  };
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
  services = {
    udiskie = {
      enable = true;
      tray = "always";
      notify = true;
      automount = true;
    };
    devilspie2 = {
      enable = true;
      config = '''';
    };
    caffeine.enable = true;
    dunst = {
      enable = true;
      settings = {
        global = {
          follow = "mouse";
          geometry = "300x60-20+48";
          indicate_hidden = "yes";
          shrink = "no";
          separator_height = 0;
          padding = 32;
          horizontal_padding = 32;
          frame_width = 2;
          sort = "no";
          idle_threshold = 120;
          font = "Droid Sans Mono Dotted 8";
          line_height = 4;
          markup = "full";
          format = ''%s\n%b'';
          alignment = "left";
          show_age_threshold = 60;
          word_wrap = "yes";
          ignore_newline = "no";
          stack_duplicates = false;
          hide_duplicate_count = "yes";
          show_indicators = "no";
          icon_position = "off";
          sticky_history = "yes";
          history_length = 20;
          browser = "/run/current-system/sw/bin/firefox -new-tab";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";

        };
        shortcuts = {
          close = "ctrl+space";
          close_all = "ctrl+shift+space";
          history = "ctrl+grave";
          context = "ctrl+shift+period";
        };
        urgency_low = {
          timeout = 4;
          background = "#141c21";
          foreground = "#93a1a1";
          frame_color = "#8bc34a";
        };
        urgency_normal = {
          timeout = 8;
          background = "#141c21";
          foreground = "#93a1a1";
          frame_color = "#ba68c8";
        };
        urgency_critical = {
          timeout = 0;
          background = "#141c21";
          foreground = "#93a1a1";
          frame_color = "#ff7043";
        };
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };
}
