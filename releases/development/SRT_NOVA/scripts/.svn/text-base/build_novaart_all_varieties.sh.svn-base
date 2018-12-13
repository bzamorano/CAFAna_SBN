#!/bin/bash

# Wrapper Script to build the NOvA-ART software.
# September 09 2014 - Jonathan Davies
# Brief: Build NOvA offline in various configurations

# We currently have 3 sets of options for builds

# Operating System (OS)     slf5 : slf6
# Branch                    development : first-ana
# Compiler options          debug : maxopt

# Therefore there are 2^3 == 8 different builds
# This script can carry out any of these builds

DEBUG=0
###################################################################################
# Prints a help menu when the script is invoked with -h option or invalid option
###################################################################################

usage () {
    echo "*******************************************************************" >&2
    echo "*Usage: `basename $0` [options]                                   *" >&2
    echo "*options:                                                         *" >&2
    echo "*    -h         prints this menu                                  *" >&2
    echo "*    -5         set operating system to slf5                      *" >&2
    echo "*    -6         set operating system to slf6                      *" >&2
    echo "*    -r         set the release                                   *" >&2
    echo "*               <development> , <first-ana> or <tagged-release>   *" >&2
    echo "*               <tagged-release> of form S15-01-12 / FA15-01-12   *" >&2
    echo "*    -b         set the build                                     *" >&2
    echo "*               <debug> or <maxopt>                               *" >&2
    echo "*    -u         also update the release                           *" >&2    
    echo "*    -d         debugging mode                                    *" >&2
    echo "*    -l         set a base directory for the build, all the       *" >&2
    echo "*               scripts and outputs will be relative to this,     *" >&2
    echo "*               else hard coded build machine locations are used  *" >&2
    echo "*    -e         externals path                                    *" >&2
    echo "*******************************************************************" >&2
    return 1 
}


###################################################################################
# Sets default values for the build parameters
###################################################################################


set_defaults () {
    os="slf5"
    release="development"
    build="debug"
    slf5=0
    slf6=0
    DEBUG=0
    basedir=""
}


###################################################################################
# Checks the OS [ slf5 : slf6 ]
###################################################################################

process_os(){


    redhat=`cat /etc/redhat-release`
    if [ "$slf5" == "1" ] && [ "$slf6" == "1" ]
    then
    	echo -e "\e[01;31mERROR! Cannot slf5 and slf6 requested. Choose one or the other\e[0m" >&2
	usage
	return 1;
    elif [ "$slf6" == "1" ] 
    then
	if [[ "$redhat" =~ "release 5." ]] 
	then
	    echo -e "\e[01;31mERROR! OS set to slf5 but this is NOT an slf5 machine!\e[0m" >&2
	    usage
	    return 1;
	else	    
	    os="slf6"
	    return 0;
	fi
    elif [ "$slf5" == "1" ]
    then
	if [[ "$redhat" =~ "release 6." ]] 
	then
	    echo -e "\e[01;31mERROR! OS set to slf6 but this is NOT an slf6 machine!\e[0m" >&2
	    usage
	    return 1;
	else	    
	    os="slf5"
	    return 0;
	fi
    else
	if [[ "$redhat" =~ "release 5." ]]
	then
	    os="slf5"
	    return 0;
	elif [[ "$redhat" =~ "release 6." ]]
	then
	    os="slf6"
	    return 0;

	else
	    echo -e "\e[01;31mERROR! Unkown OS \"$redhat\".\e[0m" >&2
	    usage
	    return 1;
	fi
    fi
    
    usage
    return 1;
}


###################################################################################
# Check the release [development : first-ana]
###################################################################################

process_release(){

    if [ "$release" == "development" ]
    then
	return 0;
    elif [ "$release" == "first-ana" ]
    then
	return 0;
    elif [ "$release" == "" ]
    then	
	echo -e "\e[01;31mERROR! Unkown release \"$release\".\e[0m" >&2
	usage 
	return 1
    else

	svn ls http://cdcvs.fnal.gov/subversion/novaart.pkgs.svn/tags/${release} > /dev/null 2>&1
	RET_CODE=$?
	
	if [ ! $RET_CODE -eq 0 ];then
	echo -e "\e[01;31mERROR! Unkown release \"$release\".\e[0m" >&2
	    usage
	    return 1
	else
	    return 0
	fi

    fi

    usage 
    return 1

}

