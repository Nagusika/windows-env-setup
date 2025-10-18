# Font configuration for WSL Ubuntu
# This file configures default fonts for terminals

# Configuration for bash
if [ -f ~/.bashrc ]; then
    echo 'export TERM=xterm-256color' >> ~/.bashrc
    echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
fi

# Configuration for zsh (if installed)
if [ -f ~/.zshrc ]; then
    echo 'export TERM=xterm-256color' >> ~/.zshrc
    echo 'export LANG=en_US.UTF-8' >> ~/.zshrc
fi

# Configuration for vim
if [ -f ~/.vimrc ]; then
    echo 'set guifont=Cascadia\ Code\ Nerd\ Font:h12' >> ~/.vimrc
fi

# Configuration for neovim
if [ -d ~/.config/nvim ]; then
    mkdir -p ~/.config/nvim
    echo 'vim.opt.guifont = "Cascadia Code Nerd Font:h12"' > ~/.config/nvim/init.lua
fi

echo "WSL font configuration completed"
