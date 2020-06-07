FROM ubuntu:focal-20200423

RUN export DEBIAN_FRONTEND="noninteractive" \
        && apt-get update -y \
        && apt-get install -y curl git ncurses-dev exuberant-ctags \
        && apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip


WORKDIR /build
RUN export CMAKE_BUILD_TYPE=Release \
        && export CMAKE_INSTALL_PREFIX=/usr/local \
        && git clone https://github.com/neovim/neovim.git \
        && cd neovim && git checkout stable \
        && make && make  install



WORKDIR /tmp
COPY entrypoint.sh /usr/local/bin/
#RUN time vim -c "execute 'silent GoUpdateBinaries' | execute 'quit'"


ENV WORKSPACE="/mnt/workspace"
VOLUME "${WORKSPACE}"

RUN /usr/local/bin/nvim -c "execute 'quit'"
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
