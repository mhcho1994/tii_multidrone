FROM ubuntu:20.04
LABEL maintainer="James Goppert <james.goppert@gmail.com>, Minhyun Cho <cho515@purdue.edu>"

# environment
ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=America/New_York
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# install px4 dependencies
RUN apt-get update && apt-get -y --quiet --no-install-recommends install \
  apt-utils \
  vim \
  bzip2 \
  ca-certificates \
  ccache \
  cmake \
  cppcheck \
  curl \
  dirmngr \
  doxygen \
  file \
  g++ \
  gcc \
  gdb \
  git \
  gnupg \
  gosu \
  lcov \
  libfreetype6-dev \
  libgtest-dev \
  libpng-dev \
  libssl-dev \
  lsb-release \
  make \
  ninja-build \
  openjdk-8-jdk \
  openssh-client \
  pkg-config \
  rsync \
  shellcheck \
  tzdata \
  unzip \
  valgrind \
  wget \
  xsltproc \
  zip \
  xterm \
  terminator \
  bash-completion \
  python3-dev \
  python3-pip \
  python3-future \
  python3-numpy \
  python3-matplotlib \
  python3-empy \
  python3-jinja2 \
  python3-coverage \
  python3-argcomplete \
  python3-cerberus \
  python3-packaging \
  python3-serial \
  python3-six \
  python3-toml \
  python3-wheel \
  python3-requests \
  python3-psutil \
  python3-jsonschema \
  python3-nacl \
  python3-pkgconfig \
  python3-setuptools \
  python3-yaml \
  libcanberra-gtk3-module \
  && apt-get -y autoremove \
  && apt-get clean

# gtest
RUN cp -r /usr/src/googletest/googletest /tmp \
  && cd /tmp/googletest \
  && mkdir build && cd build \
  && cmake .. && make -j$(nproc) \
  && find . -name \*.a -exec cp {} /usr/lib \; \
  && rm -rf /tmp/*

# ccache setup
RUN update-ccache-symlinks

# astyle v3.1
RUN wget -q https://downloads.sourceforge.net/project/astyle/astyle/astyle%203.1/astyle_3.1_linux.tar.gz -O /tmp/astyle.tar.gz \
  && cd /tmp && tar zxf astyle.tar.gz && cd astyle/src \
  && make -f ../build/gcc/Makefile -j$(nproc) && cp bin/astyle /usr/local/bin \
  && rm -rf /tmp/*

# Gradle (Required to build Fast-RTPS-Gen)
RUN wget -q "https://services.gradle.org/distributions/gradle-6.3-rc-4-bin.zip" -O /tmp/gradle-6.3-rc-4-bin.zip \
  && mkdir /opt/gradle \
  && cd /tmp \
  && unzip -d /opt/gradle gradle-6.3-rc-4-bin.zip \
  && rm -rf /tmp/*

ENV PATH "/opt/gradle/gradle-6.3-rc-4/bin:$PATH"

# Intall foonathan_memory from source as it is required to Fast-RTPS >= 1.9
RUN git clone https://github.com/eProsima/foonathan_memory_vendor.git --depth 1 /tmp/foonathan_memory \
  && cd /tmp/foonathan_memory \
  && mkdir build && cd build \
  && cmake .. \
  && cmake --build . -j $(nproc) \
  && make install \
  && rm -rf /tmp/*

# Fast-RTPS-Gen 1.0.4
RUN git clone --recursive https://github.com/eProsima/Fast-RTPS-Gen.git --depth 1 -b v1.0.4 /tmp/Fast-RTPS-Gen \
  && cd /tmp/Fast-RTPS-Gen \
  && gradle assemble \
  && /opt/gradle/gradle-6.3-rc-4/bin/gradle install \
  && rm -rf /tmp/*

# Fast-DDS 2.7.0
RUN git clone --recursive https://github.com/eProsima/Fast-DDS.git -b v2.7.0 --depth 1 /tmp/FastDDS-2.7.0 \
  && cd /tmp/FastDDS-2.7.0 \
  && mkdir build && cd build \
  && cmake -DTHIRDPARTY=ON -DSECURITY=ON .. \
  && cmake --build . -j $(nproc) \
  && make install \
  && rm -rf /tmp/*

# get the host user, group information to setup user
ARG HOST_USER_NAME HOST_USER_ID HOST_GROUP_NAME HOST_GROUP_ID

# setup user
RUN groupadd --gid ${HOST_GROUP_ID} docker \
 && adduser --disabled-password --gecos '' docker --uid ${HOST_USER_ID} --gid ${HOST_GROUP_ID}\
 && adduser docker sudo \
 && adduser docker dialout \
 && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker
WORKDIR /home/docker

# Python 3 dependencies installed by pip
RUN pip3 install kconfiglib pyros-genmsg pyulog nunavut --user

# build px4 autopilot
ENV PATH="/home/docker/bin:$PATH"
# note that px4 is a submodule, so we need to
# run docker build in parent context to grab .git
WORKDIR /home/docker
# COPY --chown=docker:docker .git .git
COPY --chown=docker:docker ./px4/bin ./bin
COPY --chown=docker:docker ./px4/PX4-Autopilot ./px4/PX4-Autopilot
#RUN px4_build.sh

# prevent terminator stderrr messages
ENV NO_AT_BRIDGE=1

# vim: set et fenc=utf-8 ff=unix ft=dockerfile sts=0 sw=2 ts=2 :
