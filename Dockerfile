FROM centos:7.6.1810

RUN yum -y group install "Development Tools" \
    && yum install -y centos-release-scl \
    && yum install -y epel-release \
    && yum install -y https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm \
    && yum update -y \
    && yum install -y cmake3 devtoolset-7 devtoolset-7-libasan-devel devtoolset-7-libubsan-devel \
    && yum install -y libaio sudo openssl-devel net-tools wget file unzip vim curl git python-pip \
    && ln -s /usr/bin/cmake3 /usr/bin/cmake \
    && yum -y clean all

RUN localedef -c -f UTF-8 -i en_US en_US.UTF-8 \
    && useradd --create-home --shell /bin/bash dev -G wheel \
    && echo "dev:dev" | chpasswd

ENV CC=/opt/rh/devtoolset-7/root/usr/bin/gcc
ENV CXX=/opt/rh/devtoolset-7/root/usr/bin/g++
ENV LC_ALL en_US.UTF-8

RUN cd /home/dev && curl -fsSL https://ftp.gnu.org/gnu/glibc/glibc-2.20.tar.gz  | tar xzf - 
RUN cd /home/dev && curl -fsSL https://github.com/clangd/clangd/releases/download/12.0.0/clangd-linux-12.0.0.zip -o clangd-linux-12.0.0.zip 
RUN cd /home/dev && curl -fsSL https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/p/patchelf-0.12-1.el7.x86_64.rpm -o patchelf.rpm \
    && rpm -ivh patchelf.rpm


RUN cd /home/dev/glibc-2.20 && mkdir build && cd build && ../configure --prefix=/opt/glibc-2.20 && make && make install \
    && unzip /home/dev/clangd-linux-12.0.0.zip -d /usr/local \
    && ln -s /usr/local/clangd_12.0.0/bin/clangd  /usr/bin/clangd \
    && patchelf --set-interpreter /opt/glibc-2.20/lib/ld-linux-x86-64.so.2 --set-rpath /opt/glibc-2.20/lib:/usr/lib64 /usr/local/clangd_12.0.0/bin/clangd \
    && pip install -q compdb \
    && rm -fr /home/dev/*

USER dev 
WORKDIR /home/dev
