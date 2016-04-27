#!/bin/bash

# This script will alert if dewpoint is below 36 degrees F.

logDir="/var/log/weatherAlert/weatherAlert.log"

notify() {
	stateFile="/tmp/weatherAlertAlarm"
	if test `find $stateFile 2>/dev/null`
	then
		echo "Five alerts already sent!" >> $logDir
		date >>$logDir
	else
		for i in `seq 0 4`;
		do 
			aws sns publish\
         		\--topic-arn arn:aws:sns:us-west-2:110057505160:dewpoint-alert\
         		--message "$alert"
			touch /tmp/weatherAlertAlarm
			echo "Message sent" date >> $logDir
			date >> $logDir
			sleep 180
		done
	fi
}

# Gets dewpoint from /var/www/weewx/RSS/weewx_rss.xml

dewpoint=`/bin/cat /var/www/weewx/RSS/weewx_rss.xml\
 | grep Dewpoint: | awk '{print $2}' | cut -f1 -d"&"`

if (($(echo "$dewpoint < 36" | bc -l) ));
then
	echo $dewpoint
	alert="Weather Alert! DewPoint is $dewpoint. Start up the wind machine."
	notify $alert
else
	echo "Dewpoint is not below 36 degrees F" >> $logDir
	date >> $logDir
fi
