FROM ubuntu:20.04
LABEL maintainer="James Goppert <james.goppert@gmail.com>, Minhyun Cho <cho515@purdue.edu>"

# install dependencies
RUN apt-get update && apt-get remove modemmanager -y \
  && apt-get install --no-install-recommends -y \
  vim \
  terminator \
  gstreamer1.0-plugins-bad \
  gstreamer1.0-libav \
  gstreamer1.0-gl \
  libqt5gui5 \
  wget \
  sudo \
  bash-completion \
  libfuse3-3 \
  fuse \
  libcanberra-gtk-module \
  libpulse-mainloop-glib0 \
  ca-certificates \
  && apt-get -y autoremove \
	&& apt-get clean

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

# download qgroundcontrol
RUN wget https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl.AppImage \
  && chmod +x ./QGroundControl.AppImage

# set permission for .config directory for when volume is mounted
# this allows qgc to remember settings
RUN mkdir -p /home/docker/.config/QGroundControl.org \
  && chown -R docker:docker .config

RUN mkdir -p /tmp/runtime-docker && chmod 700 /tmp/runtime-docker
ENV XDG_RUNTIME_DIR=/tmp/runtime-docker

# prevent terminator stderrr messages
ENV NO_AT_BRIDGE=1

# vim: set et fenc=utf-8 ff=unix ft=dockerfile sts=0 sw=2 ts=2 :