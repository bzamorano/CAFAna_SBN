#!/usr/bin/env bash

#Author: j.p.davies@sussex.ac.uk

#Date: 1st May 2015

#Brief: Download an xml file containing the configuration from NOvA Jenkins jobs


function echo-err(){
    echo "$@" >&2
}

function usage(){

    echo-err "Usage: `basename $0`"
    echo-err ""
    echo-err "Options:"
    echo-err "          -h/--help    print this menu"
    echo-err "          -l           list jobs then exit"
    echo-err "          -d           set job directory to list (default is \"Nova\")"
    echo-err "          -j <jobname> get configuration for <jobname>"
    echo-err "          -i <private key> set the ssh private key to use for authentication (NB. the associated public key must be installed on the Jenkins server"
    echo-err "          -o <output-dir> set the output dir for the configuration backups>"
    echo-err ""
}

process_args () {

    JOB_DIR="Nova"
    errorcode=0
    while getopts "hld:o:i:j:-:" opt; do
	if [ "$opt" = "-" ]; then
            opt=$OPTARG
        fi
	gettingopt=1

        case $opt in
	    h | help) 
                usage
		errorcode=1
                ;;
	    l)
		LIST_JOBS=1
		;;
            d)
                JOB_DIR="$OPTARG"
                ;;
	    j)
		JOB_NAME="$OPTARG"
		;;
	    i)
		PRIVATE_KEY="$OPTARG"
		;;
	    o)
		OUTPUT_DIR="$OPTARG"

        esac
    done
    if [ "$#" != "0" ] && [ "$gettingopt" != "1" ] && [ "$errorcode" != "1" ]; then
    	echo-err "ERROR: Invalid argument/option. Try again!"
 	usage
    	errorcode=1
    fi

    if [ -z $PRIVATE_KEY ];then
	PRIVATE_KEY=~/.ssh/id_rsa_jpdavies_novagpvm
    fi

    if [ -z $JOB_NAME ] && [ -z $LIST_JOBS ];then
	echo-err "ERROR: You must either use \"-l\" or \"-j <jobname>\""
	usage
	exit 1
    fi
    return $errorcode

}

function get_jenkins_cli_jar(){

    JENKINS_CLI_FILE=${PWD}/jenkins-cli.jar
    if [ -e $JENKINS_CLI_FILE ];then
	echo-err "ERROR: Jenkins parsing file exists: \"$JENKINS_CLI_FILE\""
	echo-err "       You should remove this file and re-run"
	exit 1
    fi

    wget -O $JENKINS_CLI_FILE https://buildmaster.fnal.gov/jnlpJars/jenkins-cli.jar 2>/dev/null

}

function setup_python_for_json_parsing(){

#Check that pytho has access to the json module that is needed
    python -c "import json" 2>/dev/null;
    RETVAL=$?
    if [ "$RETVAL" == "1" ];then
	echo "INFO: Cannot find python module \"json\" needed for Jenkins build parsing"
	if [ -e /grid/fermiapp/products/nova/externals/setup ];then
	    echo "INFO: Setting up python from /grid/fermiapp/products/nova/externals"
	    source /grid/fermiapp/products/nova/externals/setup
	    setup python v2_7_6
	    RETVAL=$?
	elif [ -e /build/nova/externals/setup ];then
	    echo "INFO: Setting up python from /build/nova/externals"
	    source /build/nova/externals/setup
	    setup python v2_7_6
	    RETVAL=$?
	else
	    echo "INFO: Could not find ups database to setup python from"
	    RETVAL=1
	fi
    fi

#Test if python was setup correctly
    if [ "$RETVAL" == "1" ];then
	echo "ERROR: Could not  set up python."
	exit 1
    fi
}

function list_jobs(){

    echo-err "INFO: Available NOvA Jobs"
    JENKINS_NOVA_BUILDS_JSON=${PWD}/jenkins-nova-builds.json

    if [ -e $JENKINS_NOVA_BUILDS_JSON ];then
	echo-err "ERROR: Jenkins NOvA builds info JSON file exists: \"$JENKINS_NOVA_BUILDS_JSON\""
	echo-err "       You should remove this file and re-run"
	exit 1
    fi

    echo "Checking job directory: https://buildmaster.fnal.gov/view/${JOB_DIR}/api/json"
    wget -O $JENKINS_NOVA_BUILDS_JSON https://buildmaster.fnal.gov/view/${JOB_DIR}/api/json  2>/dev/null

    python -mjson.tool $JENKINS_NOVA_BUILDS_JSON | grep "name" | grep -v "\"Nova\"" | cut -d ":" -f 2 | cut -d '"' -f 2 | while read -r line;
    do 
	echo $line
    done

}

function get_job_xml(){

    echo-err "INFO: Getting XML file for job \"$JOB_NAME\" save as \"${JOB_NAME}.xml\""
#   Not using ssh authentication anymore, 
#   java -jar $JENKINS_CLI_FILE -s https://buildmaster.fnal.gov/ -i $PRIVATE_KEY get-job $JOB_NAME > ${JOB_NAME}.xml
#   Begin non ssh suthentication steps
    TEMP_CERTIFICATE=${PWD}/jenkins-backup-kx509cert
    echo-err "INFO: Getting temporary kx509 certificate \"$TEMP_CERTIFICATE\""
    kx509 -q -o $TEMP_CERTIFICATE 2>/dev/null
    retval=$?
    if [ "$retval" -ne 0 ];then
	echo-err "ERROR: Obtaining kx509 certificate"
	clean_up
	exit 1
    fi

    if [ -z $OUTPUT_DIR ];then
	OUTPUT_DIR=${PWD}
    fi
    JOB_CONFIG_FILE=${OUTPUT_DIR}/${JOB_NAME}.xml

    curl -E $TEMP_CERTIFICATE https://buildmaster.fnal.gov/job/${JOB_NAME}/config.xml > ${JOB_CONFIG_FILE} 2>/dev/null
#   End non ssh authentication steps
    retval=$?
    if [ "$retval" -ne 0 ];then
	echo-err "ERROR: Obtaining \"${JOB_CONFIG_FILE}\""
	clean_up
	exit 1
    fi
    echo-err "INFO: Successfully downloading xml configuration \"${JOB_CONFIG_FILE}\""

}

function clean_up(){

    for file in $JENKINS_CLI_FILE $JENKINS_NOVA_BUILDS_JSON $TEMP_CERTIFICATE
    do
	if [ -e $file ];then
	    rm $file
	fi
    done
}

function main(){

    process_args $*
#   Only needed for ssh key authenticated backups
#   get_jenkins_cli_jar
    setup_python_for_json_parsing
    if [ ! -z $LIST_JOBS  ];then
	list_jobs
	clean_up
	exit 0
    fi
    get_job_xml
    clean_up
}

main $*
