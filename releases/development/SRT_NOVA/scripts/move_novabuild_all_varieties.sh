#!/bin/bash

#Brief -- Remove unneeded libraries and files from release, tar it up, 
#         unpack it in the install location and make links for users

#By    -- j.p.davies@sussex.ac.uk

#Date  -- December 2014


process_args () {

    errorcode=0
    while getopts "h56df-:" opt; do
	if [ "$opt" = "-" ]; then
            opt=$OPTARG
        fi
	gettingopt=1
        case $opt in
	    h) 
                usage
		errorcode=1
                ;;
	    5)
		DO_SLF5=1
		;;
	    6)
		DO_SLF6=1
		;;
	    d)
		DO_DEVELOPMENT=1
		;;
	    f)
		DO_FIRST_ANA=1
		;;
        esac
    done
    if [ "$#" != "0" ] && [ "$gettingopt" != "1" ] && [ "$errorcode" != "1" ]; then
	#    	echo -e "\e[01;31mERROR! Invalid argument/option. Try again!\e[0m" >&2
    	print_error_message "Invalid argument/option. Try again!"
 	usage
    	errorcode=1
    fi


    echo "Starting at `date`"
    return $errorcode

}

function print_error_message(){

    echo -e "\e[01;31mERROR! $1\e[0m" >&2

}

function usage(){

    echo "Usage: move_novabuild_all_varieties.sh" >&2
    echo "          -h -- print this menu" >&2
    echo "          -5 -- SLF5 build" >&2
    echo "          -6 -- SLF6 build" >&2
    echo "          -d -- development" >&2
    echo "          -f -- first-ana" >&2
    
}

function check_args(){
    
    if [ -z $DO_SLF5 ] && [ -z $DO_SLF6 ];then
	print_error_message "You must choose either SLF5 or SLF6"
	usage
	exit 1
    fi
    
    if [ ! -z $DO_SLF5 ] && [ ! -z $DO_SLF6 ];then
	print_error_message "You must choose either SLF5 or SLF6"
	usage
	exit 1
    fi
    
    if [ -z $DO_DEVELOPMENT ] && [ -z $DO_FIRST_ANA ];then
	print_error_message "You must choose either development or first-ana"
	usage
	exit 1
    fi
    
    if [ ! -z $DO_DEVELOPMENT ] && [ ! -z $DO_FIRST_ANA ];then
	print_error_message "You must choose either development or first-ana"
	usage
	exit 1
    fi
    
    if [ $DO_SLF5 ] && [ $DO_DEVELOPMENT ];then
	day=`date +%a`
	reldir=/build/nova/novasoft/releases/development
	#FIXME -- due to disk space issues on /grid/fermiapp
	#	exportdir=/grid/fermiapp/nova/novaart/novasvn/releases/
	#	exportdir=/nova/app/home/novasoft/slf5/novasoft/releases/
	exportdir=/nova/app/home/novasoft/nova_offline_software/novasoft/slf5/novasoft/releases/
	logfile=/build/nova/logs/move_$day.log
    fi
    
    if [ $DO_SLF5 ] && [ $DO_FIRST_ANA ];then
	day=`date +%a`
	reldir=/build/nova/novasoft/releases/first-ana
	#FIXME -- due to disk space issues on /grid/fermiapp
	#	exportdir=/grid/fermiapp/nova/novaart/novasvn/releases/
	#	exportdir=/nova/app/home/novasoft/slf5/novasoft/releases/
	exportdir=/nova/app/home/novasoft/nova_offline_software/novasoft/slf5/novasoft/releases/
	logfile=/build/nova/logs/branch_move_$day.log
    fi
    
    if [ $DO_SLF6 ] && [ $DO_DEVELOPMENT ];then
	day=`date +%a`
	reldir=/nova/app/home/novasoft/slf6/build/releases/development/
	#	exportdir=/nova/app/home/novasoft/slf6/novasoft/releases/
	exportdir=/nova/app/home/novasoft/nova_offline_software/novasoft/slf6/novasoft/releases/
	logfile=/nova/app/home/novasoft/slf6/logs/move_slf6_${day}.log
    fi
    
    if [ $DO_SLF6 ] && [ $DO_FIRST_ANA ];then
	day=`date +%a`
	reldir=/nova/app/home/novasoft/slf6/build/releases/first-ana/
	#	exportdir=/nova/app/home/novasoft/slf6/novasoft/releases/
	exportdir=/nova/app/home/novasoft/nova_offline_software/novasoft/slf6/novasoft/releases/
	logfile=/nova/app/home/novasoft/slf6/logs/branch_move_slf6_${day}.log
    fi
    
    if [ ! -d $reldir ];then
	print_error_message "reldir \"$reldir\" does not exist"
	exit 1
    fi
    
    if [ ! -d $exportdir ];then
	print_error_message "exportdir \"$exportdir\" does not exist"
	exit 1
    fi
    
}

