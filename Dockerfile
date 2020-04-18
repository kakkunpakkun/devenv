# syntax = docker/dockerfile:experimental
FROM ubuntu:18.04 as developer_env

COPY git-credential-github-token /usr/local/bin

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN \
  apt-get update -qq \
  && apt upgrade -y \
  && apt-get install -y --no-install-recommends \
  build-essential \
  default-libmysqlclient-dev \
  default-mysql-client \
  git \
  ca-certificates \
  openssl \
  less \
  vim \
  sudo \
  curl \
  wget \
  libssl-dev \
  libreadline-dev \
  tzdata \
  tmux \
  zip \
  unzip \
  fish \
  && adduser --disabled-password --gecos '' developer \
  && echo '%developer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && chmod +x /usr/local/bin/git-credential-github-token

USER developer
SHELL ["/bin/bash", "-c"]

# setup anyenv
RUN \
  git clone https://github.com/anyenv/anyenv ~/.anyenv \
  && export PATH="$HOME/.anyenv/bin:$PATH" \
  && yes | anyenv install --init \
  && echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.bashrc \
  && echo 'eval "$(anyenv init -)"' >> ~/.bashrc \
  && anyenv install rbenv \
  && anyenv install nodenv \
  && mkdir -p ~/.config/nodenv \
  && touch ~/.config/nodenv/default-packages

# setup git
RUN \
  git config --global url."https://github.com".insteadOf ssh://git@github.com \
  && git config --global --add url."https://github.com".insteadOf git://git@github.com \
  && git config --global --add url."https://github.com/".insteadOf git@github.com: \
  && git config --global credential.helper github-token \
  && mkdir /home/developer/src

# install deno
RUN \
  curl -fsSL https://deno.land/x/install/install.sh | sh \
  && export PATH="$HOME/.deno/bin:$PATH"

RUN \
  export PATH="$HOME/.anyenv/bin:$PATH" \
  && eval "$(anyenv init -)" \
  && rbenv install 2.7.1 \
  && nodenv install 12.16.2 \
  && rbenv global 2.7.1 \
  && gem install bundler

# install rust
RUN \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
  && export PATH="$HOME/.cargo/bin:$PATH" \
  && cargo install exa fd-find

ENV HOME /home/developer

WORKDIR ${HOME}

EXPOSE 3000
CMD ["fish"]