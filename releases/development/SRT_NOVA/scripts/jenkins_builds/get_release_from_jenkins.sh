#!/usr/bin/env bash

function usage(){

    echo "*******************************************************************" >&2
    echo "*Usage: `basename $0` [options]                     *" >&2
    echo "*options:                                                         *" >&2
    echo "*    -h         prints this menu                                  *" >&2
    echo "*    -o         set the OS                                        *" >&2
    echo "*               <slf5>, <slf6>                                    *" >&2
    echo "*    -r         specify release                                   *" >&2
    echo "*               <development>  or <tagged-release>                *" >&2
    echo "*               <tagged-release> of form S15-01-12                *" >&2
    echo "*               if unset will attempt to auto-detect              *" >&2
    echo "*    -n         set the build number to get from Jenkins          *" >&2
    echo "*    -f         force download - remove any current tarballs      *" >&2
    echo "*    -x         also extract tarball                              *" >&2
    echo "*******************************************************************" >&2
    return 1 

}

function echo_setup(){
    echo "SETUP : $@"
}
function echo_info(){
    echo "INFO  : $@"
}
function echo_warn(){
    echo "WARN  : $@"
}
function echo_error(){
    echo "ERROR : $@" >&2
}

process_args () {

    errorcode=0
    while getopts "hfxr:n:o:-:" opt; do
	if [ "$opt" = "-" ]; then
            opt=$OPTARG
        fi
	gettingopt=1

        case $opt in
	    h | help) 
                usage
		errorcode=1
                ;;
	    f)
		FORCE_DOWNLOAD=1
		;;
	    x) 
		EXTRACT_TARBALL=1
		;;
	    r)
		RELEASE=$OPTARG
		;;
	    n)
		BUILD_NUMBER=$OPTARG
		;;
	    o)
		this_os=$OPTARG
		;;
        esac
    done
    if [ "$#" != "0" ] && [ "$gettingopt" != "1" ] && [ "$errorcode" != "1" ]; then
    	print_error " Invalid argument/option. Try again!"
 	usage
    	errorcode=1
    fi

    echo_setup "get_release_from_jenkins.sh started at `date`" 

    return $errorcode

}

function check_lock_file(){

    #Make sure that two instances aren't running
    echo_setup "Checking LOCK_FILE" 

    if [ "$RELEASE" == "development" ];then
	GET_RELEASE_FROM_JENKINKS_LOCK_FILE=~/.get_nightly_from_jenkins_lock_file_${this_os}
    else
	GET_RELEASE_FROM_JENKINKS_LOCK_FILE=~/.get_release_from_jenkins_lock_file_${this_os}
    fi
    if [ -e $GET_RELEASE_FROM_JENKINKS_LOCK_FILE ];then
	echo_setup "Lock file \"$GET_RELEASE_FROM_JENKINKS_LOCK_FILE\" exists" 
#	cat $GET_RELEASE_FROM_JENKINKS_LOCK_FILE
	echo "" >&2
	echo "" >&2
	exit 1
    fi
    echo_setup "LOCK_FILE \"$GET_RELEASE_FROM_JENKINKS_LOCK_FILE\" does not exist - running" 
    echo "Running - Date \"`date`\"" >> $GET_RELEASE_FROM_JENKINKS_LOCK_FILE
}

function remove_lock_file(){

    if [ -e $GET_RELEASE_FROM_JENKINKS_LOCK_FILE ];then
	echo_info "Removing LOCK_FILE" 
	rm $GET_RELEASE_FROM_JENKINKS_LOCK_FILE
    fi
    echo_info "Finished at `date`" 
    echo "" >&2
    echo "" >&2

}


