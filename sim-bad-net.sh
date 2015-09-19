#!/bin/bash

# Help
if [ -z "$1" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
	echo -e "\n ./sim-bad-net.sh start #1 #2 #3 #4"
	echo -e "\t #1: delay \t\t The amont of delay in ms"
	echo -e "\t #2: delay-variation \t The delay variation, ms as well"
	echo -e "\t #3: package-loss \t The amount of package-loss you want to see in %"
	echo -e "\t #4: corruption \t The amount of corruption you want to see in %"

	echo -e "\n ./sim-bad-net.sh add #1"
	echo -e "\t #1: numeric-ip \t Your network will be bad only with those specified IPs"

	echo -e "\n ./sim-bad-net.sh stop"

	echo -e "\n ** Examples **"
	echo -e "\t % ./sim-bad-net.sh start 500 100 10 0.5"
	echo -e "\t % ./sim-bad-net.sh add 192.168.17.106"
	echo -e "\t % ./sim-bad-net.sh add 192.168.17.25"
	echo -e "\t % ./sim-bad-net.sh stop\n"

	exit 0;
fi

# Start
if [ "$1" = "start" ]
then
	# Set ifb0
	modprobe ifb
	ip link set dev ifb0 up
	tc qdisc add dev eth0 ingress
	tc filter add dev eth0 parent ffff: protocol ip u32 match u32 0 0 flowid 1:1 action mirred egress redirect dev ifb0

	# Adding configs for outgoing packages
	tc qdisc add dev eth0 handle 1: root htb
	tc class add dev eth0 parent 1: classid 1:1 htb rate 1000Mbps
	tc class add dev eth0 parent 1:1 classid 1:11 htb rate 1000Mbps

	tc qdisc add dev eth0 parent 1:11 handle 10: netem delay "$2"ms "$3"ms loss random "$4"% corrupt "$5"%
	echo -e "\n Add some IPs now! \n"
	exit 0;
fi

# Filter
if [ "$1" = "add" ]
then
	tc filter add dev eth0 protocol ip prio 1 u32 match ip dst "$2" flowid 1:11

	echo -e "\n Your network is bad now for IP $2  :d \n"
	exit 0;
fi

# Stop
if [ "$1" = "stop" ]
then
	tc qdisc delete dev eth0 root
	tc qdisc delete dev ifb0 root

	echo -e "\n Your network is ok again :)"
	echo -e " * Just ignore any message from system \n"
	exit 0;
fi
