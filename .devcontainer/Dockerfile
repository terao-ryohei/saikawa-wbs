FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    build-essential \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libpq-dev \
    libsqlite3-dev \
    libyaml-dev \
    libffi-dev \
    libgdbm-dev \
    libncurses5-dev \
    libgmp-dev \
    pkg-config \
    autoconf \
    bison \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install rbenv and ruby-build
ENV RBENV_ROOT=/usr/local/rbenv
ENV PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"

RUN git clone https://github.com/rbenv/rbenv.git $RBENV_ROOT \
    && git clone https://github.com/rbenv/ruby-build.git $RBENV_ROOT/plugins/ruby-build \
    && echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

# Install Ruby 3.2.5 and 3.3.10 (for GDK)
RUN rbenv install 3.2.5 \
    && rbenv install 3.3.10 \
    && rbenv global 3.3.10 \
    && rbenv rehash

# Install bundler
RUN gem install bundler \
    && RBENV_VERSION=3.2.5 gem install bundler

# Install PostgreSQL 17 and 18 (full install for initdb)
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/postgresql-keyring.gpg] https://apt.postgresql.org/pub/repos/apt jammy-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y postgresql-17 postgresql-18 \
    && rm -rf /var/lib/apt/lists/*

# Install Redis 8.x (server and tools)
RUN curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb jammy main" > /etc/apt/sources.list.d/redis.list \
    && apt-get update \
    && apt-get install -y redis-server redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Install GDK dependencies
RUN apt-get update && apt-get install -y \
    exiftool \
    graphicsmagick \
    meson \
    ninja-build \
    runit \
    cmake \
    libicu-dev \
    libkrb5-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.24.5 directly (without mise for simpler permissions)
ENV GO_VERSION=1.24.5
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH="$GOPATH/bin:$GOROOT/bin:$PATH"
RUN ARCH=$(dpkg --print-architecture) \
    && if [ "$ARCH" = "amd64" ]; then GO_ARCH="amd64"; else GO_ARCH="arm64"; fi \
    && curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz | tar -C /usr/local -xzf - \
    && mkdir -p $GOPATH/bin \
    && chmod -R 777 $GOPATH

# Install Node.js 22.x (for Rails asset pipeline)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN npm install -g yarn

# Create non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Set permissions for shared tools
RUN chown -R $USERNAME:$USERNAME $RBENV_ROOT \
    && chown -R $USERNAME:$USERNAME $GOPATH

# Add vscode user to postgres group and set PostgreSQL permissions
RUN usermod -aG postgres $USERNAME \
    && mkdir -p /var/run/postgresql \
    && chown -R postgres:postgres /var/run/postgresql \
    && chmod 2775 /var/run/postgresql \
    && usermod -aG $USERNAME postgres

# Add PostgreSQL binaries to PATH
ENV PATH="/usr/lib/postgresql/18/bin:/usr/lib/postgresql/17/bin:$PATH"

# Setup git-prompt for bash
RUN curl -o /etc/bash_git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

USER $USERNAME

# Setup .bashrc with git prompt
RUN echo '\n\
# Git prompt settings\n\
source /etc/bash_git-prompt.sh\n\
GIT_PS1_SHOWDIRTYSTATE=true\n\
GIT_PS1_SHOWUNTRACKEDFILES=true\n\
GIT_PS1_SHOWSTASHSTATE=true\n\
GIT_PS1_SHOWUPSTREAM=auto\n\
\n\
# Prompt with git status\n\
PS1='"'"'\[\033[32m\]\u@\h\[\033[0m\]: \[\033[36m\]\w\[\033[0m\] \[\033[31m\]$(__git_ps1 "(%s)")\[\033[0m\]\n\$ '"'"'\n\
\n\
# Aliases\n\
alias la="ls -aF --color=auto"\n\
alias ls="ls -F --color=auto"\n\
alias ll="ls -alF --color=auto"\n\
' >> /home/$USERNAME/.bashrc

WORKDIR /workspace
