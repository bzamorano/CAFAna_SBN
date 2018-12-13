#!/bin/bash

#Name: clean_up_rel_send_to_gpvm.sh
#Brief: Clean up the release (remove all the unneeded files), then copy it to GPVM nodes

function usage(){

    echo "Usage: clean_up_rel_send_to_gpvm.sh [options]" >&2
    echo "options:" >&2
    echo "          -r:        specifies release" >&2
    echo "          -f:        force - if the code exists on GPVM remove then replace it" >&2
    echo "          -o:        set os to \"slf5\" or \"slf6\"" >&2

}


function process_args() 
{

    errorcode=0
    while getopts "hfo:r:-:" opt; do
        if [ "$opt" = "-" ]; then
            opt=$OPTARG
	    fi
        gettingopt=1
        case $opt in
	    f)
		DO_FORCE=1
		;;
            h)
		usage
                errorcode=1
		;;
	    r)
                release=$OPTARG
                ;;
	    o)
		os=$OPTARG
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


function init()
{

    process_args $*

#0. Set and source some useful stuff
    source /nova/app/home/novasoft/.bashrc
#    setup_jpdavies

#1. Find out which system we are on slf5 / slf6                                                                   
    
    redhat=`cat /etc/redhat-release`
    if [[ "$redhat" =~ "release 6." ]] || [[ "$os" == "slf6" ]] ; then
	os=slf6
    elif [[ "$redhat" =~ "release 5." ]] || [[ "$os" == "slf5" ]]; then
	os=slf5
    else
	echo "Unkown release of slf. redhat $redhat os $os" >&2
	exit 1
    fi

    if [ -z $release ];
    then
	usage
	exit 1
    fi
    
    echo ""
    echo "=================================================="
    echo "clean_up_rel_send_to_gpvm.sh"
    echo "=================================================="
    echo "OS: \"$os\""
    echo "release: \"$release\""
    echo ""
    
    if [ "$os" == "slf5" ];then
	BUILD_DIR=/build/nova/novasoft
	GPVM_INSTALL_DIR=/nova/app/home/novasoft/nova_offline_software/novasoft/slf5/novasoft
	
    elif [ "$os" == "slf6" ];then
	BUILD_DIR=/nova/app/home/novasoft/slf6/build
	GPVM_INSTALL_DIR=/nova/app/home/novasoft/nova_offline_software/novasoft/slf6/novasoft
	
    else
	echo "Unkown release \"$release\"" >&2
	exit 1
    fi
}


function cleanRel()
{

#2. Go to the build directory and remove the unneeded files
    echo ""
    echo "Removing unneeded files"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++"
    
    if [ -e $BUILD_DIR/releases/$release ] && [ ! -z $release ];then
	cd $BUILD_DIR
	
    else
	echo "Error: \$BUILD_DIR/releases/\$release does not exist" >&2
	echo "\$BUILD_DIR/releases/\$release \"$BUILD_DIR/release/$release\"" >&2
	exit 1
    fi
    
    
    rm -rf $BUILD_DIR/releases/$release/tmp/*
    rm -rf $BUILD_DIR/releases/$release/lib/*/*.o
    
}    

function copyToGPVM()
{

#4. Copy the files to the GPVM install location
    echo ""
    echo "Copying release to GPVM nodes"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++"
    
    cd $BUILD_DIR/releases
    
    if [ -e $GPVM_INSTALL_DIR/releases/$release ];then
	echo "Error: GPVM install location already has this release directory" >&2
	echo "\$GPVM_INSTALL_DIR/releases/\$release \"$GPVM_INSTALL_DIR/releases/$release\"" >&2
	
	if [ $DO_FORCE ];then
	    echo "Don't worry - you selected -f [force] so we'll overwrite that release directory"
	    rm -rf $GPVM_INSTALL_DIR/releases/$release
	    cp -r $release $GPVM_INSTALL_DIR/releases/
            if [ $? -ne 0 ];then
                echo "ERROR copying release into place"
                exit 1
            fi
            
         echo ""
         echo "Creating file ${GPVM_INSTALL_DIR}/releases/${release}/distribution_date with content \"`date +'%F %T'`\""
         echo ""

         echo `date +'%F %T'` > ${GPVM_INSTALL_DIR}/releases/${release}/distribution_date
	 	 
#FIXME -- due to disk space issues on /grid/fermiapp 
        if [ "$os" == "slf5" ];then
            ln -sfT $GPVM_INSTALL_DIR/releases/${release} /grid/fermiapp/nova/novaart/novasvn/releases/${release}
	elif [ "$os" == "slf6" ];then
            ln -sfT $GPVM_INSTALL_DIR/releases/${release} /nova/app/home/novasoft/slf6/novasoft/releases/${release}
	fi
	    return 0
	else
	    return 0
	fi
	
    else

	cp -r $release $GPVM_INSTALL_DIR/releases/
        if [ $? -ne 0 ];then
            echo "ERROR copying release into place"
            exit 1
        fi

	touch $GPVM_INSTALL_DIR/releases/${release}/DONE

#FIXME -- due to disk space issues on /grid/fermiapp
	if [ "$os" == "slf5" ];then
	    ln -sfT $GPVM_INSTALL_DIR/releases/${release} /grid/fermiapp/nova/novaart/novasvn/releases/${release}
	elif [ "$os" == "slf6" ];then
            ln -sfT $GPVM_INSTALL_DIR/releases/${release} /nova/app/home/novasoft/slf6/novasoft/releases/${release}
	fi
    fi
}


function main(){
    
    init $*
    cleanRel
    copyToGPVM
    exit 0

}

main $*




