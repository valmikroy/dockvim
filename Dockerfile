FROM ubuntu:latest
RUN apt-get update && \
        apt-get install -y python3.8 python3.8-dev python3.8-minimal python3.8-venv python3-pip curl apt-utils
RUN curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage && \
        chmod +x nvim.appimage && mv nvim.appimage  /usr/bin/nvim 
RUN update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60 && \
    update-alternatives --config vi && \
    update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60 && \
    update-alternatives --config vim && \
    update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60 && \
    update-alternatives --config editor
RUN curl -O https://dl.google.com/go/go1.13.7.linux-amd64.tar.gz && \
        tar -xvf go1.13.7.linux-amd64.tar.gz && \
         chown -R root:root ./go && \
         mv go /usr/local
RUN apt-get install -y exuberant-ctags
ENTRYPOINT ["/usr/bin/nvim"]
