ARG UBUNTU_VERSION=dummy

FROM ubuntu:${UBUNTU_VERSION} AS base

ENV DEBIAN_FRONTEND noninteractive

# install dependencies for ppa download
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
    software-properties-common

# install libraries
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    add-apt-repository ppa:neovim-ppa/stable && \
    apt-get update && apt-get install -y \
    libcanberra-gtk3-module \
    libgccjit0 \
    libgif7 \
    libgtk-3-common \
    libjansson4 \
    libmagickwand-6.q16-6 \
    libtree-sitter0 \
    libwebkit2gtk-4.0-37 \
    libxaw7 \
    libxft2 \
    texinfo

FROM base AS emacs-build

# install build tools and library headers
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
    build-essential \
    curl \
    g++-10 \
    gcc-10 \
    libcanberra-dev \
    libcanberra-gtk3-dev \
    libgccjit-10-dev \
    libgif-dev \
    libgnutls28-dev \
    libgtk-3-dev \
    libjansson-dev \
    libjpeg-dev \
    libmagickcore-dev libmagick++-dev \
    libncurses-dev \
    libpng-dev \
    libtiff5-dev \
    libtree-sitter-dev \
    libwebkit2gtk-4.0-dev \
    libxaw7-dev \
    libxft-dev \
    libxpm-dev

ARG EMACS_VERSION=29.4

# download && unpack
WORKDIR /opt/src
RUN curl -Ls https://ftp.gnu.org/gnu/emacs/emacs-${EMACS_VERSION}.tar.xz | tar xvJf -

# configure && build
WORKDIR /opt/src/emacs-${EMACS_VERSION}
ENV CC=/usr/bin/gcc-10
ENV CXX=/usr/bin/gcc-10
RUN ./autogen.sh
RUN ./configure \
    --with-imagemagick \
    --with-json \
    --with-native-compilation \
    --with-tree-sitter \
    --with-xft \
    --with-xwidgets
RUN make --jobs=$(nproc)

# install && pack
RUN make install prefix=/opt/usr/local && tar -C /opt -cf /opt/emacs.tar.xz usr/local

FROM base AS emacs

COPY --from=emacs-build /opt/emacs.tar.xz /usr/share/
RUN tar xf /usr/share/emacs.tar.xz -C /
