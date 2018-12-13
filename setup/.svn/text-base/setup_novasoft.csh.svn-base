# 24-Feb-10 B. Rebel adapted for fnal
# 10-Apr-12 G. Davies adapted for externals in /nusoft/app/externals
# area and new setup script new

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

if ( $?NOVASOFT_SETUP )  then
  
  echo
  echo "***********************WARNING***********************"
  echo "Currently we prevent multiple sourcing, i.e. switching between releases mid-session\!"
  echo "You have NOT successfully sourced a different release\!" 
  echo "If you want to source a different release you must either log out and login to source again, or open a new terminal\!"
  echo "This is to prevent indefinite extension of PATH and LD_LIBRARY_PATH"
  echo "********************END OF WARNING********************"
  echo
  
endif

if ( ! $?NOVASOFT_SETUP ) then

    setenv prod_db ${EXTERNALS}

    set SETUP_LOCATION=/grid/fermiapp/nova/novaart/novasvn/setup
    unsetenv INVALID_RELEASE
    echo $SETUP_LOCATION
    # Make sure this is an executable script.
    if ( -x ${SETUP_LOCATION}/setup_novasoft_setup.sh ) then 
    
    	# Execute the script and save the result.  Note that the "-c"
	# option causes the result file's commands to be
	# csh-compatible.  Pass along any arguments to this script.
	set result=`${SETUP_LOCATION}/setup_novasoft_setup.sh -c $argv`
	# Make sure provided argument is and existing release
	if ( ! -d ${SETUP_LOCATION}/../releases/$2 ) then
	     echo "INVALID RELEASE. Try sourcing again with a valid release name."
             setenv INVALID_RELEASE 1
        endif    	
	# Only execute if sourcing a "real" existing release
	if ( ! $?INVALID_RELEASE ) then
 	     # Make sure the result is a readable file.
	     if ( -r ${result} ) then		
	          # Execute the contents of this file in the current environment.
		  source ${result}
	     endif
	     #make a setup alias for NOvA specific setups
   	     if ( -x ${SRT_PUBLIC_CONTEXT}/bin/${SRT_SUBDIR}/srt_environment_nova ) then
		  alias srt_setup source '`srt_environment_nova -X -c \!*`'
	     endif
	     # Set a flag to suppress unnecessary re-executions of this script.
             setenv NOVASOFT_SETUP 1
        endif
        
    endif

endif
