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

# Environment variables for user 1000 home directory
ENV HOME=/home/kasm-user
ENV USER_HOME=/home/kasm-user

# Setup Oh-My-Zsh for kasm-user
RUN git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git /home/kasm-user/.oh-my-zsh \
    && cp /home/kasm-user/.oh-my-zsh/templates/zshrc.zsh-template /home/kasm-user/.zshrc \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /home/kasm-user/.zshrc

# Setup Oh-My-Zsh for root
RUN git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh \
    && cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /root/.zshrc

# Install zsh-autosuggestions plugin for both users
RUN git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /home/kasm-user/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' /home/kasm-user/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' /root/.zshrc

# Fix compinit - use a real temp file, not /dev/null
RUN sed -i '1s|^|ZSH_COMPDUMP=$(mktemp)\n|' /home/kasm-user/.zshrc \
    && sed -i '1s|^|ZSH_COMPDUMP=$(mktemp)\n|' /root/.zshrc \
    && printf '\nautoload -Uz compinit 2>/dev/null\ncompinit -u 2>/dev/null\n' >> /home/kasm-user/.zshrc \
    && printf '\nautoload -Uz compinit 2>/dev/null\ncompinit -u 2>/dev/null\n' >> /root/.zshrc

# Configure shell aliases and settings for both users
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
' >> /home/kasm-user/.zshrc \
    && printf '\
alias ll="ls -la"\n\
alias ports="ss -tulpn"\n\
alias myip="curl -s ifconfig.me"\n\
alias cls=clear\n\
alias grep="grep --color=auto"\n\
export HISTSIZE=10000\n\
export HISTFILE=~/.zsh_history\n\
export SAVEHIST=10000\n\
setopt HIST_IGNORE_DUPS\n\
' >> /root/.zshrc

# Configure Vim for both users
RUN printf 'set number\nsyntax on\nset tabstop=4\nset autoindent\nset mouse=a\n' > /home/kasm-user/.vimrc \
    && printf 'set number\nsyntax on\nset tabstop=4\nset autoindent\nset mouse=a\n' > /root/.vimrc

# Change default shell to zsh for root and kasm-user
RUN chsh -s /usr/bin/zsh root \
    && chsh -s /usr/bin/zsh kasm-user 2>/dev/null || true

# Install Python penetration testing tools bypassing APT conflicts
RUN PIP_BREAK_SYSTEM_PACKAGES=1 pip3 install --ignore-installed --no-build-isolation \
    pwntools \
    bbot

# Sync user profile to /etc/skel AFTER all configs are generated
RUN cp -r /home/kasm-user/. /etc/skel/

# Set final directory permissions for kasm-user (UID 1000)
RUN chown -R 1000:1000 /home/kasm-user/ /etc/skel/

USER root