#!/bin/sh 

#name  : netserver diagnosic tool
#written by : james johnston
#dated  : 19970911
#modified to produce HTML report by David Beveridge
#updated :  19980429
#comments : in development


#declare menu & message variables
log_mess="which log do you want to view?"
file_mess="which file do you want to view?" 
user_mess="which user do you want to query?"
absent_mess="the selected service is not running on this machine,"
change_mess="you can telnet to the other box & run the same script there"
err_mess="menu input not recognized, try again" 

path10="/var/spool/mail"

#function definitions

countmess () {
        shift
        for i
        do
                if [ -d $1 ]
                then
                        echo '$1 \c'
                        ls $1/inbox | grep -c .AAA.
                fi
                shift
        done
}

if [ `uname` = Linux ]
then
        echo "From: $USER@$HOSTNAME"
        echo "To: Administrator"
        echo "Subject: Linux Server Report - `uname -n`"
fi
if [ `uname` = SunOS ]
then
        echo "Subject: Sun Solaris Server Report - `uname -n`"
fi
echo "Date: `date`"
echo 'MIME-Version: 1.0'
echo 'Content-Type: text/html; charset=us-ascii'
echo ""
echo '<HTML>'
echo '<HEAD>'
echo '<TITLE>Server Report</TITLE>'
echo '<LINK REL=stylesheet HREF="/html4.css">'
echo '</HEAD>'
echo '<BODY>'
echo '<H1>Report for server'
uname -n
echo 'as at'
date
echo '</H1>'

echo '<H2>Uptime</H2>'
echo '<PRE>'
uptime
echo '</PRE>'

echo '<H2>Free Disk Space</H2>'
echo '<PRE>'
df -h
echo '</PRE>'

echo '<H2>Disk Mirror Status</H2>'
echo '<PRE>'
cat /proc/mdstat
echo '</PRE>'

if [ `uname` = Linux ]
then
	echo '<H2>Memory</H2>'
	echo '<PRE>'
	cat /proc/meminfo
	echo '</PRE>'
fi

if [ `uname` = SunOS ]
then
        echo '<H2>System Activity Report</H2>'
        echo '<PRE>'
        sar -u 5 5
        echo '</PRE>'

	echo '<H2>System Statistics</H2>'
	echo '<PRE>'
	vmstat 5 5
	echo '</PRE>'

        echo '<H2>Extended Disk Statistics</H2>'
        echo '<PRE>'
        iostat -xtc
        echo '</PRE>'

        echo '<H2>Swap Area</H2>'
        echo '<PRE>'
        swap -l
        echo '</PRE>'

        echo '<H2>Swap Resources</H2>'
        echo '<PRE>'
        swap -s
        echo '</PRE>'

        echo '<H2>Users with no password set</H2>'
        echo '<PRE>'
        logins -p
        echo '</PRE>'
fi

#echo '<H2>Mail Statistics</H2>'
#echo '<PRE>'
#mailstats
#echo '</PRE>'

echo '<H2>Mail Queue</H2>'
echo '<PRE>'
mailq
echo '</PRE>'

if [ -d "$path10 SKIP THIS" ]
then
        cd $path10
        echo '<H2>Mailbox Messages Count</H2>'
        echo '<PRE>'
        countmess * | sort -n -k 2 | pg
        echo '</PRE>'
fi

#echo '<H2>Finger Information</H2>'
#echo '<PRE>'
#finger
#echo '</PRE>'

#echo '<H2>Disk Usage of home directories</H2>'
#echo '<PRE>'
#du /home | sort -n -r
#echo '</PRE>'

if [ `uname` = Linux ]
then
	#echo '<H2>Logins</H2>'
	#echo '<PRE>'
	#last
	#echo '</PRE>'

	echo '<H2>Hardware Information</H2>'
	echo '<H4>CPU</H4>'
	echo '<PRE>'
	cat /proc/cpuinfo
	echo '</PRE>'

	echo '<H4>PCI Bus</H4>'
	echo '<PRE>'
	/usr/bin/lspci
	echo '</PRE>'

	echo '<H4>IO Ports</H4>'
	echo '<PRE>'
	cat /proc/ioports
	echo '</PRE>'

	echo '<H4>Interrupts</H4>'
	echo '<PRE>'
	cat /proc/interrupts
	echo '</PRE>'
fi

echo '<H2>Processes</h2><Pre>'
ps ax

exit 0
