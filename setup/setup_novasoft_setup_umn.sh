#!/bin/sh  
#
#  lar setup script
#  B. Rebel - June 19, 2008
#  stolen from P. Shanahan script for nova
#  J. Zirnstein - October 25, 2012
#  Cleaning House at UMN, now reflects script at FNAL
#  J. Zirnstein - February 16, 2013
#  Build in maxopt now enabled

#  Based on logic of SRT setup scripts
#
#  This script does nothing other than setup another (temporary) script, which 
#  will either be in csh or sh, as desired, and then return the full name
#  of the temporary script.  
#  
#  It is intended that a wrapper will then source the temp script.
#  
#  Why is it done this way?  Basically to allow one script to handle 
#  csh and sh.  The persistence of variables requires source'ing rather
#  than direct execution, but sourcing is incompatible with forcing a
#  shell.  So, we force the shell, but then write a sourceable file
#  in the user's prefered shell.


remove_tww () {
	#  remove TheWrittenWord from the path. Evil. Bad.
	print_var PATH "\`dropit -p \$PATH /opt/TWWfsw/bin\`"  $shell_type
}

set_defaults () {

	shell_type=csh
	release=default
	testrel=.
	build=debug
	nova_lnk=pro
	find_output_file_name
}

set_ups () {

    if [ -z "${EXTERNALS}" ]; then
	echo "You need to set the EXTERNALS directory"
    else
	upssource="${EXTERNALS}/setup"
    fi
    if [ -f $upssource ]; then
	insert_source $upssource
    fi
}

usage () {
	echo "" >&2
	echo "usage: `basename $0` [options]" >&2
	echo "options:" >&2
	echo "     -h, --help: prints this usage message" >&2
	echo "     -r, --release: specifies the release to be set up" >&2
	echo "     -b, --build: specifies the build-type (debug or prof)" >&2
	exit
}

process_args () {
	while getopts "hncsr:b:-:" opt; do 
		if [ "$opt" = "-" ]; then
			opt=$OPTARG
		fi
		case $opt in
			h | help)
				usage
				;;
			s | sh)
				shell_type=sh
				;;
			c | csh)
				shell_type=csh
				;;
			r | release)
				release=$OPTARG
				nova_lnk=$release
				;;
			b | build)
				build=$OPTARG
				;;
			*) usage
			;;

		esac
	done
}


find_output_file_name () {
	output_file="/tmp/env_tmp.$$"
	if [ -f $output_file ]; then
		i=0
		while [ -f $output_file ]; do
			i=`expr $i + 1`
			output_file="/tmp/env_tmp.$i.$$"
		done
	fi
}

get_vars () {
	process_args $*
}


print_var () {
	# print a statement to set a variable in the desired shell type
	local_style=$3
	if [ "$local_style" = "sh" ]; then
		echo "$1=\"$2\"" >> $output_file
		echo "export $1" >> $output_file
	elif [ "$local_style" = "csh" ]; then
		echo "setenv $1 \"$2\"" >> $output_file
	elif [ "$local_style" = "human" ]; then
		echo "$1 = \"$2\""
	fi
}

unprint_var () {
	# print a statement to set a variable in the desired shell type
	local_style=$2
	if [ "$local_style" = "sh" ]; then
		echo "unset $1" >> $output_file
	elif [ "$local_style" = "csh" ]; then
		echo "unsetenv $1" >> $output_file
	elif [ "$local_style" = "human" ]; then
		echo "unsetting $1"
	fi
}

insert_source () {
	echo "source $1" >> $output_file
}

insert_cmd () {
	echo "$1" >> $output_file
}

set_extern () {
    # a file containing the ups setup command args for each external product

    if [[ "$build" = "prof" || "$build" = "maxopt" ]];then
	srt_ups_versions='$SRT_PUBLIC_CONTEXT/setup/nova-offline-ups-externals-$SRT_BASE_RELEASE-prof'
    else
	srt_ups_versions='$SRT_PUBLIC_CONTEXT/setup/nova-offline-ups-externals-$SRT_BASE_RELEASE'
    fi

    # the script to run the setups
    srt_ups_script='$SRT_DIST/setup/setup_srt_ups.'$shell_type

    insert_source "$srt_ups_script $srt_ups_versions"
}