function print_vars
{
    echo "============================================================"
    echo "move_novabuild_all_varieties.sh"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "day \"$day\""
    echo "reldir \"$reldir\""
    echo "exportdir \"$exportdir\""
    echo "logfile \"$logfile\""
    echo ""
    echo "============================================================"

}

function check_user(){

    echo ""
    user=`whoami`
    if [ ${user} != "novasoft" ]; then
	echo "This script can only be run as novasoft."
	echo "Please log in as novasoft and try executing again."
	echo ""
	exit 1
    fi


}

function clean_release
{

    if [ -e $logfile ]
	then
	rm $logfile
    fi
    
    touch $logfile
#JPD -- we really have to check that reldir and exportdir exist
    if [ ! -e $reldir ]
	then
	echo "reldir $reldir does not exist!" | tee -a $logfile
	echo "Exiting" | tee -a $logfile
	exit 1
    fi
    
    if [ ! -e $exportdir ]
	then
	echo "exportdir $exportdir does not exist!" | tee -a $logfile
	echo "Exiting" | tee -a $logfile
	exit 1
    fi



# Get any applicable subdirectories of lib and delete the object code
    libdirs=`ls -l "$reldir/lib" | egrep '^d' | awk '{print $9}'`
    
    echo "libdirs are" | tee -a $logfile
    echo "$libdirs" | tee -a $logfile

    echo "Deleting object code files from libdirs " | tee -a $logfile
    for dir in $libdirs
      do
      cd "$reldir/lib/$dir"
      echo "Removing *.o from $reldir/lib/$dir" | tee -a $logfile
      rm -f *.o 2>&1 | tee -a $logfile
    done
    
# Clear out the tmp directory
    if [ -e $reldir/tmp ]
	then
	cd "$reldir/tmp"
	tmpdirs=`ls -l | egrep '^d' | awk '{print $9}'`
	echo "Deleting tmp subdirectories " | tee -a $logfile
	for dir in $tmpdirs
	  do
	  echo "dir $dir" | tee -a $logfile
	  if [ -e $dir ]
	      then
	      rm -rf $dir 2>&1 | tee -a $logfile
	  fi
	done
    else
	echo "$reldir/tmp does not exist!" | tee -a $logfile
    fi
    
}

    
function tar_and_move_release(){

    if [ $DO_DEVELOPMENT ];then
	THIS_RELEASE=development
	THIS_RELEASE_SHORT=dev
    else
	THIS_RELEASE=first-ana
	THIS_RELEASE_SHORT=ana
    fi

 # Tar up release
     cd "$reldir/.."


#Check the disk space where we are
     echo "" | tee -a $logfile
     echo "Disk space in \"${PWD}\" is " | tee -a $logfile
     df -h ./ | tee -a $logfile
     echo "" | tee -a $logfile

     echo "Tar up release " | tee -a $logfile
     tar cf ${THIS_RELEASE_SHORT}_$day.tar ${THIS_RELEASE} | tee -a $logfile
     
 # Copy file to other release dir, over writing existant file

#Check the disk space where we are copying things to
     echo "" | tee -a $logfile
     echo "Disk space in \"${exportdir}\" is " | tee -a $logfile
     df -h $exportdir | tee -a $logfile
     echo "" | tee -a $logfile

#Check the quota for /grid/fermiapp

     echo "" | tee -a $logfile
     echo "Group quota for novasoft on /nova/app is " | tee -a $logfile
     quota -gs | grep "/nova/app" -A 1 | tee -a $logfile
     echo "Group quota for novasoft on /grid/fermiapp/ is " | tee -a $logfile
     quota -gs | grep "/fermigrid-fermiapp" -A 1 | tee -a $logfile
     echo ""



     echo "Copying file ${THIS_RELEASE_SHORT}_$day.tar to $exportdir " | tee -a $logfile
     cp -v ${THIS_RELEASE_SHORT}_$day.tar $exportdir 2>&1 | tee -a $logfile
     
     # Now go to the export dir, delete the old ${THIS_RELEASE_SHORT}_$day dir
     # make an empty shell so we can extract the tar ball into it
     # Then link the new release to the ${THIS_RELEASE} directory
     echo "Moving to $exportdir and starting fun there " | tee -a $logfile
     cd $exportdir
     rm -rf ${THIS_RELEASE_SHORT}_$day 2>&1 | tee -a $logfile
     mkdir -v ${THIS_RELEASE_SHORT}_$day 2>&1 | tee -a $logfile
     tar xf ${THIS_RELEASE_SHORT}_$day.tar --strip-components 1 -C ${THIS_RELEASE_SHORT}_$day 2>&1 | tee -a $logfile

     #This captures the status of the tar command.
     #If it's zero then it was successful so make new link
     if [ ${PIPESTATUS[0]} = 0 ]; then
	 echo "" | tee -a $logfile
	 echo "Finished unwinding tarball. Making new softlink." | tee -a $logfile
	 #FIXME -- due to disk space issues on /grid/fermiapp
	 if [ $DO_SLF5 ];then
	     #	 ln -sfT /nova/app/home/novasoft/slf5/novasoft/releases/${THIS_RELEASE_SHORT}_${day} /grid/fermiapp/nova/novaart/novasvn/releases/${THIS_RELEASE}
	     ln -svfT /nova/app/home/novasoft/nova_offline_software/novasoft/slf5/novasoft/releases/${THIS_RELEASE_SHORT}_${day} /grid/fermiapp/nova/novaart/novasvn/releases/${THIS_RELEASE} | tee -a $logfile
	     
	 else
	     #	 ln -sfT ${THIS_RELEASE_SHORT}_$day ${THIS_RELEASE} >> $logfile 2>&1
	     ln -svfT /nova/app/home/novasoft/nova_offline_software/novasoft/slf6/novasoft/releases/${THIS_RELEASE_SHORT}_$day /nova/app/home/novasoft/slf6/novasoft/releases/${THIS_RELEASE} 2>&1 | tee -a $logfile
	 fi
	 
	 rm -v ${THIS_RELEASE_SHORT}_$day.tar 2>&1 | tee -a $logfile
	 
         echo ""
         echo "Creating file ${THIS_RELEASE_SHORT}_${day}/distribution_date with content \"`date +'%F %T'`\""
         echo ""

         echo `date +'%F %T'` > ${THIS_RELEASE_SHORT}_${day}/distribution_date
	 	 
	 echo "Finished Release Migration at `date`" | tee -a $logfile
	 
     else
	 #Failed to untar the build so don't make new link.
	 #Email #managing_releases that it failed.
	 echo "Unwinding the tarball threw an error! Sending email" | tee -a $logfile
	 email_prod
	 echo "Build migration incomplete. Link not updated. Production notified." | tee -a $logfile
     fi
	 
    
}

function email_prod(){

    RECIPIENT="o5l2s5s2o6e7c0b3@neutrino.slack.com"
    
    SUBJECT="novabuild fail! Nightly build migration incomplete"
    
    MESSAGE="Unwinding novabuild tarball failed for \"${THIS_RELEASE}\". \n"
    MESSAGE="$MESSAGE $THIS_RELEASE link NOT updated to $THIS_RELEASE_SHORT. \n"
    MESSAGE="$MESSAGE Likely cause is a Disk quota issue. \n"
    MESSAGE="$MESSAGE Check the logfile for more information: \n"
    MESSAGE="$MESSAGE $logfile \n"
    
    echo -e $MESSAGE | mail -s "$SUBJECT" $RECIPIENT

}


function main(){
    
    process_args "$@"
    check_args
    check_user
    print_vars
    clean_release
    tar_and_move_release
    exit 0;

}

main "$@"
