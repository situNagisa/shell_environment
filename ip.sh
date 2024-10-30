function get_ip()
{
	local net="$1"
	if [ -z "$net" ]; then
		echo "Usage:"
		echo "\tget_ip <net_interface>"
		echo "example:"
		echo "\tget_ip eth0"
		exit -1
	fi
	ip addr show $net | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
}
