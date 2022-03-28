#!/bin/bash
# Screenshot: http://s.natalian.org/2013-08-17/dwm_status.png
# Network speed stuff stolen from http://linuxclues.blogspot.sg/2009/11/shell-script-show-network-speed.html

# 2022-03-28 edit penghuaxing
# origin: https://github.com/theniceboy/scripts

# This function parses /proc/net/dev file searching for a line containing $interface data.
# Within that line, the first and ninth numbers after ':' are respectively the received and transmited bytes.
function get_bytes {
	# Find active network interface
	interface=$(ip route get 8.8.8.8 2>/dev/null| awk '{print $5}')
	line=$(grep $interface /proc/net/dev | cut -d ':' -f 2 | awk '{print "received_bytes="$1, "transmitted_bytes="$9}')
	eval $line
	now=$(date +%s%N)
}

# Function which calculates the speed using actual and old byte number.
# Speed is shown in KByte per second when greater or equal than 1 KByte per second.
# This function should be called each second.

function get_velocity {
	value=$1
	old_value=$2
	now=$3

	timediff=$(($now - $old_time))
	velKB=$(echo "1000000000*($value-$old_value)/1024/$timediff" | bc)
	if test "$velKB" -gt 1024
	then
		echo $(echo "scale=2; $velKB/1024" | bc)MB/s
	else
		echo ${velKB}KB/s
	fi
}

# Get initial values
get_bytes
old_received_bytes=$received_bytes
old_transmitted_bytes=$transmitted_bytes
old_time=$now

print_volume() {
	volumns=$(amixer get Master | tail -n1 | sed -r 's/.*\[(.+)%\].*\[(off|on)\].*/\1,\2/')
	if [ $(echo ${volumns} | gawk -F, '{print $2}') = "on" ]
	then
		val=$(echo ${volumns} | gawk -F, '{print $1}')
		if [ $(echo "$val>70" | bc) -eq 1 ]
		then
			echo -e " ${val}"
		elif [ $(echo "$val > 30" | bc) -eq 1 ]
		then
			echo -e "墳 ${val}"
		elif [ $(echo "$val > 0" | bc) -eq 1 ]
		then
			echo -e " ${val}"
		else
			echo -e "ﱝ "
		fi
	else
		echo -e "ﱝ "
	fi
}

print_mem(){
	memfree=$(($(grep -m1 'MemAvailable:' /proc/meminfo | awk '{print $2}') / 1024))
	echo -e "$memfree"
}

print_cpu(){
	mycpu=$(top -bn1 -i | grep -i "%cpu" | gawk -F, '{print $1}' | gawk -F: '{print $2}' | gawk '{print $1}')
	echo -e " $mycpu"
}


get_time_until_charged() {
	# get until_charget time or remain time
	pretty_time=$(acpi -V  | grep -m1 "Battery" | gawk -F, '{print $3}' | gawk '{print $1}')
	if [ -z "${pretty_time}" ]
	then
		pretty_time="Full"
	fi
	echo $pretty_time;
}

get_battery_combined_percent() {

	percent=$(acpi -V | grep -m1 "Battery" | gawk -F "," '{print $2}' | sed 's/ //')

	echo $percent;
}

get_battery_charging_status() {
	acpi_value=$(acpi -V)
	battery_percent=$(echo "$acpi_value" | grep -m1 "Battery" | gawk -F, '{print $2}' | sed 's/ //' | sed 's/%//')
	if [ "$(echo "$(acpi -V)" | grep -i adapter | gawk '{print $3}')" = "off-line" ]
	then
		if [ $(echo "$battery_percent>90" | bc) -eq 1 ]
		then
			echo "";
		elif [ $(echo "$battery_percent>80" | bc) -eq 1 ]
		then
			echo ""
		elif [ $(echo "$battery_percent>70" | bc) -eq 1 ]
		then
			echo ""
		elif [ $(echo "$battery_percent>60" | bc) -eq 1 ]
		then
			echo ""
		elif [ $(echo "$battery_percent>50" | bc) -eq 1 ]
		then
			echo ""
		elif [ $(echo "$battery_percent>40" | bc) -eq 1 ]
		then
			echo ""
		elif [ $(echo "$battery_percent>30" | bc) -eq 1 ]
		then
			echo ""
		elif [ $(echo "$battery_percent>20" | bc) -eq 1 ]
		then
			echo ""
		else
			echo ""
		fi
	else # acpi can give Unknown or Charging if charging, https://unix.stackexchange.com/questions/203741/lenovo-t440s-battery-status-unknown-but-charging
		if [ $(echo "$battery_percent>90" | bc) -eq 1 ]
		then
			echo "";
		elif [ $(echo "$battery_percent>80" | bc) -eq 1 ]
		then
			echo ""
		elif [ $(echo "$battery_percent>60" | bc) -eq 1 ]
		then
			echo ""
		elif [ $(echo "$battery_percent>40" | bc) -eq 1 ]
		then
			echo ""
		elif [ $(echo "$battery_percent>30" | bc) -eq 1 ]
		then
			echo ""
		else 
			echo ""
		fi
	fi
}



print_bat(){
	if [ -z "$(acpi -V | grep -m1 "Battery" | grep "Full")" ]
	then
		echo "$(get_battery_charging_status) $(get_battery_combined_percent); $(get_time_until_charged)";
	else
		echo " $(get_battery_combined_percent)"
	fi
}



#LOC=$(readlink -f "$0")
#DIR=$(dirname "$LOC")
#export IDENTIFIER="unicode"

#. "$DIR/dwmbar-functions/dwm_transmission.sh"
#. "$DIR/dwmbar-functions/dwm_cmus.sh"
#. "$DIR/dwmbar-functions/dwm_resources.sh"
#. "$DIR/dwmbar-functions/dwm_battery.sh"
#. "$DIR/dwmbar-functions/dwm_mail.sh"
#. "$DIR/dwmbar-functions/dwm_backlight.sh"
#. "$DIR/dwmbar-functions/dwm_alsa.sh"
#. "$DIR/dwmbar-functions/dwm_pulse.sh"
#. "$DIR/dwmbar-functions/dwm_weather.sh"
#. "$DIR/dwmbar-functions/dwm_vpn.sh"
#. "$DIR/dwmbar-functions/dwm_network.sh"
#. "$DIR/dwmbar-functions/dwm_keyboard.sh"
#. "$DIR/dwmbar-functions/dwm_ccurse.sh"
#. "$DIR/dwmbar-functions/dwm_date.sh"

get_bytes

# Calculates speeds
vel_recv=$(get_velocity $received_bytes $old_received_bytes $now)
vel_trans=$(get_velocity $transmitted_bytes $old_transmitted_bytes $now)


dwm_backlight () {
    printf "☀ %s\n" "$(xbacklight -get)"
}

dwm_date () {
    printf " %s" "$(date "+%a %y-%m-%d %R")"
}


xsetroot -name " $(print_cpu)  $vel_recv  $vel_trans  [ $(print_bat) ] $(dwm_backlight) $(print_volume) $(dwm_date) "

# Update old values to perform new calculations
old_received_bytes=$received_bytes
old_transmitted_bytes=$transmitted_bytes
old_time=$now

exit 0
