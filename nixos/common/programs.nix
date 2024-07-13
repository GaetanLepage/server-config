{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    dua
    git
    btop
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