###################################################################################
# Check the build [ debug : maxopt ]
###################################################################################

process_build(){

    if [ "$build" == "debug" ]
    then
	return 0;
    elif [ "$build" == "maxopt" ]
    then
	return 0;
    else
	echo -e "\e[01;31mERROR! Unkown build. Choose \"debug\" or \"max-opt\".\e[0m" >&2
	usage
	return 1;
    fi

    usage
    return 1;
}

###################################################################################
# Check the arguments passed to the script
###################################################################################

process_args () {

    errorcode=0
    while getopts "h56due:r:b:l:-:" opt; do
	if [ "$opt" = "-" ]; then
            opt=$OPTARG
        fi
	gettingopt=1

        case $opt in
	    h | help) 
                usage
		errorcode=1
                ;;
	    5)
		slf5=1
		;;
	    6)
		slf6=1
		;;
	    d)
		DEBUG=1
		echo ""
		echo ""
		echo "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
		echo "=+=+=+=+=+=+=+=+=+=+=+ DEBUGGING MODE =+=+=+=+=+=+=+=+=+=+=+"
		echo "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
		echo ""
		echo ""
		;;
	    u)
		do_update_release=1
		;;
	    e)
		the_externals_path=$OPTARG
		;;
	    r)
		release=$OPTARG
		;;
	    b)
		build=$OPTARG
		;;
	    l)
		basedir=$OPTARG
		BASEDIR_SET=1
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


###################################################################################
# This will set the variables necessary for building
# They depend on [os] [build] [release]
###################################################################################

