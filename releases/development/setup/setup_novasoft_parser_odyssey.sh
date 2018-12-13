#!/bin/sh  
#
#  NOvA-ART setup script
#  B. Rebel - June 19, 2008
#  G. Davies - April 10, 2011
#  stolen from P. Shanahan script for nova

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


#################################################################
########### Following routines are site-specific   ##############
#################################################################
remove_tww () {
#  remove TheWrittenWord from the path. Evil. Bad.

	
	print_var PATH "\`dropit -p \$PATH /opt/TWWfsw/bin\`"  $shell_type

}

set_defaults () {

	shell_type=sh
	release=default
	testrel=.
	nova_lnk=pro
	find_output_file_name
}


########### preceding routines are site-specific ########

process_args () {
	while getopts "hcsr:-:" opt; do 
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

set_version () {


    fmwkv="v1_00_06 -qnova:debug"
    g4v="v4_9_4_p02 -qdebug:gcc46"
    g4ablav=v3_0
    g4emlowv=v6_19
    g4neutronv=v3_14
    g4neutronxsv=v1_0
    g4photonv=v2_1
    g4piiv=v1_2
    g4radiativev=v3_3
    g4surfacev=v1_0
    fftwv="v3_2_2 -qdebug:gcc46"
    geniev="v3334 -qdebug:nova"
    cryv="v1_5 -qgcc46"
    pdfsetsv="v5_8_4a"
    postgresqlv="v8_4_7 -qgcc46"
    cstxsdv="v3_3_0"
    mysql_clientv="v5_1_56 -qgcc46"
    xerces_cv="v3_1_1 -qdebug:gcc46"
    numibeamdbv="v1_0_1 -qR53002GCC46"
    #totalviewv="v8_9_0a"
    
    print_var NDOS_MC       "/n/nssdeep/feldman_lab/nova/mc/S11.11.16/ndos"                 $shell_type
    print_var NDOS_DATA     "/n/nssdeep/feldman_lab/nova/novaroot/NDOS/S11.11.16"           $shell_type
        

        if [ $nova_lnk = "S11.11.16" ]; then
           
           fmwkv="v1_00_05 -qnova:debug"
           g4v="v4_9_4_p02 -qdebug:gcc46"
           g4ablav=v3_0
           g4emlowv=v6_19
           g4neutronv=v3_14
           g4neutronxsv=v1_0
           g4photonv=v2_1
           g4piiv=v1_2
           g4radiativev=v3_3
           g4surfacev=v1_0
           fftwv="v3_2_2 -qdebug:gcc46"
           geniev="v3334 -qdebug:nova"
           cryv="v1_5 -qgcc46"
           pdfsetsv="v5_8_4a"
           postgresqlv="v8_4_7 -qgcc46"
           cstxsdv="v3_3_0"
           mysql_clientv="v5_1_56 -qgcc46"
           xerces_cv="v3_1_1 -qdebug:gcc46"
           numibeamdbv="v1_0_1 -qR53002GCC46"
           #totalviewv="v8_9_0a"

	   print_var NDOS_MC       "/n/nssdeep/feldman_lab/nova/mc/S11.11.16/ndos"                 $shell_type
	   print_var NDOS_DATA     "/n/nssdeep/feldman_lab/nova/novaroot/NDOS/S11.11.16"           $shell_type

        fi


        if [ $nova_lnk = "S11.07.27" ]; then
           
           fmwkv="v0_07_04 -qnova:debug"
           g4v="v4_9_4_p01 -qdebug:gcc45"
           g4ablav=v3_0
           g4emlowv=v6_19
           g4neutronv=v3_14
           g4neutronxsv=v1_0
           g4photonv=v2_1
           g4piiv=v1_2
           g4radiativev=v3_3
           g4surfacev=v1_0
           fftwv="v3_2_2 -qgcc45"
           geniev="v3249 -qnova"
           cryv="v1_5 -qgcc45"
           pdfsetsv="v5_8_4a"
           postgresqlv="v8_4_7 -qgcc45"
           cstxsdv="v3_3_0"
           mysql_clientv="v5_1_56 -qgcc45"
           xerces_cv="v3_1_1 -qgcc45"
	   numibeamdbv="v0_1_1 -qR52800aGCC45"
           #totalviewv="v8_6d"
    
           print_var NDOS_MC       "/n/nssdeep/feldman_lab/nova/mc/NDOS/S11.07.27"                      $shell_type
           print_var NDOS_DATA     "/n/nssdeep/feldman_lab/nova/novaroot/NDOS/S11.07.27"           $shell_type     
        fi
           
        if [ $nova_lnk = "S11.06.14" ]; then
        
           fmwkv="v0_07_04 -qnova:debug"
           g4v="v4_9_4_p01 -qgcc45"
    	   g4ablav=v3_0
    	   g4emlowv=v6_19
    	   g4neutronv=v3_14
    	   g4neutronxsv=v1_0
    	   g4photonv=v2_1
    	   g4piiv=v1_2
    	   g4radiativev=v3_3
    	   g4surfacev=v1_0
    	   fftwv="v3_2_2 -qgcc45"
    	   geniev="v3249 -qnova"
    	   cryv="v1_5 -qgcc45"
    	   pdfsetsv="v5_8_4a"
    	   postgresqlv="v8_4_7 -qgcc45"
    	   cstxsdv="v3_3_0"
    	   mysql_clientv="v5_1_56 -qgcc45"
    	   xerces_cv="v3_1_1 -qgcc45"
	   numibeamdbv="v0_1_1 -qR52800aGCC45"
    	   #totalviewv="v8_6d"
    	   
    	   print_var NDOS_MC       "/n/nssdeep/feldman_lab/nova/mc/NDOS/S11.06.14"                       $shell_type
    	   print_var NDOS_RECO     "/n/nssdeep/feldman_lab/nova/novareco/NDOS/S11.06.14/reco"       $shell_type
    	   print_var NDOS_RECOHIST "/n/nssdeep/feldman_lab/nova/novareco/NDOS/S11.06.14/recohist"   $shell_type
    	   print_var NDOS_CANA     "/n/nssdeep/feldman_lab/nova/novareco/NDOS/S11.06.14/cana"       $shell_type
        fi
        
	if [ $nova_lnk = "S11.04.30" ]; then

	   fmwkv="v0_06_03 -qnova:debug"
    	   g4v="v4_9_4_p01 -qgcc45"
    	   g4ablav=v3_0
    	   g4emlowv=v6_19
    	   g4neutronv=v3_14
    	   g4neutronxsv=v1_0
    	   g4photonv=v2_1
    	   g4piiv=v1_2
    	   g4radiativev=v3_3
    	   g4surfacev=v1_0
    	   fftwv="v3_2_2 -qgcc45"
    	   geniev="v3249 -qnova"
    	   cryv="v1_5 -qgcc45"
    	   pdfsetsv="v5_8_4a"
    	   postgresqlv="v8_4_7 -qgcc45"
    	   cstxsdv="v3_3_0"
    	   mysql_clientv="v5_1_56 -qgcc45"
    	   xerces_cv="v3_1_1 -qgcc45"
	   numibeamdbv="v0_1_1 -qR52800aGCC45"
	fi

}

set_extern () {
    
    print_var NOVAHOME "/n/sw/nova/software/novaart"   $shell_type
    print_var EXTERNHOME "/n/sw/nova/software/novaart" $shell_type
    print_var prod_db    "\$EXTERNHOME/externals"        $shell_type
    
    insert_source "\$prod_db/setup"
    insert_cmd "setup art          $fmwkv"  
    insert_cmd "setup genie        $geniev"  
    insert_cmd "setup geant4       $g4v"  
    insert_cmd "setup g4abla       $g4ablav"  
    insert_cmd "setup g4emlow      $g4emlowv"  
    insert_cmd "setup g4neutron    $g4neutronv"  
    insert_cmd "setup g4neutronxs  $g4neutronxsv"  
    insert_cmd "setup g4photon     $g4photonv"  
    insert_cmd "setup g4pii        $g4piiv"  
    insert_cmd "setup g4radiative  $g4radiativev"  
    insert_cmd "setup g4surface    $g4surfacev"  
    insert_cmd "setup cry          $cryv"  
    insert_cmd "setup fftw         $fftwv"  
    insert_cmd "setup pdfsets      $pdfsetsv"
    insert_cmd "setup cstxsd       $cstxsdv"
    insert_cmd "setup postgresql   $postgresqlv"
    insert_cmd "setup mysql_client $mysql_clientv"
    insert_cmd "setup xerces_c	   $xerces_cv"
    insert_cmd "setup NumiBeamDB   $numibeamdbv"
    #insert_cmd "setup totalview    $totalviewv"

}

set_srt () {

    # may need this(?) (see SoftRelTools/HEAD/include/arch_spec_f77.mk)
    # setenv SRT_USE_F2C true

    # Source the srt setup file
    insert_source "\$NOVAHOME/novasoft/srt/srt.$shell_type"

    # setup desired release for the user. This adds the lib and bin areas
    # for the chosen base release to $path and to LD_LIBRARY_PATH
    #
    # first try to unsetup the current settings

    if [ "$release" = "none" ]; then
      	echo "Skipping SRT Setup"
    else
       	insert_cmd "srt_setup --unsetup" 
       
       	if [ "$release" = "default" ]; then
       		insert_cmd "srt_setup -d"   	
	else
       		insert_cmd "srt_setup -d SRT_BASE_RELEASE=$release"
       	fi
    fi

    #set environmental variables necessary for using ART FileInPath functionality
    #will the SRT_PRIVATE_CONTEXT actually reset after the setup???
    print_var FW_BASE         "\${SRT_PUBLIC_CONTEXT}"                                 $shell_type
    print_var FW_RELEASE_BASE "\${SRT_PUBLIC_CONTEXT}"                                 $shell_type
    print_var FW_DATA         "/n/nssdeep/feldman_lab/nova/data/:/n/nssdeep/feldman_lab/nova/aux/:/n/nssdeep/feldman_lab/nusoft/data/flux/"   $shell_type 
    print_var FW_SEARCH_PATH  "\${SRT_PUBLIC_CONTEXT}/:\${FW_DATA}" 		       $shell_type
    print_var FHICL_FILE_PATH "./:\${SRT_PUBLIC_CONTEXT}/job/:\${SRT_PUBLIC_CONTEXT}/:\${FHICL_FILE_PATH}" $shell_type

}

set_devdb () {
  
    print_var NOVADBHOST      "novadbdev.fnal.gov"                                     $shell_type
    print_var NOVADBNAME      "nova_dev"   					       $shell_type
    print_var NOVADBUSER      "nova_reader"                                            $shell_type
    print_var NOVADBPWDFILE   "/n/sw/nova/app/db/nova_reader_pwd"                           $shell_type
    print_var NOVADBPORT      "5432"                                                   $shell_type

}

set_paths () {
    
    print_var LD_LIBRARY_PATH "\${LD_LIBRARY_PATH}:\${LHAPDF_FQ_DIR}/lib"              $shell_type
    print_var LD_LIBRARY_PATH "\${LD_LIBRARY_PATH}:\${GENIE}/lib"                      $shell_type
 
}

finish () {

	echo $output_file
}

main () {

     set_defaults
     get_vars $*
     set_version
     set_extern
     set_srt
     set_devdb
     set_paths
     finish
}

main $*


