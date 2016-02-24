#!/bin/bash

function usage() {
	# Help
	echo -e "\n ./sim-bad-net-timer.sh #1 #2 #3 #4 #5"
	echo -e "\t #1: delay \t\t The amont of delay in ms"
	echo -e "\t #2: delay-variation \t The delay variation, ms as well"
	echo -e "\t #3: package-loss \t The amount of package-loss you want to see in %"
	echo -e "\t #4: corruption \t The amount of corruption you want to see in %"
	echo -e "\t #5: timer \t For how much time do you wish to simulate a bad network in seconds"

	echo -e "\n ** Examples **"
	echo -e "\t % ./sim-bad-net-timer.sh 500 100 10 0.5 60"
	echo -e "\t % ./sim-bad-net-timer.sh 0 0 100 0 300\n"

	exit 1;
}

# Checks
[[ -z "$1" ]] && usage
[[ -z "$2" ]] && usage
[[ -z "$3" ]] && usage
[[ -z "$4" ]] && usage
[[ -z "$5" ]] && usage

# Start

# Adding configs for outgoing packages
tc qdisc add dev eth0 root netem delay $(expr "$1" / 2)ms $(expr "$2" / 2)ms loss random $(expr "$3" / 2)% corrupt $(expr "$4" / 2)%

# Set ifb0
modprobe ifb
ip link set dev ifb0 up
tc qdisc add dev eth0 handle ffff: ingress
tc filter add dev eth0 parent ffff: protocol ip u32 match u32 0 0 action mirred egress redirect dev ifb0

# Adding configs for incoming packages
tc qdisc add dev ifb0 root netem delay $(expr "$1" / 2)ms $(expr "$2" / 2)ms loss random $(expr "$3" / 2)% corrupt $(expr "$4" / 2)%

echo -e "\n Your network is bad now :P \n"

echo -e "\n Applying delay of $5 seconds"

sleep "$5";

# Stop
tc qdisc delete dev eth0 root
tc qdisc delete dev ifb0 root

echo -e "\n Your network is ok again ;)"

exit 0;
