# Clate
FROM ubuntu:18.04

# Install dependencies
RUN apt-get update

RUN apt-get update
RUN apt-get install -y software-properties-common

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
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

# GCC-9
RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt update \
    && apt install -y gcc-9 g++-9 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9

# Python
RUN apt-get update
RUN apt-get install -y --no-install-recommends python3.8 python3.8-dev python3-pip python3-setuptools python3-wheel
RUN rm /usr/bin/python && ln -s /usr/bin/python3.8 /usr/bin/python
RUN pip3 install pep8

# RUN git clone https://github.com/Z3Prover/z3.git \
#     && cd z3 \
#     && git checkout -b z3-4.8.8 z3-4.8.8 \
#     && python scripts/mk_make.py \
#     && cd build \
#     && make -j8 \
#     && make install \
#     && cd ../.. \
#     && rm -rf z3

# Build llvm & clang && ccls
RUN wget -c https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.0/clang+llvm-10.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz \
    && tar xvf clang+llvm-10.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz \
    && rm -rf clang+llvm-10.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz \
    && mv clang+llvm-10.0.0-x86_64-linux-gnu-ubuntu-18.04 /llvm \
    && git clone --depth=1 --recursive https://github.com/MaskRay/ccls \
    && cd ccls \
    && cmake -H. -BRelease -G Ninja -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/llvm \
    && ninja -C Release install && cd .. \
    && rm -rf ccls
ENV PATH /llvm/bin:$PATH
ENV LD_LIBRARY_PATH /llvm/lib:$LD_LIBRARY_PATH

# Node.js
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 12.16.3
RUN mkdir -p $NVM_DIR && \
    curl https://raw.githubusercontent.com/creationix/nvm/v0.35.3/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Bash
RUN npm i -g bash-language-server

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

