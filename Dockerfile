FROM kasmweb/kali-rolling-desktop:1.19.0-rolling-weekly

USER root

# Install system tools, build dependencies, and system-level Python packages
RUN apt-get update && apt-get install -y \
    iputils-ping \
    iproute2 \
    net-tools \
    dnsutils \
    curl \
    wget \
    unzip \
    nmap \
    tmux \
    fzf \
    zsh \
    gawk \
    python3-pip \
    python3-dev \
    python3-unicorn \
    python3-impacket \
    python3-scapy \
    python3-xmltodict \
    build-essential \
    cmake \
    pkg-config \
    libffi-dev \
    git \
    vim \
    netcat-openbsd \
    wordlists \
    gobuster \
    hashcat \
    wfuzz \
    recon-ng \
    whois \
    traceroute \
    exploitdb \
    ffuf \
    amass \
    evil-winrm \
    netexec \
    && rm -rf /var/lib/apt/lists/*

# SecLists
RUN git clone --depth 1 https://github.com/danielmiessler/SecLists /usr/share/seclists

# Nuclei
RUN NUCLEI_VERSION=$(curl -s https://api.github.com/repos/projectdiscovery/nuclei/releases/latest | grep '"tag_name"' | cut -d'"' -f4) \
    && curl -sSL "https://github.com/projectdiscovery/nuclei/releases/download/${NUCLEI_VERSION}/nuclei_${NUCLEI_VERSION#v}_linux_amd64.zip" -o nuclei.zip \
    && unzip nuclei.zip -d /usr/local/bin/ \
    && rm nuclei.zip \
    && chmod +x /usr/local/bin/nuclei

# Oh-My-Zsh
RUN git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git /home/kasm-default-profile/.oh-my-zsh \
    && cp /home/kasm-default-profile/.oh-my-zsh/templates/zshrc.zsh-template /home/kasm-default-profile/.zshrc \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME=""/' /home/kasm-default-profile/.zshrc \
    && sed -i '1i ZSH_DISABLE_COMPFIX="true"' /home/kasm-default-profile/.zshrc

# Zsh autosuggestions
RUN git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
    /home/kasm-default-profile/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' \
    /home/kasm-default-profile/.zshrc

# Zsh configuration
RUN cat >> /home/kasm-default-profile/.zshrc << 'EOF'
alias ll="ls -la"
alias ports="ss -tulpn"
alias myip="curl -s ifconfig.me"
alias cls=clear
alias grep="grep --color=auto"
export HISTSIZE=10000
export HISTFILE=~/.zsh_history
export SAVEHIST=10000
setopt HIST_IGNORE_DUPS
PROMPT='%F{blue}┌──(%F{red}%n㉿%m%F{blue})-[%F{white}%~%F{blue}]
└─%F{red}%#%f '
EOF

# Vim
RUN printf 'set number\nsyntax on\nset tabstop=4\nset autoindent\nset mouse=a\n' \
    > /home/kasm-default-profile/.vimrc

# Wallpaper
COPY wallpaper.jpg /home/kasm-default-profile/Downloads/wallpaper.jpg

# Remove Root Terminal Emulator from panel
RUN rm /home/kasm-default-profile/.config/xfce4/panel/launcher-7/17389582524.desktop

# Fix Zsh permissions
RUN chown -R root:root /usr/share/zsh /usr/local/share/zsh \
    && chmod -R 755 /usr/share/zsh /usr/local/share/zsh \
    && chmod -R go-w /usr/share/zsh /usr/local/share/zsh

# Force Zsh for interactive terminals
RUN echo '[ -t 1 ] && [ -z "$ZSH_VERSION" ] && exec /usr/bin/zsh -l' \
    >> /etc/bash.bashrc

# Python penetration testing tools
RUN PIP_BREAK_SYSTEM_PACKAGES=1 pip3 install --ignore-installed --no-build-isolation \
    pwntools \
    bbot