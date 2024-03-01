{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    dua
    git
    htop
    tmux
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
}