set_vars(){

##os
    if [ "$os" == "slf5" ]
    then
	if [ -z $basedir ];then
	    basedir=/build/nova/novasoft
	fi
	HOSTNAME=novabuild01.fnal.gov
	setup_nova_script=${basedir}/setup/setup_nova.sh

	if [ -z $the_externals_path ];then
	    setup_nova_os_options="-5 ${basedir} -e /grid/fermiapp/products/common/db:/build/nova/externals:/nova/data/pidlibs/products"
	else
	    setup_nova_os_options="-5 ${basedir} -e ${the_externals_path}"
	fi

	if [ "$DEBUG" == "1" ]
	then
	    logfile_dir=${basedir}/logs_testing 
	else
	    logfile_dir=${basedir}/logs
	fi
	mkdir -p $logfile_dir


	logfile_name_os=""
	webdir_name_os=""
	temp_build_script_os=${basedir}/releases/development/SRT_NOVA/scripts/temp_build_script_slf5
	
	if [ "$DEBUG" == "1" ]
	then
	    temp_build_script_copy_os=${basedir}/logs_testing/temp_build_script_slf5 
	    mkdir -p ${basedir}/logs_testing/
	else
	    temp_build_script_copy_os=${basedir}/logs/temp_build_script_slf5 
	    mkdir -p ${basedir}/logs/
	fi

    elif [ "$os" == "slf6" ]
    then
	if [ -z $basedir ];then
	    basedir=/nova/app/home/novasoft/slf6/build
	fi
	HOSTNAME=novagpvm09.fnal.gov
	setup_nova_script=${basedir}/setup/setup_nova.sh

	if [ -z $the_externals_path ];then
	    setup_nova_os_options="-6 ${basedir} -e /nusoft/app/externals:/grid/fermiapp/products/common/db:/nova/data/pidlibs/products:/grid/fermiapp/products/nova/externals"
	else
	    setup_nova_os_options="-6 ${basedir} -e ${the_externals_path}"
	fi


	if [ "$DEBUG" == "1" ]
	then
	    logfile_dir=${basedir}/logs_testing 
	else
	    logfile_dir=${basedir}/logs
	fi
	mkdir -p $logfile_dir


	logfile_name_os="_slf6"
	webdir_name_os="_slf6"
	temp_build_script_os=${basedir}/releases/development/SRT_NOVA/scripts/temp_build_script_slf6

	if [ "$DEBUG" == "1" ]
	then
	    temp_build_script_copy_os=${basedir}/logs_testing/temp_build_script_slf6 
	    mkdir -p ${basedir}/logs_testing/
	else
	    temp_build_script_copy_os=${basedir}/logs/temp_build_script_slf6
	    mkdir -p ${basedir}/logs/
	fi
    fi

##release
    if [ "$release" == "development" ]
    then
	setup_nova_release_options=""
	logfile_name_release=""
	webdir_name_release=""
	novasoft_build_release_options="-rel development"	
	update_release_opt_release="-rel development"	
	build_log_name=make_nova_build_log
	temp_build_script_release="_development"
    elif [ "$release" == "first-ana" ]
    then
	setup_nova_release_options="-r first-ana"
	logfile_name_release="_branch"
	webdir_name_release="_branch"
	novasoft_build_release_options="-rel first-ana"	
	update_release_opt_release="-rel first-ana -b"	
	build_log_name=make_nova_branch_build_log
	temp_build_script_release="_first-ana"
    else
	setup_nova_release_options="-r ${release}"
	logfile_name_release="_${release}"
	webdir_name_release="_${release}"
	novasoft_build_release_options="-rel ${release}"	
	update_release_opt_release="-rel ${release}"	
	build_log_name=make_nova_${relase}_build_log
	temp_build_script_release="_${release}"
    fi

##build
    if [ "$build" == "debug" ]
    then
	setup_nova_build_options=""
	logfile_name_build=""
	webdir_name_build="debug"
	novasoft_build_build_options="-debug"	
	temp_build_script_build="_debug"
    elif [ "$build" == "maxopt" ]
    then
	setup_nova_build_options="-b maxopt"
	logfile_name_build="_maxopt"
	webdir_name_build="maxopt"
	novasoft_build_build_options=""	
	temp_build_script_build="_maxopt"
    fi

}

###################################################################################
# Cleanup the variables used in this script. We don't want to litter the environment
# It is also necessary for getopts to not remember it's previous state to react 
# properly if the script is invoked multiple times.
###################################################################################

cleanup_vars () {


    unset DEBUG
    unset os
    unset redhat
    unset release
    unset build
    unset slf5
    unset slf6
    unset errorcode
    unset opt
    unset OPTARG
    unset gettingopt
    unset retval_args
    unset retval_os
    unset retval_release
    unset setup_nova_script
    unset setup_nova_os_options
    unset logfile
    unset logfile_name_os
    unset logfile_name_release
    unset logfile_name_build
    unset webdir
    unset webdir_dir
    unset webdir_name_build
    unset webdir_name_os
    unset webdir_name_release
    unset novasoft_build_release_options
    unset novasoft_build_build_options
    unset setup_nova_build_options
    unset setup_nova_release_options
    unset update_release_opt_release
    unset build_log_name
    unset vsize
    unset img
    unset temp_build_script_os
    unset temp_build_script_copy_os
    unset temp_build_script_release
    unset temp_build_script_build
    unset temp_build_script_name
    unset temp_build_script_copy_name
    unset do_update_release
    unset basedir
    unset BASEDIR_SET
    unset the_externals_path
}





