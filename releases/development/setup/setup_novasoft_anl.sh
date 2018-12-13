# A wrapper script for setup_novasoft_setup_nusoft.sh.
# 24-Feb-10 B. Rebel
# 10-Apr-11 G. Davies 
# 30-Oct-12 J. Paley for ANL

# Here's the idea: setup_novasoft_setup_nusoft.sh is a shell executable
# script.  When it is run, it returns the name of a temporary script
# that can be sourced to set the user's shell variables appropriately
# for the FNAL NOvASoft installation.

# All this wrapper has to do is run the program, save the output, and
# source that output file.  The output file will automatically delete
# itself.

# Only execute this script if NOvASoft has not already been set up (to
# prevent indefinite extension of $PATH and $LD_LIBRARY_PATH); note
# that this may cause problems if we want to switch release
# mid-session or something like that.

if [ ! -z "${NOVASOFT_SETUP}" ] ; then
  
  echo
  echo "***********************WARNING!***********************"
  echo "Currently we prevent multiple sourcing, i.e. switching between releases mid-session!"
  echo "You have NOT successfully sourced a different release!" 
  echo "If you want to source a different release you must either log out and login to source again, or open a new terminal!"
  echo "This is to prevent indefinite extension of PATH and LD_LIBRARY_PATH"
  echo "********************END OF WARNING!********************"
  echo
  
fi

if [ -z "${NOVASOFT_SETUP}" ]; then

    echo
    echo "***********************WARNING!***********************"
    echo "You should start to migrate to the new setup method"
    echo "This method will soon become deprecated!"
    echo "Please add the following to your ~/.bashrc or ~/.profile:"
    echo ""
    echo "function setup_nova {"
    echo "  source /data1/jpaley/novasoft/srt/srt.sh"
    echo "  export EXTERNALS=/data1/jpaley/nusoft/externals"
    echo "  source \$SRT_DIST/setup/setup_novasoft.sh ""$@"""
    echo "}"
    echo "********************END OF WARNING!********************"
    echo

    SETUP_LOCATION=/n2data1/nova/software/novasoft-svn/setup
    unset INVALID_RELEASE
    # Make sure this is an executable script.
    if [ -x ${SETUP_LOCATION}/setup_novasoft_setup_anl.sh ]; then 
        
        # Execute the script and save the result.  Note that the "-s"
        # option causes the result file's commands to be
        # sh-compatible.  Pass along any arguments to this script.
	setup_script=${SRT_DIST}/setup/setup_novasoft_setup_anl.sh

	# Make sure provided argument is an existing release 
	# IF sourcing a release other than development using '-r' option
	if [ "$1" == "-r" ]; then 
	    if [ ! -d "${SETUP_LOCATION}/../releases/$2" ]; then
		echo "INVALID RELEASE. Try sourcing again with a valid release name."
		export INVALID_RELEASE=1
	    else
		setup_script=${SRT_DIST}/releases/$2/setup/setup_novasoft_setup_anl.sh
	    fi    
	else
	    setup_script=${SRT_DIST}/releases/development/setup/setup_novasoft_setup_anl.sh
	fi

	echo "sourcing setup from ${setup_script}"
	result=`${setup_script} -s $@`

        # Only execute if sourcing a "real" existing release
        if [ -z "${INVALID_RELEASE}" ] ; then
            # Make sure the result is a readable file.
	    if [ -r ${result} ]; then
	        # Execute the contents of this file in the current environment.
	        source ${result}
	    fi         
	    #make a setup alias for NOvA specific setups
	    if [ -x ${SRT_PUBLIC_CONTEXT}/bin/${SRT_SUBDIR}/srt_environment_nova ]; then
	        srt_setup () {
		    . `srt_environment_nova -X "$@"`
	        }
	    fi
	    # Set a flag to suppress unnecessary re-executions of this script.
            export NOVASOFT_SETUP=1
	fi
	
    fi
    
fi
