#!/bin/bash

# check whether the autopilot source code is included
if [ ! -d ./px4/PX4-Autopilot ]; then
    cd px4
    source ./bin/px4_clone.sh
    cd ..
fi

#
xhost +local:docker

#
export CONTAINER_USER_NAME=$(id -un)
export CONTAINER_USER_ID=$(id -u)
export CONTAINER_GROUP_NAME=$(id -gn)
export CONTAINER_GROUP_ID=$(id -g)