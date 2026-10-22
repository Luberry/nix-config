# Shell, editor and git setup shared by every machine, desktop or not.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs = {
    git = {
      enable = true;
      settings.user.name = "Dylan Kozicki";
      settings.user.email = "dylan.kozicki@gmail.com";
    };
    zsh.oh-my-zsh.custom = "${config.home.homeDirectory}/.oh-my-zsh-custom";
  };
  xdg.configFile."nvim/init.vim" = {
    enable = true;
    source = ./dotfiles/init.vim;
  };
  home = {
    sessionVariables.EDITOR = "nvim";
    file = {
      ".zshrc".source = ./dotfiles/zsh/.zshrc;
      ".oh-my-zsh-custom/themes/agnoster-newline.zsh-theme".source =
        ./dotfiles/zsh/agnoster-newline.zsh-theme;
    };
  };
}
