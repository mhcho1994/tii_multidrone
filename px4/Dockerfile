FROM ubuntu:20.04
LABEL maintainer="James Goppert <james.goppert@gmail.com>"

# setup user
RUN apt-get update \
 && apt-get install -y sudo apt-utils
RUN addgroup docker
RUN adduser --disabled-password --gecos '' docker --ingroup docker --ingroup dialout --shell /bin/bash
RUN adduser docker sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER docker
WORKDIR /home/docker

# environment
ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=America/New_York
RUN echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

# install px4 dependencies
RUN sudo apt-get update && sudo apt-get -y --quiet --no-install-recommends install \
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
  && sudo apt-get -y autoremove \
  && sudo apt-get clean autoclean \
  && sudo rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# gtest
RUN cp -r /usr/src/googletest/googletest /tmp \
  && cd /tmp/googletest \
  && mkdir build && cd build \
  && cmake .. && make -j$(nproc) \
  && sudo find . -name \*.a -exec cp {} /usr/lib \; \
  && rm -rf /tmp/*

# Python 3 dependencies installed by pip
RUN pip install kconfiglib pyros-genmsg pyulog nunavut --user

# ccache setup
RUN sudo update-ccache-symlinks

# astyle v3.1
RUN wget -q https://downloads.sourceforge.net/project/astyle/astyle/astyle%203.1/astyle_3.1_linux.tar.gz -O /tmp/astyle.tar.gz \
  && cd /tmp && tar zxf astyle.tar.gz && cd astyle/src \
  && make -f ../build/gcc/Makefile -j$(nproc) && sudo cp bin/astyle /usr/local/bin \
  && rm -rf /tmp/*

# Gradle (Required to build Fast-RTPS-Gen)
RUN wget -q "https://services.gradle.org/distributions/gradle-6.3-rc-4-bin.zip" -O /tmp/gradle-6.3-rc-4-bin.zip \
  && sudo mkdir /opt/gradle \
  && cd /tmp \
  && sudo unzip -d /opt/gradle gradle-6.3-rc-4-bin.zip \
  && rm -rf /tmp/*

ENV PATH "/opt/gradle/gradle-6.3-rc-4/bin:$PATH"

# Intall foonathan_memory from source as it is required to Fast-RTPS >= 1.9
RUN git clone https://github.com/eProsima/foonathan_memory_vendor.git --depth 1 /tmp/foonathan_memory \
  && cd /tmp/foonathan_memory \
  && mkdir build && cd build \
  && cmake .. \
  && cmake --build . -j $(nproc) \
  && sudo make install \
  && rm -rf /tmp/*

# Fast-RTPS-Gen 1.0.4
RUN git clone --recursive https://github.com/eProsima/Fast-RTPS-Gen.git --depth 1 -b v1.0.4 /tmp/Fast-RTPS-Gen \
  && cd /tmp/Fast-RTPS-Gen \
  && gradle assemble \
  && sudo /opt/gradle/gradle-6.3-rc-4/bin/gradle install \
  && sudo rm -rf /tmp/*

# Fast-DDS 2.7.0
RUN git clone --recursive https://github.com/eProsima/Fast-DDS.git -b v2.7.0 --depth 1 /tmp/FastDDS-2.7.0 \
  && cd /tmp/FastDDS-2.7.0 \
  && mkdir build && cd build \
  && cmake -DTHIRDPARTY=ON -DSECURITY=ON .. \
  && cmake --build . -j $(nproc) \
  && sudo make install \
  && rm -rf /tmp/*

# build px4 autopilot
ENV PATH="/home/docker/bin:$PATH"
# note that px4 is a submodule, so we need to
# run docker build in parent context to grab .git
COPY --chown=docker:docker .git .git
COPY --chown=docker:docker ./px4/bin ./bin
COPY --chown=docker:docker ./px4/PX4-Autopilot ./px4/PX4-Autopilot
#RUN px4_build.sh

# prevent terminator stderrr messages
ENV NO_AT_BRIDGE=1

# vim: set et fenc=utf-8 ff=unix ft=dockerfile sts=0 sw=2 ts=2 :