main () {
    
###set default variables
#    set_defaults -- don't need this - make the user be explicit

###process arguments
   process_args $*
    retval_args=$?
    if [ "$retval_args" == 1 ]; then
	cleanup_vars
	return 1
    fi

    process_os
    retval_os=$?
    if [ "$retval_os" == 1 ]; then
	cleanup_vars
	return 1
    fi
    
    process_release
    retval_release=$?
    if [ "$retval_release" == 1 ]; then
	cleanup_vars
	return 1
    fi

    process_build
    retval_build=$?
    if [ "$retval_build" == 1 ]; then
	cleanup_vars
	return 1
    fi
    

###setup the variables needed below, based on the options found above
    set_vars


###Create a temporary script that will be run at the last stage
    temp_build_script_name=${temp_build_script_os}${temp_build_script_release}${temp_build_script_build}
    temp_build_script_copy_name=${temp_build_script_copy_os}${temp_build_script_release}${temp_build_script_build}_backup

###Set the logfile and webdir     
    if [ "$DEBUG" == "1" ]
    then
	if [ -z $BASEDIR_SET ];then
	    webdir_dir=/nusoft/app/web/htdoc/nova/novasoft/logs_testing 
	else
	    webdir_dir=${basedir}/web/logs_testing 
	fi
    else
	if [ -z $BASEDIR_SET ];then
	    webdir_dir=/nusoft/app/web/htdoc/nova/novasoft/logs 	
	else
	    webdir_dir=${basedir}/web/logs_testing 
	fi
    fi



    logfile=${logfile_dir}/novaart${logfile_name_build}${logfile_name_os}_make${logfile_name_release}.log

    webdir=${webdir_dir}/${webdir_name_build}logs${webdir_name_os}${webdir_name_release}
    mkdir -p $webdir


    if [ -e $temp_build_script_name ]
    then
	rm $temp_build_script_name
    fi

    echo "============================================================"
    echo "build_novaart_all_varieties.sh"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "OS: $os"
    echo "release: $release"
    echo "build: $build"
    echo ""
    echo "Date: `date`"
    echo ""
    echo "temp_build_script_name: $temp_build_script_name"
    echo ""
    echo "temp_build_script_copy_name: $temp_build_script_copy_name"
    echo ""
    echo "logfile=$logfile"
    echo ""
    echo "webdir=$webdir"
    echo "============================================================"
    


    echo "#============================================================" >> $temp_build_script_name
    echo "#build_novaart_all_varieties.sh" >> $temp_build_script_name
    echo "#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $temp_build_script_name
    echo "#OS: $os" >> $temp_build_script_name
    echo "#release: $release" >> $temp_build_script_name
    echo "#build: $build" >> $temp_build_script_name
    echo "#" >> $temp_build_script_name
    echo "#Date: `date`" >> $temp_build_script_name
    echo "#" >> $temp_build_script_name
    echo "#temp_build_script_name: $temp_build_script_name" >> $temp_build_script_name
    echo "#" >> $temp_build_script_name
    echo "#temp_build_script_copy_name: $temp_build_script_copy_name" >> $temp_build_script_name
    echo "#============================================================" >> $temp_build_script_name

    #1/ set hostname

    echo -e "export HOSTNAME=$HOSTNAME\n" >> $temp_build_script_name

    #2/ set log file and webdir

    echo -e "logfile=$logfile" >> $temp_build_script_name
    echo -e "webdir=$webdir\n" >> $temp_build_script_name

    #3/ setup_nova
    echo -e "source $setup_nova_script $setup_nova_os_options $setup_nova_release_options $setup_nova_build_options >> \$logfile 2>&1\n" >> $temp_build_script_name

    #4/ update $SRT_DIST/SRT_NOVA
    echo "echo \"============================================================\" > \$logfile" >> $temp_build_script_name
    echo "echo \"build_novaart_all_varieties.sh\" >> \$logfile" >> $temp_build_script_name
    echo "echo \"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\" >> \$logfile" >> $temp_build_script_name
    echo "echo \"OS: $os\" >> \$logfile" >> $temp_build_script_name
    echo "echo \"release: $release\" >> \$logfile" >> $temp_build_script_name
    echo "echo \"build: $build\" >> \$logfile" >> $temp_build_script_name
    echo "echo \"\" >> \$logfile" >> $temp_build_script_name
    echo "echo \"Date: `date`\" >> \$logfile" >> $temp_build_script_name
    echo "echo \"\" >> \$logfile" >> $temp_build_script_name
    echo "echo \"temp_build_script_name: $temp_build_script_name\" >> \$logfile" >> $temp_build_script_name
    echo "echo \"\" >> \$logfile" >> $temp_build_script_name
    echo "echo \"temp_build_script_copy_name: $temp_build_script_copy_name\" >> \$logfile" >> $temp_build_script_name
    echo "echo \"============================================================\" >> \$logfile" >> $temp_build_script_name
    
    echo -e "echo \"Output written to\" \$logfile\n" >> $temp_build_script_name
    echo -e "cd \$SRT_PUBLIC_CONTEXT/SRT_NOVA\n" >> $temp_build_script_name
    
    echo -e "echo \"Updating \$SRT_DIST/SRT_NOVA first:\" >> \$logfile" >> $temp_build_script_name
    echo -e "svn update >> \$logfile 2>&1\n" >> $temp_build_script_name
    
    #5/ clean release
    echo -e "echo \"Cleaning FNAL NOvA-ART Release at \" >> \$logfile" >> $temp_build_script_name
    echo -e "date >> \$logfile\n" >> $temp_build_script_name
    echo -e "cd \$SRT_PUBLIC_CONTEXT\n" >> $temp_build_script_name
    echo -e "make clean >> \$logfile 2>&1\n" >> $temp_build_script_name
    
    #6/ call novasoft_build clean
    echo -e "\$SRT_PUBLIC_CONTEXT/SRT_NOVA/scripts/novasoft_build ${novasoft_build_release_options} -clean ${novasoft_build_build_options} >> \$logfile 2>&1\n" >> $temp_build_script_name

    echo -e "echo \"Finished Cleaning\" >> \$logfile\n" >> $temp_build_script_name
    
    #6/ update-release
    if [ ! -z $do_update_release ];then
	echo -e "echo \"Starting FNAL NOvA-ART Update at \" >> \$logfile" >> $temp_build_script_name
	echo -e "date >> \$logfile" >> $temp_build_script_name
	echo -e "\$SRT_PUBLIC_CONTEXT/SRT_NOVA/scripts/update-release ${update_release_opt_release} >> \$logfile 2>&1\n" >> $temp_build_script_name
	echo -e "echo \"Finished Updating\" >> \$logfile\n" >> $temp_build_script_name
	
	echo -e "echo \`date\` Updated Release Finished\n" >> $temp_build_script_name
    fi
	
    #7/ novasoft_build
    echo -e "echo \"Started Building\" >> \$logfile\n" >> $temp_build_script_name
    
    echo -e "echo \`date\` Started Building Release\n" >> $temp_build_script_name
    
    echo -e "\$SRT_PUBLIC_CONTEXT/SRT_NOVA/scripts/novasoft_build ${novasoft_build_release_options} -p 17 ${novasoft_build_build_options} >> \$logfile 2>&1\n" >> $temp_build_script_name

    echo -e "echo \`date\` Finished Building Release\n" >> $temp_build_script_name
    
    #8/ run image sizing job
    echo -e "export img=\`nova -c \$SRT_PUBLIC_CONTEXT/Utilities/memtest.fcl\`" >> $temp_build_script_name
    echo -e "export vsize=\`echo \$img | sed -e 's#.*Peak virtual size \([0-9]*\.[0-9]*\).*#\1# '\`" >> $temp_build_script_name
    echo -e "echo -e \"The image size (in MB) of a do-nothing nova job: \$vsize \\\n\" >> \$logfile\n" >> $temp_build_script_name

    #9/ make log file
    echo -e "\$SRT_PUBLIC_CONTEXT/SRT_NOVA/scripts/${build_log_name} \$logfile \$webdir" >> $temp_build_script_name

    if [ "$DEBUG" == "1" ]
    then
	echo -e "DEBUG mode -- Not running script"
	cp $temp_build_script_name $temp_build_script_copy_name
	rm $temp_build_script_name
    else
	bash $temp_build_script_name
	cp $temp_build_script_name $temp_build_script_copy_name
	rm $temp_build_script_name
    fi

    cleanup_vars
    
}

main $*



