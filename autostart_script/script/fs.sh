#!/bin/bash
processing=$(ps -aux | grep flameshot | grep -v "grep")
if [ -z "${processing}" ]
then
	flameshot gui &
else
	pid=$(echo ${processing} | gawk '{print $2}')
	kill -9 $pid
	flameshot gui &
fi
	
