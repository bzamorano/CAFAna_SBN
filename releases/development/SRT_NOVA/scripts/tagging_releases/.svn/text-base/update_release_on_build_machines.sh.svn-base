#!/bin/bash

#Brief - This script will be used to update the release of NOvA Soft on the build machines

function process_args() 
{

    errorcode=0
    while getopts "hr:-:" opt; do
        if [ "$opt" = "-" ]; then
            opt=$OPTARG
	    fi
        gettingopt=1
        case $opt in
            h)
		usage
                errorcode=1
		;;
	    r)
                TAG_NAME="$OPTARG"
                ;;
	    
        esac
    done
    if [ "$#" != "0" ] && [ "$gettingopt" != "1" ] && [ "$errorcode" != "1" ]; then
	echo -e "\e[01;31mERROR! Invalid argument/option. Try again!\e[0m" >&2
        usage
	errorcode=1
    fi

    return $errorcode
}

function check_args(){

    if [ -z "$TAG_NAME" ];then
	usage
	echo "TAG_NAME \"$TAG_NAME\""
	exit 1;
    fi

}


function usage(){

    echo "Usage: update_release_on_build_machines.sh" >&2
    echo "         -h print this menu" >&2
    echo "         -r <release>" >&2

}

function send_jpd_mail(){

    if [ "$1" == "" ] || [ "$2" == "" ]
    then
        echo "Usage: $FUNCNAME <subject> <body>" >&2
        return;
    fi

    SUBJECT=$1
    BODY=$2
#    ADDRESS="j.p.davies@sussex.ac.uk"
    ADDRESS="jdjonathandavies+nova@googlemail.com"

#    echo "echo -e \"$BODY\" | mail -s \"$SUBJECT\" \"$ADDRESS\""                    
    echo -e "$BODY" | mail -s "$SUBJECT" "$ADDRESS"

}

function do_setup()
{

#1. Find out which system we are on slf5 / slf6                                                                   
    redhat=`cat /etc/redhat-release`
    if [[ "$redhat" =~ "release 6." ]] ; then
	os=slf6
    elif [[ "$redhat" =~ "release 5." ]] ; then
	os=slf5
    else
	echo "Unkown release of slf. redhat $redhat" >&2
	exit 1
    fi


    echo "============================================================" 
    echo "update_release_on_build_machines.sh" 
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo "tag: \"$TAG_NAME\"" 
    echo "os: \"$os\""
    echo "" 
    echo "Date: `date`" 
    echo "============================================================" 

    echo "SRT_PUBLIC_CONTEXT \"$SRT_PUBLIC_CONTEXT\""

#2. Setup nova software
    echo ""
    echo "setting up NOvA software"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++"
    
    if [ "$os" == "slf5" ];then
	source /build/nova/novasoft/setup/setup_nova.sh -5 "/build/nova/novasoft/" -e "/grid/fermiapp/products/common/db:/build/nova/externals:/nova/data/pidlibs/products"  "$@"
    elif [ "$os" == "slf6" ];then
	source /nova/app/home/novasoft/slf6/build/setup/setup_nova.sh -6 "/nova/app/home/novasoft/slf6/build/" "$@"
    else
	echo "Error: Unknown os \"$os\"" >&2
	exit 1
    fi
    
    echo "SRT_PUBLIC_CONTEXT \"$SRT_PUBLIC_CONTEXT\""

}

function update_release(){

#3. Check that the release exists
    echo ""
    echo "Checking the release exists in subversion"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++"
    
    svn ls http://cdcvs.fnal.gov/subversion/novaart.pkgs.svn/tags/$TAG_NAME > /dev/null 2>&1
    RET_CODE=$?
    
    if [ ! $RET_CODE -eq 0 ];then
	echo "Error: Tag \"http://cdcvs.fnal.gov/subversion/novaart.pkgs.svn/tags/$TAG_NAME\" does not exist in subversion (svn) repository" >&2
	exit 1
    else
	echo "release exists in subversion"
    fi
    
    
#4. Update the release
    echo ""
    echo "updating release"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "SRT_PUBLIC_CONTEXT \"$SRT_PUBLIC_CONTEXT\""
    echo "which update-release \"`which update-release`\""
    
    update-release -rel $TAG_NAME
    
#5. Check that the release SRT_DIST/scripts directory exists as minimal success test
    echo ""
    echo "checking that releases/\$TAG_NAME/SRT_NOVA/scripts exists"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++"
    
    SRT_NOVA_DIR=$SRT_DIST/releases/$TAG_NAME/SRT_NOVA/scripts
    echo "\$SRT_DIST/releases/\$TAG_NAME/SRT_NOVA/scripts \"$SRT_NOVA_DIR\""
    if [ -e $SRT_NOVA_DIR ]; then
	echo "It exists"
    else
	echo "Error: release/SRT_NOVA/scripts dir does not exist" &>2
	exit 1
    fi

}



function main(){

    process_args "$@"
    check_args
    do_setup
    update_release
    exit 0    

}

main "$@"
