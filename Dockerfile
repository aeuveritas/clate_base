# Clate
FROM ubuntu:18.04
MAINTAINER Karl.Jeong <aeuveritas@gmail.com>

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
    libssl-dev

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
RUN wget -c http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz \
    && tar xvf clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz \
    && rm -rf clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz \
    && mv clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04 /llvm \
    && git clone --depth=1 --recursive https://github.com/MaskRay/ccls \
    && cd ccls \
    && cmake -H. -BRelease -G Ninja -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/llvm \
    && ninja -C Release install && cd .. \
    && rm -rf ccls
ENV PATH=/llvm/bin:$PATH
ENV LD_LIBRARY_PATH=/llvm/lib:$LD_LIBRARY_PATH

# Python
RUN apt-get install virtualenv

# Node.js
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 10.16.0
RUN mkdir -p $NVM_DIR && curl https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH=/usr/local/nvm/versions/node/v10.16.0/bin:$PATH

# PATH for ssh user
RUN echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/llvm/bin:/usr/local/nvm/versions/node/v10.16.0/bin"' > /etc/environment

# Install ssh tools
RUN apt-get install -y \
    sshpass \
    openssh-server

# Set running environment
ENV TERM=xterm-256color
RUN echo "* hard nofile 773280" >> /etc/security/limits.conf \
    && echo "* soft nofile 773280" >> /etc/security/limits.conf \
    && echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf

ENTRYPOINT ["/bin/bash"]

