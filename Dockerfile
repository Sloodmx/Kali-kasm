FROM kasmweb/kali-rolling-desktop:1.19.0-rolling-weekly

USER root

# Install system tools, build dependencies, and system-level python packages
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

# Clone SecLists repository
RUN git clone --depth 1 https://github.com/danielmiessler/SecLists /usr/share/seclists

# Install RustScan
RUN curl -sSL https://github.com/RustScan/RustScan/releases/download/2.3.0/rustscan_2.3.0_amd64.deb -o rustscan.deb \
    && dpkg -i rustscan.deb \
    && rm rustscan.deb

# Install Nuclei
RUN curl -sSL https://github.com/projectdiscovery/nuclei/releases/download/v3.3.8/nuclei_3.3.8_linux_amd64.zip -o nuclei.zip \
    && unzip nuclei.zip -d /usr/local/bin/ \
    && rm nuclei.zip \
    && chmod +x /usr/local/bin/nuclei

# Setup Oh-My-Zsh dans kasm-default-profile (Kasm copie ce dir dans $HOME au démarrage)
RUN git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git /home/kasm-default-profile/.oh-my-zsh \
    && cp /home/kasm-default-profile/.oh-my-zsh/templates/zshrc.zsh-template /home/kasm-default-profile/.zshrc \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="robbyrussell"/' /home/kasm-default-profile/.zshrc \
    && sed -i '1i ZSH_DISABLE_COMPFIX="true"' /home/kasm-default-profile/.zshrc

# Install zsh-autosuggestions
RUN git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /home/kasm-default-profile/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' /home/kasm-default-profile/.zshrc

# Configure aliases et settings
RUN printf '\
alias ll="ls -la"\n\
alias ports="ss -tulpn"\n\
alias myip="curl -s ifconfig.me"\n\
alias cls=clear\n\
alias grep="grep --color=auto"\n\
export HISTSIZE=10000\n\
export HISTFILE=~/.zsh_history\n\
export SAVEHIST=10000\n\
setopt HIST_IGNORE_DUPS\n\
' >> /home/kasm-default-profile/.zshrc

# Configure Vim
RUN printf 'set number\nsyntax on\nset tabstop=4\nset autoindent\nset mouse=a\n' > /home/kasm-default-profile/.vimrc

# Fix zsh permissions
RUN chown -R root:root /usr/share/zsh /usr/local/share/zsh \
    && chmod -R 755 /usr/share/zsh /usr/local/share/zsh \
    && chmod -R go-w /usr/share/zsh /usr/local/share/zsh

# Force zsh globalement pour les terminaux interactifs
RUN echo '[ -t 1 ] && [ -z "$ZSH_VERSION" ] && exec /usr/bin/zsh -l' >> /etc/bash.bashrc

# Install Python penetration testing tools
RUN PIP_BREAK_SYSTEM_PACKAGES=1 pip3 install --ignore-installed --no-build-isolation \
    pwntools \
    bbot

# Permissions finales
RUN chown -R 1000:1000 /home/kasm-default-profile/

USER root