function check_url(){
#    echo_info "check_url"
##    echo INFO: Checking URL $1 >&2
#    wget --spider --no-check-certificate $1 &> /dev/null
#    RETVAL=$?
#    if [ "$RETVAL" != "0" ]; then
#	echo_error "URL $1 - does not exist"
#	return $RETVAL
#    else
#	echo_info "URL $1 - exists"
#    fi
#    

    #Now check that the build is complete!
    #We need to remove the 'artifact/buildout' part and add '/api/json'
    API_URL=${URL%/artifact/buildout*}
    API_URL=${API_URL}/api/json
    wget --spider --no-check-certificate $API_URL &> /dev/null
    RETVAL=$?
    if [ "$RETVAL" != "0" ]; then
	echo_error "Build does not exist"
	return $RETVAL
    fi

    if [ -z $RELEASE ];then
	echo_info "Finding release name"

        #Get the release name from the jenkins api json file
        #The only way to do this is to parse the "fileName" variable
        # fileName = novabuild.${RELEASE}.SLF{5/6}.{debug/maxopt}.tar.bz2
#	RELEASE=`curl $API_URL --silent | python -mjson.tool | grep fileName | grep debug | cut -d ":" -f 2 | cut -d '"' -f 2 | cut -d "." -f 2`
	RELEASE=`curl $API_URL --silent | python -mjson.tool | grep fileName | grep debug | cut -d ":" -f 2 | cut -d '"' -f 2`
        RELEASE=${RELEASE%.SLF*}
        RELEASE=${RELEASE#novabuild.}
	
	if [ "$RETVAL" == "1" ];then
	    echo_error "Failed to parse api url"
	    return 1
	fi
	echo_info "RELEASE is $RELEASE"
    fi #RELEASE

    if [ -z $BUILD_SUCCESS ];then
	RESULT=`curl $API_URL --silent | python -mjson.tool | grep '"result"' | cut -d ":" -f 2 | cut -d '"' -f 2`
	if [ "$RESULT" == "SUCCESS" ];then
	    echo_info  "Build result is SUCCESS"
	    BUILD_SUCCESS=1
	else
	    echo_error "Build result is $RESULT"
	    BUILD_SUCCESS=0
	    return 1
	fi
    elif [ "$BUILD_SUCCESS" != 1 ];then
	return 1
    fi #BUILD_SUCCESS


    if [ -z $BUILD_COMPLETE ];then
	curl $API_URL --silent | grep --color building\":true &>/dev/null  
	RETVAL=$?
    # RETVAL==1 means complete, RETVAL==0 means incomplete
	if [ "$RETVAL" == "1" ]; then
	    echo_info "Build complete"
	    BUILD_COMPLETE=1
	    return 0
	else
	    echo_error "Build incomplete"
	    BUILD_COMPLETE=0
	    return 1
	fi
    elif [ "$BUILD_COMPLETE" != 1 ];then
	return 1
    fi #BUILD_COMPLETE

}

function get_tarball(){
    echo_info "get_tarball $1"
    check_url $1
    RETVAL=$?
    if [ "$RETVAL" != 0 ];then
	echo_error "check_url returned $RETVAL"
	return $RETVAL
    fi
    cd $2

    #Check if tarball exists
    tarball=`echo $1 | rev | cut -d "/" -f 1 | rev`
    if [ -f $2/$tarball ] ; then
	echo_warn "tarball $tarball already exists" 
	if [ ! -z $FORCE_DOWNLOAD ];then
	    echo_warn "Forcing download" 
	    rm $tarball
	else
	    echo_error "Not downloading - use \"-f\" option to force download" 
	    RETVAL=1
	    return $RETVAL
	fi
    else
	echo_info "Tarball $tarball does not exist - downloading" >&2
    fi
    
    echo_info "Downloading tarball $1"
    wget --no-check-certificate $1 &> /dev/null
    RETVAL=$?

    if [ "$RETVAL" != 0 ];then
	echo_error "FAILED to \"wget $1\""
	return 1
    fi

    #Extract the tarball
    if [ ! -z $EXTRACT_TARBALL ];then
	echo_info "Extracting tarball $tarball" 
	tar -xf $tarball
	echo_info "Removing tarball" >&2
	rm -rf $tarball
    fi
}

function do_setup(){

#get OS
    if [ "$this_os" == "slf5" ];then
	DOWNLOAD_DIR=/build/nova/novasoft/releases/Jenkins_Downloads
	THIS_OS=SLF5
    elif [ "$this_os" == "slf6" ];then
	DOWNLOAD_DIR=/nova/app/home/novasoft/slf6/build/releases/Jenkins_Downloads
	THIS_OS=SLF6
    else
	usage
	remove_lock_file
	exit 1
    fi
    
    if [ "$RELEASE" == "development" ];then
	URL_BASE=https://buildmaster.fnal.gov/view/Nova/job/nova_SRT_${this_os}_nightly_build_output
	BUILD_NUM_FILE=${DOWNLOAD_DIR}/next_build_number_nightly
	BUILD_RECORD_FILE=${DOWNLOAD_DIR}/tars/build_record_nightly
    else
	URL_BASE=https://buildmaster.fnal.gov/view/Nova/job/nova_SRT_${this_os}_release_build_output
	BUILD_NUM_FILE=${DOWNLOAD_DIR}/next_build_number_release
	BUILD_RECORD_FILE=${DOWNLOAD_DIR}/tars/build_record_release
    fi

#Check that pytho has access to the json module that is needed
    python -c "import json" 2>/dev/null;
    RETVAL=$?
    if [ "$RETVAL" == "1" ];then
#	echo_setup "Cannot find python module \"json\" needed for Jenkins build parsing"
	if [ -e /grid/fermiapp/products/nova/externals/setup ];then
#	    echo_setup "Setting up python from /grid/fermiapp/products/nova/externals"
	    source /grid/fermiapp/products/nova/externals/setup
	    setup python v2_7_6
	    RETVAL=$?
	elif [ -e /build/nova/externals/setup ];then
#	    echo_setup "Setting up python from /build/nova/externals"
	    source /build/nova/externals/setup
	    setup python v2_7_6
	    RETVAL=$?
	else
	    echo_error "Could not find ups database to setup python from"
	    RETVAL=1
	fi
    fi

#Test if python was setup correctly
    if [ "$RETVAL" == "1" ];then
	echo_error "Could not  set up python."
	remove_lock_file
	exit 1
    fi
    
#Get build number
    if [ -z $BUILD_NUMBER ];then 
	if [ ! -e ${BUILD_NUM_FILE} ];then
	    THIS_BUILD_NUM=1
	else
	    THIS_BUILD_NUM=`cat ${BUILD_NUM_FILE}`
	fi
    else
	THIS_BUILD_NUM=$BUILD_NUMBER
    fi
    echo_info "THIS_BUILD_NUM $THIS_BUILD_NUM"
}

function download_release(){
    URL=${URL_BASE}/${THIS_BUILD_NUM}/artifact/buildout
    check_url $URL

    RETVAL=$?

    if [ "$RETVAL" == "0" ];then
	NEW_BUILD_NUMBER=$((THIS_BUILD_NUM + 1));
    else
	#If the release URL doesn't exist bail
	echo_error "Build not available. Exiting"
	remove_lock_file
	exit 1
    fi
    
   if [ ! -e ${DOWNLOAD_DIR}/tars ];then
       mkdir -p ${DOWNLOAD_DIR}/tars
   fi
    
    
    URL=${URL_BASE}/${THIS_BUILD_NUM}/artifact/buildout/novabuild.${RELEASE}.${THIS_OS}.debug.tar.bz2
    get_tarball $URL ${DOWNLOAD_DIR}/tars
    URL=${URL_BASE}/${THIS_BUILD_NUM}/artifact/buildout/novabuild.${RELEASE}.${THIS_OS}.maxopt.tar.bz2
    get_tarball $URL ${DOWNLOAD_DIR}/tars


    
#Update build number
    echo $NEW_BUILD_NUMBER > ${BUILD_NUM_FILE}

#Keep record of the downloaded files
    touch ${BUILD_RECORD_FILE}
    echo_info "Updating build record file" 
    echo RELEASE $RELEASE THIS_OS $THIS_OS BUILD_NUMBER $THIS_BUILD_NUM `date +"%H:%M:%S %Y-%m-%d"` | cat - ${BUILD_RECORD_FILE} > ~/.get_release_from_jenkins_build_record_${os} && mv ~/.get_release_from_jenkins_build_record_${os} ${BUILD_RECORD_FILE}

    echo_info "Copying build record file to /nusoft/app/web/htdoc/nova/novasoft/jenkins_logs/$this_os/" 
    cp $BUILD_RECORD_FILE /nusoft/app/web/htdoc/nova/novasoft/jenkins_logs/${this_os}/

}

function move_release_into_place(){
    

    if [ "$this_os" == "slf5" ];then
	RELEASE_DIR=/build/nova/novasoft/releases
	THIS_OS=SLF5
    elif [ "$this_os" == "slf6" ];then
	RELEASE_DIR=/nova/app/home/novasoft/slf6/build/releases
	THIS_OS=SLF6
    else
	echo_error "Wrong OS this_os \"$this_os\" THIS_OS \"$THIS_OS\" RELEASE_DIR \"$RELEASE_DIR\"" 
	usage
	remove_lock_file
	exit 1
    fi

    DOWNLOAD_DIR=${RELEASE_DIR}/Jenkins_Downloads/tars
    
    echo_info "Moving release $DOWNLOAD_DIR/$RELEASE into $RELEASE_DIR/" >&2
    if [ -d $RELEASE_DIR/$RELEASE ];then
	rm -rf $RELEASE_DIR/$RELEASE
    fi
    mv $DOWNLOAD_DIR/$RELEASE/ $RELEASE_DIR/

}


function main(){

    process_args $*
    check_lock_file
    do_setup
    download_release
    if [ ! -z $EXTRACT_TARBALL ];then
	move_release_into_place
    else
	echo_error "Not extracting release - use \"-x\" option to cause extraction" 
    fi
    remove_lock_file

}

main $*
