<<<<<<< HEAD
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
=======
# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/engine/reference/builder/

################################################################################
# Pick a base image to serve as the foundation for the other build stages in
# this file.
#
# For illustrative purposes, the following FROM command
# is using the alpine image (see https://hub.docker.com/_/alpine).
# By specifying the "latest" tag, it will also use whatever happens to be the
# most recent version of that image when you build your Dockerfile.
# If reproducability is important, consider using a versioned tag
# (e.g., alpine:3.17.2) or SHA (e.g., alpine:sha256:c41ab5c992deb4fe7e5da09f67a8804a46bd0592bfdf0b1847dde0e0889d2bff).
FROM ubuntu:22.04 as base

################################################################################
# Create a stage for building/compiling the application.
#
# The following commands will leverage the "base" stage above to generate
# a "hello world" script and make it executable, but for a real application, you
# would issue a RUN command for your application's build process to generate the
# executable. For language-specific examples, take a look at the Dockerfiles in
# the Awesome Compose repository: https://github.com/docker/awesome-compose
FROM base as build
RUN apt-get update && apt-get install -y \
    cmake \
    curl \
    gettext \
    git \
    ninja-build \
    unzip \
    && rm -rf /var/lib/apt/lists/*
ARG neovim_version=v0.9.5
RUN git clone --branch $neovim_version https://github.com/neovim/neovim && cd neovim && make CMAKE_BUILD_TYPE=Release
RUN cd neovim && make install

################################################################################
# Create a final stage for running your application.
#
# The following commands copy the output from the "build" stage above and tell
# the container runtime to execute it when the image is run. Ideally this stage
# contains the minimal runtime dependencies for the application as to produce
# the smallest image possible. This often means using a different and smaller
# image than the one used for building the application, but for illustrative
# purposes the "base" image is used here.
FROM base AS final
COPY --from=build /usr/local/bin/nvim /usr/local/bin/nvim
COPY --from=build /usr/local/share/nvim /usr/local/share/nvim

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
#ARG UID=10001
#RUN adduser \
#    --disabled-password \
#    --gecos "" \
#    --home "/nonexistent" \
#    --shell "/sbin/nologin" \
#    --no-create-home \
#    --uid "${UID}" \
#    appuser
#USER appuser

# Copy the executable from the "build" stage.
# COPY --from=build /bin/hello.sh /bin/

# What the container should run when it is started.
#ENTRYPOINT [ "bash" ]
>>>>>>> 92b7640 (Add Neovim)
