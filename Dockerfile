FROM kasmweb/kali-rolling-desktop:1.19.0-rolling-weekly

USER root

# Install tools
RUN apt-get update && apt-get install -y \
    iputils-ping \
    iproute2 \
    net-tools \
    dnsutils \
    curl \
    wget \
    nmap \
    tmux \
    fzf \
    zsh \
    gawk \
    python3-pip \
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
    crackmapexec \
    && rm -rf /var/lib/apt/lists/*

# SecLists
RUN git clone --depth 1 https://github.com/danielmiessler/SecLists /usr/share/seclists

# RustScan
RUN curl -LO https://github.com/RustScan/rustscan/releases/latest/download/rustscan_2.3.0_amd64.deb \
    && dpkg -i rustscan_2.3.0_amd64.deb \
    && rm rustscan_2.3.0_amd64.deb

# Nuclei
RUN curl -LO https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei_linux_amd64.zip \
    && unzip nuclei_linux_amd64.zip -d /usr/local/bin/ \
    && rm nuclei_linux_amd64.zip \
    && chmod +x /usr/local/bin/nuclei

# Setup user 1000 home
ENV HOME=/home/kasm-user
ENV USER_HOME=/home/kasm-user

# Oh-My-Zsh pour user 1000
RUN git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git /home/kasm-user/.oh-my-zsh \
    && cp /home/kasm-user/.oh-my-zsh/templates/zshrc.zsh-template /home/kasm-user/.zshrc \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /home/kasm-user/.zshrc

# Oh-My-Zsh pour root aussi
RUN git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh \
    && cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /root/.zshrc

# zsh-autosuggestions pour les deux users
RUN git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /home/kasm-user/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' /home/kasm-user/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' /root/.zshrc

# Aliases + config pour les deux users
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

# Vim config pour les deux users
RUN printf 'set number\nsyntax on\nset tabstop=4\nset autoindent\nset mouse=a\n' > /home/kasm-user/.vimrc \
    && printf 'set number\nsyntax on\nset tabstop=4\nset autoindent\nset mouse=a\n' > /root/.vimrc

# Fix zsh compinit warning
RUN chmod 755 /usr/local/share/zsh/site-functions 2>/dev/null || true \
    && chmod 755 /usr/share/zsh/vendor-completions 2>/dev/null || true

# Shell par défaut
RUN chsh -s /usr/bin/zsh root \
    && chsh -s /usr/bin/zsh kasm-user 2>/dev/null || true

# Fix permissions home kasm-user
RUN chown -R 1000:1000 /home/kasm-user/

# Python tools
RUN pip3 install --break-system-packages \
    impacket \
    scapy \
    pwntools \
    bbot

USER 1000