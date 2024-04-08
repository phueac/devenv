FROM ubuntu:22.04 as base

FROM base as build
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git 

FROM build as neovim
RUN apt-get install -y ninja-build gettext cmake unzip
RUN git clone --depth 1 --branch v0.9.5 https://github.com/neovim/neovim.git
RUN cd neovim && make CMAKE_BUILD_TYPE=Release && make install

FROM base as final

COPY --from=neovim /usr/local/bin /usr/local/bin
COPY --from=neovim /usr/local/lib /usr/local/include
COPY --from=neovim /usr/local/share /usr/local/share

RUN apt-get update && apt-get install -y \
  git \
  python3.11 \
  python3.11-venv \ 
&& rm -rf /var/lib/apt/lists/*
COPY dotfiles .

ENTRYPOINT bash
