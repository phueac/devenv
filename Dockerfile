FROM ubuntu:22.04 as base

FROM base as build
RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  git \
  unzip \
  wget

FROM build as neovim
RUN apt-get install -y ninja-build gettext cmake unzip
RUN git clone --depth 1 --branch v0.9.5 https://github.com/neovim/neovim.git
RUN cd neovim && make CMAKE_BUILD_TYPE=Release && make install

# Prebuilt treesitter parsers to potentially save image build time/space
# FROM build as treesitter
# RUN wget https://github.com/anasrar/nvim-treesitter-parser-bin/releases/download/linux/all.zip
# RUN unzip -j all.zip python.so lua.so

FROM base as final

COPY --from=neovim /usr/local/bin /usr/local/bin
COPY --from=neovim /usr/local/lib /usr/local/include
COPY --from=neovim /usr/local/share /usr/local/share

RUN apt-get update && apt-get install -y \
  build-essential \
  git \
  python3.11 \
  python3.11-venv \ 
&& rm -rf /var/lib/apt/lists/*
RUN useradd -ms /bin/bash dave
USER dave
WORKDIR /home/dave
COPY nvim/ /home/dave/.config/nvim
RUN nvim --headless "+Lazy! sync" +qa

ENTRYPOINT bash
