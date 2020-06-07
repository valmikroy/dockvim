FROM ubuntu:focal-20200423

ENV GOVERSION=1.13.7 \
    GOROOT=/usr/local/go \
    GOPATH=/root/go \
    GO111MODULE=on \
    GOPRIVATE="github.com/valmikroy" \
    PATH="/root/.yarn/bin:/root/.config/yarn/global/node_modules/.bin:/root/go/bin:/usr/local/go/bin:${PATH}"

RUN export DEBIAN_FRONTEND="noninteractive" \
        && apt-get update -y \
        && apt-get install -y curl git ncurses-dev exuberant-ctags software-properties-common \
        && add-apt-repository universe \
        && apt update -y \
        && apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip \
        && apt-get install -y python3 python3-pip python2


WORKDIR /build
RUN curl https://bootstrap.pypa.io/get-pip.py --output get-pip.py \
        && python2 get-pip.py \
        && pip2 install neovim \
        && pip3 install neovim \
        && pip2 install --upgrade neovim \
        && pip3 install --upgrade neovim

WORKDIR /build
RUN export CMAKE_BUILD_TYPE=Release \
        && export CMAKE_INSTALL_PREFIX=/usr/local \
        && git clone https://github.com/neovim/neovim.git \
        && cd neovim && git checkout stable \
        && make && make  install

WORKDIR /build
RUN curl -O https://dl.google.com/go/go${GOVERSION}.linux-amd64.tar.gz \
        && tar -xvf go1.13.7.linux-amd64.tar.gz \
        && mv go /usr/local 

WORKDIR /build
RUN curl -o install-node.now.sh -sL install-node.now.sh  &&  bash install-node.now.sh --yes

WORKDIR /build
RUN curl -o yarn_install.sh --compressed  -L https://yarnpkg.com/install.sh && bash yarn_install.sh && /root/.yarn/bin/yarn install --frozen-lockfile --network-concurrency 1


WORKDIR /tmp
RUN mkdir -p ${HOME}/.config/nvim \
        && mkdir -p ${HOME}/.config/nvim/UltiSnips \
        && mkdir -p ${HOME}/.local/share/nvim/site/autoload \
        && mkdir -p ${HOME}/.config/coc/extensions

RUN cd ${HOME}/.config/coc/extensions \
    && echo '{"dependencies":{}}'> package.json \
    && npm install coc-snippets --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod


COPY neovim-configs/init.vim  /root/.config/nvim/
COPY neovim-configs/coc-settings.json  /root/.config/nvim/
COPY neovim-configs/ultisnips/go.snippets  /root/.config/nvim/UltiSnips/
COPY neovim-configs/ultisnips/snippets.snippets  /root/.config/nvim/UltiSnips/

RUN curl -fLo ${HOME}/.local/share/nvim/site/autoload/plug.vim  \
        --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 

COPY entrypoint.sh /usr/local/bin/


ENV WORKSPACE="/mnt/workspace"
VOLUME "${WORKSPACE}"

#RUN /usr/local/bin/nvim -c " execute 'quit'"
RUN /usr/local/bin/nvim   -c " execute 'silent PlugInstall' | execute 'quitall' "  ; return 0
RUN /usr/local/bin/nvim   -c " execute 'silent call coc#util#install()' | execute 'quitall' "  ; return 0
#RUN /usr/local/bin/nvim -c " execute 'PlugInstall' | execute 'GoUpdateBinaries' | execute 'quit' "
#RUN /usr/local/bin/nvim -c " execute 'PlugInstall' | execute 'GoUpdateBinaries' | execute 'quit' "
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