set_srt () {

    # Source the srt setup file
    insert_source "\$SRT_DIST/srt/srt.$shell_type"

    # setup desired release for the user. This adds the lib and bin areas
    # for the chosen base release to $path and to LD_LIBRARY_PATH
    #
    # first try to unsetup the current settings
    if [ $release = "none" ]; then
	echo "Skipping SRT Setup"
    else
	srt_setup_cmd="srt_setup -d"
	if [ $release = "default" ]; then
	  srt_setup_cmd="$srt_setup_cmd SRT_QUAL=$build"
	elif [[ $release = "S12.02.04" || $release = S11* ]]; then
	  srt_setup_cmd="$srt_setup_cmd SRT_BASE_RELEASE=$release"
	else
	  srt_setup_cmd="$srt_setup_cmd SRT_QUAL=$build SRT_BASE_RELEASE=$release"
	fi
	insert_cmd "srt_setup --unsetup"
	insert_cmd "$srt_setup_cmd"
    fi

    #set environmental variables necessary for using ART FileInPath functionality
    print_var FW_BASE         "\${SRT_PUBLIC_CONTEXT}"                                 $shell_type
    print_var FW_RELEASE_BASE "\${SRT_PUBLIC_CONTEXT}"                                 $shell_type
    print_var FW_DATA         "/local/nova/novadata:/local/nova/novadata/aux:/local/nova/novadata/flux:/data/novadata2:/data/novadata3"           $shell_type 
    print_var NOVA_DATA       "/data/novadata3"                                        $shell_type
    print_var PID_LIB_PATH    "/local/nova/pidlibs/S14-07-18"			       $shell_type
    print_var FW_SEARCH_PATH  "\${SRT_PUBLIC_CONTEXT}/:\${FW_DATA}" 		       $shell_type
    print_var NOVADOCPWDFILE  "/local/nova/externals/doc_db_pwd" 		       $shell_type

}

set_paths () {
    
    print_var LD_LIBRARY_PATH "\${LD_LIBRARY_PATH}:\${LHAPDF_FQ_DIR}/lib"              $shell_type
    print_var LD_LIBRARY_PATH "\${LD_LIBRARY_PATH}:\${GENIE}/lib"                      $shell_type
    print_var FHICL_FILE_PATH "./:\${SRT_PUBLIC_CONTEXT}/job/:\${SRT_PUBLIC_CONTEXT}/:\${FHICL_FILE_PATH}" $shell_type
 
}
set_devdb () {

    print_var NOVADBHOST      "ifdbrep.fnal.gov"                                       $shell_type
    print_var NOVADBHOST1     "ifdbprod.fnal.gov"                                      $shell_type
    print_var NOVADBWSURL     "http://novacon-data.fnal.gov:8091/NOvACon/v2_2b/app/"   $shell_type
    print_var NOVADBWSURLINT  "http://novacon-data.fnal.gov:8109/NOvACon/v2_2b/app/"   $shell_type
    print_var NOVADBWSURLPUT  "http://novacon-data.fnal.gov:8107/NOvACon/v2_2b/app/"   $shell_type
    print_var NOVADBQEURL     "http://novacon-data.fnal.gov:8105/QE/NOvA/app/SQ/"      $shell_type
    print_var NOVADBNAME      "nova_prod"                                              $shell_type
    print_var NOVADBUSER      "nova_reader"                                            $shell_type
    print_var NOVADBPWDFILE   "\${SRT_PUBLIC_CONTEXT}/Database/config/nova_reader_pwd" $shell_type
    print_var NOVADBGRIDPWDFILE "\${SRT_PUBLIC_CONTEXT}/Database/config/nova_grid_pwd" $shell_type
    print_var NOVADBWSPWDFILE "/local/nova/db/nova_devdbws_pwd"                        $shell_type
    print_var NOVADBPORT      "5433"                                                   $shell_type
    print_var NOVAHWDBHOST    "ifdbrep.fnal.gov"                                       $shell_type
    print_var NOVAHWDBHOST1   "ifdbprod.fnal.gov"                                      $shell_type
    print_var NOVAHWDBNAME    "nova_hardware"   				       $shell_type
    print_var NOVAHWDBUSER    "nova_reader"                                            $shell_type
    print_var NOVAHWDBPORT    "5432"                                                   $shell_type
    print_var NOVADBTIMEOUT   "30"                                                     $shell_type
    print_var NOVANEARDAQDBHOST "ifdbrep.fnal.gov"                                     $shell_type
    print_var NOVANEARDAQDBNAME "nova_prod"                                            $shell_type
    print_var NOVANEARDAQDBPORT "5434"                                                 $shell_type
    print_var NOVANEARDAQDBUSER "nova_grid"                                            $shell_type
    print_var NOVAFARDAQDBHOST "ifdbrep.fnal.gov"                                      $shell_type
    print_var NOVAFARDAQDBNAME "nova_prod"                                             $shell_type
    print_var NOVAFARDAQDBPORT "5436"                                                  $shell_type
    print_var NOVAFARDAQDBUSER "nova_grid"                                             $shell_type
    print_var NOVAFARDCSDBHOST "ifdbrep.fnal.gov"                                      $shell_type
    print_var NOVAFARDCSDBNAME "nova_prod"                                             $shell_type
    print_var NOVAFARDCSDBPORT "5437"                                                  $shell_type
    print_var NOVAFARDCSDBUSER "nova_grid"                                             $shell_type
}

set_other () {
    
    print_var ACK_OPTIONS "--type-set=fcl=.fcl"                                        $shell_type
 
}

finish () {
	echo $output_file
}

main () {
     set_defaults
     get_vars $*
     set_srt
     set_ups
     set_extern
     set_devdb
     set_paths
     set_other
     finish
}

main $*


