# A wrapper script for setup_larsoft_setup_fnal.sh.
# 24-Feb-10 B. Rebel 

# Here's the idea: setup_novasoft_setup_ifcluster.sh is a shell executable
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

# 25-Oct-12 J. Zirnstein 
# Updated to reflect changes to setup scripts at FNAL

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

    SETUP_LOCATION=/local/nova/novasoft/setup
    unset INVALID_RELEASE
    
    # Make sure this is an executable script.
    if [ -x ${SETUP_LOCATION}/setup_novasoft_setup_umn.sh ]; then 

        # Execute the script and save the result.  Note that the "-s"
        # option causes the result file's commands to be
        # sh-compatible.  Pass along any arguments to this script.

	setup_script=${SRT_DIST}/setup/setup_novasoft_setup_umn.sh

	# Make sure provided argument is an existing release
	# IF sourcing a release other than development using '-r' option
	
	if [ "$1" == "-r" ]; then
		if [ ! -d "${SETUP_LOCATION}/../releases/$2" ]; then
			echo "INVALID RELEASE. Try sourcing again with a valid release name."
			export INVALID_RELEASE=1
		else
		    setup_script=${SRT_DIST}/releases/$2/setup/setup_novasoft_setup_umn.sh
		fi
	else
	    setup_script=${SRT_DIST}/releases/development/setup/setup_novasoft_setup_umn.sh
	fi

	echo "sourcing setup from ${setup_script}"
	result=`${setup_script} -s $@`
	
	# Only execute if sourcing a "real" existing release
	if [ -z "${INVALID_RELEASE}" ]; then
		# Make sure the result is a readable file.
		if [ -r ${result} ]; then
		    # Execute the contents of this file in the current environment.
		    source ${result}
		fi

		#make a setup alias for lar specific setups
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
