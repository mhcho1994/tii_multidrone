#!/bin/bash

# run this shell script at ./px4 directory
if [ ! -d PX4-Autopilot ]; then
    git clone https://github.com/PX4/PX4-Autopilot.git
    cd PX4-Autopilot
    git checkout tags/v1.12.3
    cd ..
fi