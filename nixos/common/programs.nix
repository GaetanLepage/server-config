{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    dua
    git
    htop
    speedtest-go
    tmux
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
}
