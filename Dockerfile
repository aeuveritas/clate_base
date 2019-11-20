# Clate
FROM ubuntu:18.04

# Install dependencies
RUN apt-get update

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    python3-dev \
    python3-pip \
    diffutils \
    libboost-all-dev \
    software-properties-common\
    autoconf \
    bison \
    flex \
    gperf \
    libtool-bin \
    texinfo \
    ncurses-dev \
    cmake \
    zlib1g-dev \
    ninja-build \
    xz-utils \
    neovim \
    apt-transport-https \
    ca-certificates \
    libssl-dev \
    unzip

RUN apt-get install g++-8 -y \
    && rm /usr/bin/g++ \
    && ln -s /usr/bin/g++-8 /usr/bin/g++

RUN git clone https://github.com/Z3Prover/z3.git \
    && cd z3 \
    && git checkout -b z3-4.8.4 z3-4.8.4 \
    && python scripts/mk_make.py \
    && cd build \
    && make -j15 \
    && make install \
    && cd ../.. \
    && rm -rf z3

# Build llvm & clang && ccls
RUN wget -c http://releases.llvm.org/9.0.0/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz \
    && tar xvf clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz \
    && rm -rf clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz \
    && mv clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04 /llvm \
    && git clone --depth=1 --recursive https://github.com/MaskRay/ccls \
    && cd ccls \
    && cmake -H. -BRelease -G Ninja -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/llvm \
    && ninja -C Release install && cd .. \
    && rm -rf ccls
ENV PATH /llvm/bin:$PATH
ENV LD_LIBRARY_PATH /llvm/lib:$LD_LIBRARY_PATH

# Python
RUN apt-get install virtualenv -y
RUN pip3 install pep8

# Node.js
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 10.16.0
RUN mkdir -p $NVM_DIR && \
    curl https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install ssh tools
RUN apt-get install -y \
    sshpass \
    openssh-server

# Set running environment
ENV TERM xterm-256color
RUN echo "* hard nofile 773280" >> /etc/security/limits.conf \
    && echo "* soft nofile 773280" >> /etc/security/limits.conf \
    && echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf

# PATH for ssh user
RUN echo "PATH=\"$PATH\"" > /etc/environment

ENTRYPOINT ["/bin/bash"]

