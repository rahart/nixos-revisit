{ config, pkgs, dotfiles ? null, ... }:

{
  home.username = "hex";
  home.homeDirectory = "/home/hex";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "hex";
    userEmail = "hex@dottrav.com";
  };

  # Zsh with autosuggestions & syntax highlighting (correct option names)
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
  };

  home.packages = with pkgs; [
    neovim tmux ripgrep fd gcc gnumake unzip wl-clipboard
  ];

  xdg.configFile."hypr/hyprland.conf".text = ''
    monitor=,preferred,auto,1
    input {
      follow_mouse=0
      touchpad {
        natural_scroll=false
      }
    }
    general {
      gaps_in=6
      gaps_out=12
      border_size=2
      col.active_border=0xFF8bd5ca
      col.inactive_border=0xFF3a3a3a
    }
    animations {
      enabled=true
      animation=windows,1,3,default
      animation=workspaces,1,3,default
    }
    misc {
      disable_hyprland_logo=true
      mouse_move_enables_dpms=false
    }
    # Basic keybinds
    $mod = SUPER
    bind=$mod,Return,exec,alacritty
    bind=$mod,Q,killactive,
    bind=$mod,E,exec,thunar
    bind=$mod,F,fullscreen,0
    bind=$mod,Space,exec,rofi -show drun
    bind=$mod,1,workspace,1
    bind=$mod,2,workspace,2
    bind=$mod,3,workspace,3
    bind=$mod,4,workspace,4
  '';

  xdg.configFile."nvim".source = dotfiles + "/nvim";
  xdg.configFile."tmux/tmux.conf".source = dotfiles + "/tmux/tmux.conf";
}
