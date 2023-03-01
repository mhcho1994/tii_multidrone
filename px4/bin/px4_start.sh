#!/bin/bash
# run multiple instances of the px4 binary, but w/o starting the simulator.
# first build the px4 using 'px4_build.sh'

sitl_num=1
[ -n "$1" ] && sitl_num="$1"

build_path=$HOME/px4/PX4-Autopilot/build/px4_sitl_rtps

echo "killing running instances"
pkill -x px4 || true

sleep 1

n=0
while [ $n -lt $sitl_num ]; do
	working_dir="$build_path/instance_$n"
	[ ! -d "$working_dir" ] && mkdir -p "$working_dir"

	pushd "$working_dir" &>/dev/null
	echo "starting instance $n in $(pwd)"
	../bin/px4 -i $n -d "$build_path/etc" -s etc/init.d-posix/rcS >out.log 2>err.log &
	popd &>/dev/null

	n=$(($n + 1))
done

# cd $HOME/px4/PX4-Autopilot/build/px4_sitl_rtps && ./bin/px4 ./etc -s etc/init.d-posix/rcS