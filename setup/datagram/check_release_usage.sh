#!/bin/bash

#Brief: Little script to check the usage of NOvA offline software releases on the GPVM nodes
#       It just parses the datagram log files that are created for each day (and appended when
#       anyone sets up NOvA soft)

#Author: Jonathan Davies j.p.davies@sussex.ac.uk

#Log line format: Details of the format of the entries in the log file, for ref. see datagram_client.py and datagram_server.py
#                 Before the DATAGRAM_VERSION was introduced
#                 date                address  : "shell user release kernel sl"               
#                 %Y-%m-%d %H:%M:%S   %s       : " %s     %s    %s    %s    %s"
#                 After the DATAGRAM_VERSION was introduced
#                 date                address  : "shell user release kernel sl DATAGRAM_VERSION ..."
#                 %Y-%m-%d %H:%M:%S   %s       : " %s     %s    %s    %s    %s      %s             "
#
#                 DATAGRAM_VERSION v0.1
#                 ...              srt_public_context products


function usage(){

    echo "Usage: check_release_usage.sh [options]" >&2
    echo "options:" >&2
    echo "          -r:        specifies release" >&2
    echo "          -h:        print this help menu" >&2
    echo "          -p:        specifies time frame in months (default 6)" >&2
    echo "          -d:        specifies a period in days. For finer grain checking than the \"-p\" option" >&2
    echo "          --ups:     specifies to search for novasoft ups product instead of release" >&2
    echo "          -D:        DEBUG mode"
    echo "          -e:        Exclude list. Either a list of people seperated by \"\|\" (-e \"foo\|bar\|etc\") or one name per option (-e \"foo\" -e \"bar\" -e \"etc\")" >&2
}


function process_args() 
{

    errorcode=0
    DEBUG=0
    while getopts "hDe:p:r:d:-:" opt; do
        if [ "$opt" = "-" ]; then
            opt=$OPTARG
	fi
        gettingopt=1
        case $opt in
            h | help)
		errorcode=1
		;;
            r)
		release="$OPTARG"
		;;
    	    p)
		period_months="$OPTARG"
		;;
            ups)
# email from brebel 5th Jan 2015 - ups_build string added to datagram logging for novasoft ups product setup
# previous to this we can use e6.debug and e6.prof strings to find novasoft ups product setup
		release='ups_build\|e6.debug\|e6.prof'
		;;
	    d)
		period_days="$OPTARG"
		;;
            D)
		DEBUG=1
		;;
	    e)
		if [ -z $DO_EXCLUDE_LIST ];then
		    EXCLUDE_LIST="$OPTARG"
		else
		    EXCLUDE_LIST="$EXCLUDE_LIST\|$OPTARG"
		fi
		DO_EXCLUDE_LIST=1
		;;
        esac
    done


    if [ "$#" != "0" ] && [ "$gettingopt" != "1" ] && [ "$errorcode" != "1" ]; then
        echo -e "\e[01;31mERROR! Invalid argument/option. Try again!\e[0m" >&2 
        usage
    	errorcode=1
    fi

    if [ -z $release ];then
    	usage
	errorcode=1
    fi

    if [ -z $period_months ];then
    	period_months=6;
    fi


    return $errorcode
}

function check_usage(){
    
    days_ago=0
    days_ago_limit=$(( period_months * 31 ))

    if [ ! -z $period_days ];then
	days_ago_limit=$period_days
    fi

    count_usage_total=0

    while [ $days_ago -lt $days_ago_limit ];do

	date_to_check=$(date +"%Y %m %d" --date="${days_ago} day ago")
	
	logtag=$(date +%Y%m%d_ --date="${days_ago} day ago")
	
	LOGFILE=/nova/app/home/novasoft/datagram_logs/zzz_${logtag}*.log
 
	if ls $LOGFILE* 1> /dev/null 2>&1; then
	    
	    if [ $DO_EXCLUDE_LIST ];then
		count_usage=`cat $LOGFILE* | grep "$release" | grep -v "$EXCLUDE_LIST" | wc -l`
	    else
		count_usage=`cat $LOGFILE* | grep "$release" | wc -l`
	    fi
	    
	    if [ $count_usage -gt 0 ] && [ "$DEBUG" == "1" ];then
		echo "Checking for \"$release\" on date \"$date_to_check\" found \"$count_usage\" uses"
		if [ $DO_EXCLUDE_LIST ];then
		    cat $LOGFILE* | grep "$release" | grep -v "$EXCLUDE_LIST" 
		else
		    cat $LOGFILE* | grep "$release"
		fi
	    fi
	    count_usage_total=$(( count_usage_total + count_usage ))
	    
	fi
	
	days_ago=$(( days_ago + 1 ))
	
    done
    
    echo "$release $period_months $count_usage_total"

}

function main(){

    process_args $* || exit 1

    check_usage
}

main $*
