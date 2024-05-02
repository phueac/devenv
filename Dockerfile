FROM ubuntu:22.04 as base

FROM base as build
RUN apt-get update && apt-get install -y \
  build-essential \
  git \
  wget

# Build Neovim from source
FROM build as neovim
RUN apt-get install -y ninja-build gettext cmake unzip
RUN git clone --depth 1 --branch v0.9.5 https://github.com/neovim/neovim.git
RUN cd neovim && make CMAKE_BUILD_TYPE=Release  && make install DESTDIR=/nvim-install

FROM base as final
RUN apt-get update && apt-get install -y \
  curl \
  git \
  nodejs \
  npm \
  python3.11 \
  python3.11-venv \
  wget && \
wget -O gh.deb \
  https://github.com/cli/cli/releases/download/v2.47.0/gh_2.47.0_linux_amd64.deb && \
  apt install ./gh.deb && \
  rm gh.deb && \
  rm -rf /var/lib/apt/lists/*
RUN git config --system init.defaultBranch main
# RUN curl -s https://get.modular.com | sh

RUN useradd -ms /bin/bash dave
WORKDIR /home/dave
USER dave
COPY --from=neovim /nvim-install/usr /usr

RUN git config --global user.email "3943510+phueac@users.noreply.github.com"
RUN git config --global user.name "Dave Edmunds"

RUN git clone --recurse-submodules git@github.com:phueac/dotfiles.git ~/.dotfiles
RUN cd ~/.dotfiles
RUN ./install

#COPY ./nvim /home/dave/.config/nvim
RUN nvim --headless "+Lazy! sync" +qa
#RUN modular install mojo
#ENV PATH=/home/dave/.modular/pkg/packages.modular.com_mojo/bin:$PATH

ENTRYPOINT bash
