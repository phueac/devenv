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

# Create a non-root user
RUN useradd -ms /bin/bash dave
WORKDIR /home/dave
USER dave
COPY --from=neovim /nvim-install/usr /usr

RUN git config --global user.email "3943510+phueac@users.noreply.github.com"
RUN git config --global user.name "Dave Edmunds"

RUN --mount=type=secret,id=github_personal_access_token,uid=1000 PAT=$(cat /run/secrets/github_personal_access_token) && git clone https://$PAT@github.com/phueac/dotfiles.git .dotfiles && cd .dotfiles && ./install

# Install nvm (Node version manager) and LTS version of NodeJS
RUN PROFILE=/dev/null curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && bash -c "source ~/.nvm/nvm.sh && nvm install --lts && npm install -g typescript-language-server"

RUN nvim --headless "+Lazy! sync" +qa
#RUN modular install mojo
#ENV PATH=/home/dave/.modular/pkg/packages.modular.com_mojo/bin:$PATH

ENTRYPOINT bash
