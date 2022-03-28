#!/bin/sh

# A dwm_bar function to show the master volume of ALSA
# Joe Standring <git@joestandring.com>
# GNU GPLv3

# Dependencies: alsa-utils

dwm_alsa () {
    VOL=$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")
    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        if [ "$VOL" -eq 0 ]; then
            printf "🔇"
        elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
            printf "🔈 %s%%" "$VOL"
        elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
            printf "🔉 %s%%" "$VOL"
        else
            printf "🔊 %s%%" "$VOL"
        fi
    else
        if [ "$VOL" -eq 0 ]; then
            printf "MUTE"
        elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
            printf "VOL %s%%" "$VOL"
        elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
            printf "VOL %s%%" "$VOL"
        else
            printf "VOL %s%%" "$VOL"
        fi
    fi
    printf "%s\n" "$SEP2"
}

# A dwm_bar module to display the current backlight brighness with xbacklight
# Joe Standring <git@joestandring.com>
# GNU GPLv3

# Dependencies: xbacklight
# debug xbacklight add arg -get
# Penghuaxing
dwm_backlight () {
    printf "%s☀ %.0f%s\n" "$SEP1" "$(xbacklight -get)" "$SEP2"
}

dwm_backlight

# A dwm_bar function to read the battery level and status
# Joe Standring <git@joestandring.com>
# GNU GPLv3

dwm_battery () {
    # Change BAT1 to whatever your battery is identified as. Typically BAT0 or BAT1
    CHARGE=$(cat /sys/class/power_supply/BAT1/capacity)
    STATUS=$(cat /sys/class/power_supply/BAT1/status)

    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        if [ "$STATUS" = "Charging" ]; then
            printf " %s%% %s" "$CHARGE" "$STATUS"
        else
            printf " %s%% %s" "$CHARGE" "$STATUS"
        fi
    else
        printf "BAT %s%% %s" "$CHARGE" "$STATUS"
    fi
    printf "%s\n" "$SEP2"
}

dwm_battery


# A dwm_bar function that shows the current date and time
# Joe Standring <git@joestandring.com>
# GNU GPLv3

# Date is formatted like like this: "[Mon 01-01-00 00:00:00]"
dwm_date () {
    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
		printf " %s" "$(date "+%a %d-%m-%y %T")"
	else
        printf "DAT %s" "$(date "+%a %d-%m-%y %T")"
    fi
    printf "%s\n" "$SEP2"
}

dwm_date


# A dwm_bar function to display the number of emails in an inbox
# Joe Standring <git@joestandring.com>
# GNU GPLv3

# To count mail in an inbox, change "/path/to/inbox" below to the location of your inbox. For example, "/home/$USER/.mail/new"

dwm_mail () {
    MAILBOX=$(ls /path/to/inbox | wc -l)

    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        if [ "$MAILBOX" -eq 0 ]; then
			printf "﫮 %s" "$MAILBOX"
		else
			printf " %s" "$MAILBOX"
		fi
    else
        printf "MAI %s" "$MAILBOX"
    fi
    printf "%s\n" "$SEP2"
}

dwm_mail

# A dwm_bar function to show the current network connection/SSID, private IP, and public IP
# Joe Standring <git@joestandring.com>
# GNU GPLv3

# Dependencies: NetworkManager, curl

dwm_network () {
    CONNAME=$(nmcli -a | grep 'Wired connection' | awk 'NR==1{print $1}')
    if [ "$CONNAME" = "" ]; then
        CONNAME=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -c 5-)
    fi

    PRIVATE=$(nmcli -a | grep 'inet4 192' | awk '{print $2}')
    PUBLIC=$(curl -s https://ipinfo.io/ip)

    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
		printf " %s %s | %s " "$CONNAME" "$PRIVATE" "$PUBLIC"
else
        printf "NET %s %s | %s" "$CONNAME" "$PRIVATE" "$PUBLIC"
    fi
    printf "%s\n" "$SEP2"
}

dwm_network

# A dwm_bar function to show the master volume of PulseAudio
# Joe Standring <git@joestandring.com>
# GNU GPLv3

# Dependencies: pamixer

dwm_pulse () {
    VOL=$(pamixer --get-volume-human | tr -d '%')

    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        if [ "$VOL" = "muted" ] || [ "$VOL" -eq 0 ]; then
            printf "🔇"
        elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
            printf "🔈 %s%%" "$VOL"
        elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
            printf "🔉 %s%%" "$VOL"
        else
            printf "🔊 %s%%" "$VOL"
        fi
    else
        if [ "$VOL" = "muted" ] || [ "$VOL" -eq 0 ]; then
            printf "MUTE"
        elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
            printf "VOL %s%%" "$VOL"
        elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
            printf "VOL %s%%" "$VOL"
        else
            printf "VOL %s%%" "$VOL"
        fi
    fi
    printf "%s\n" "$SEP2"
}

dwm_pulse

# A dwm_bar function to display information regarding system memory, CPU temperature, and storage
# Joe Standring <git@joestandring.com>
# GNU GPLv3

dwm_resources () {
    # Used and total memory
    MEMUSED=$(free -h | awk '(NR == 2) {print $3}')
    MEMTOT=$(free -h |awk '(NR == 2) {print $2}')
    # CPU temperature
    CPU=$(sysctl -n hw.sensors.cpu0.temp0 | cut -d. -f1)
    # Used and total storage in /home (rounded to 1024B)
    STOUSED=$(df -h | grep '/home$' | awk '{print $3}')
    STOTOT=$(df -h | grep '/home$' | awk '{print $2}')
    STOPER=$(df -h | grep '/home$' | awk '{print $5}')

    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        printf "💻 MEM %s/%s CPU %s STO %s/%s: %s" "$MEMUSED" "$MEMTOT" "$CPU" "$STOUSED" "$STOTOT" "$STOPER"
    else
        printf "STA | MEM %s/%s CPU %s STO %s/%s: %s" "$MEMUSED" "$MEMTOT" "$CPU" "$STOUSED" "$STOTOT" "$STOPER"
    fi
    printf "%s\n" "$SEP2"
}

dwm_resources

# A dwm_bar function to print the weather from wttr.in
# Joe Standring <git@joestandring.com>
# GNU GPLv3

# Dependencies: curl

# Change the value of LOCATION to match your city
dwm_weather() {
    LOCATION=city

    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        printf "%s" "$(curl -s wttr.in/$LOCATION?format=1)"
    else
        printf "WEA %s" "$(curl -s wttr.in/$LOCATION?format=1 | grep -o "[0-9].*")"
    fi
    printf "%s\n" "$SEP2"
}

dwm_weather
