FROM ubuntu:xenial

ENV DEBIAN_FRONTEND=noninteractive
ENV GRAMATRON_HOME=/root
WORKDIR $GRAMATRON_HOME

RUN apt-get -y update && \ 
    apt-get -y install build-essential curl git-all libxml2-dev bison libsqlite3-dev \
    lcov autoconf libtool gdb pkg-config vim silversearcher-ag ruby\
    wget graphviz libgraphviz-dev clang-8 cmake

# Install python3 (not present in xenial apt repo)
RUN apt-get -y update && apt-get -y install software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get -y update && \
    apt-get -y install python3.6 python3.6-venv python3.6-dev python3-pip 

RUN python3.6 -m pip install --upgrade pip && \
    python3.6 -m pip install matplotlib==3.1.1 pygraphviz networkx

RUN apt-get -y install locales && locale-gen en_US.UTF-8
ENV LC_ALL="en_US.UTF-8"

#========COMPILER SETUP============
# Set defaults
 RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-8 10 \
                         --slave /usr/bin/clang++ clang++ /usr/bin/clang++-8 && \
     update-alternatives --install /usr/lib/llvm llvm /usr/lib/llvm-8 20 \
                         --slave /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-8

#========FUZZER SETUP==============
# Setup AFL toolchain to compile the targets with it
WORKDIR $GRAMATRON_HOME
RUN git clone https://github.com/json-c/json-c.git  
RUN cd json-c && git reset --hard af8dd4a307e7b837f9fa2959549548ace4afe08b && sh autogen.sh && ./configure && make && make install

#===========TARGET DEPENDENCY SETUP=============
# Setup re2c (PHP)
WORKDIR $GRAMATRON_HOME
RUN git clone https://github.com/skvadrik/re2c.git re2c
WORKDIR "$GRAMATRON_HOME/re2c"
RUN git reset --hard 0d5342dd9733833a7a30af4120cf05740967b5d5 && ./autogen.sh && \
    ./configure && \
    make -j`nproc` && \
    make install

# Switch to home user
WORKDIR $GRAMATRON_HOME
RUN mkdir gramatron_src 
COPY ./src ./gramatron_src
COPY ./grammars ./grammars
WORKDIR ./gramatron_src
RUN ./setup.sh
