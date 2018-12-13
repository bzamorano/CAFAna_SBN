#!/bin/bash

#Brief - This script will create the setup files necessary for tagging a release and commit them to svn

DEBUG=1

function echo_info(){
    echo "INFO  : $@" >&2
}
function echo_error(){
    echo "ERROR : $@" >&2
}


function do_command(){
    if [ ! -z $DEBUG ];then
	echo_info "Doing \"$@\""
	eval $@
	return $?
    fi
}



function check_user()
{

# check that the user is logged in as novasoft                                                                      
    echo ""
    user=`whoami`
    if [ ${user} != "novasoft" ]; then
	echo_info "This script can only be run as novasoft." >&2
	echo_info "Please log in as novasoft and try executing again." >&2
	echo "" >&2
	exit 1
    fi

}

function process_args() 
{

    errorcode=0
    while getopts "hfb:v:n:t:r:c:-:" opt; do
        if [ "$opt" = "-" ]; then
            opt=$OPTARG
	    fi
        gettingopt=1
        case $opt in
            h)
		usage
                errorcode=1
		;;
	    f)
		FORCE=1
		;;
	    r)
                TAG_NAME="$OPTARG"
                ;;
	    n)
		TAG_COLLOQUIAL_NAME="$OPTARG"
		;;
	    t)
		LOCAL_SVN_DIR="$OPTARG"
		;;
	    c)
		TAG_TO_CLONE="$OPTARG"
		;;
	    v)
		REVISION="$OPTARG"
		;;
	    b)
		BRANCH_TO_CLONE="$OPTARG"
		;;

        esac
    done
    if [ "$#" != "0" ] && [ "$gettingopt" != "1" ] && [ "$errorcode" != "1" ]; then
	echo -e "\e[01;31mERROR! Invalid argument/option. Try again!\e[0m" >&2
        usage
	errorcode=1
    fi
    CVSROOT_OFF="svn+ssh://p-novaart@cdcvs.fnal.gov/cvs/projects/novaart/pkgs.svn"

    return $errorcode
}

function check_args(){

    if [ -z "$TAG_NAME" ] || [ -z "$TAG_COLLOQUIAL_NAME" ] || [ -z "$LOCAL_SVN_DIR" ];then
	usage
	exit 1;
    fi

    echo_info "============================================================" 
    echo_info "create_release_svn_files.sh" 
    echo_info "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo_info "tag: \"$TAG_NAME\"" 
    echo_info "tag colloquial name: \"$TAG_COLLOQUIAL_NAME\"" 
    echo_info "local svn dir: \"$LOCAL_SVN_DIR\"" 
    if [ ! -z "$TAG_TO_CLONE" ];then
	echo_info "tag to clone: \"$TAG_TO_CLONE\""
    fi
    if [ ! -z "$BRANCH_TO_CLONE" ];then
	echo_info "branchto clone: \"$BRANCH_TO_CLONE\""
    fi
    echo_info "" 
    echo_info "Date: `date`" 
    echo_info "============================================================" 


}

function usage(){

    echo "Usage: create_release_svn_files.sh " >&2
    echo "         -h print this help" >&2
    echo "         -r <release>" >&2
    echo "         -n <tag colloquial name>" >&2
    echo "         -t <temporary directory for svn actions>" >&2
    echo "         -v <revision> copy from specific revision in repository" >&2    
    echo "         -c <release> copy this tag from an existing tag" >&2
    echo "         -b <release> copy this tag from an existing branch" >&2
    
}


function create_svn_setup_files()
{

    echo_info "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo_info "Creating svn setup files"
    echo_info "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo ""


#1 Check that the local_svn_dir exists and whether we can commit from it
    if [ -d $LOCAL_SVN_DIR ];then

	if [ -z $FORCE ];then

	    echo_error "Local svn directory already exists, aborting";
	    echo_error "dir \"$LOCAL_SVN_DIR\"";
	    exit 1
	else
	    rm -rf $LOCAL_SVN_DIR
	fi
    fi


    if [ ! -z "$TAG_TO_CLONE" ];then
	SETUP_FILE_SUFFIX="$TAG_TO_CLONE"
    elif [ ! -z "$BRANCH_TO_CLONE" ];then
	SETUP_FILE_SUFFIX="$BRANCH_TO_CLONE"
    else
	SETUP_FILE_SUFFIX=development
    fi


    mkdir $LOCAL_SVN_DIR
    

    if [ ! -d $LOCAL_SVN_DIR ];then
	echo_error "Created local svn directory"
	echo_error "dir \"$LOCAL_SVN_DIR\"";
	exit 1
    fi

    echo ""
    echo_info "Checking out the repository"
    echo ""

    cd $LOCAL_SVN_DIR
    do_command "svn co $CVSROOT_OFF/trunk/setup . &> /dev/null"


#2 Make copies of the development nova-externals files
    echo_info "Making new setup files for release"
    echo_info "Creating \"$LOCAL_SVN_DIR/nova-offline-ups-externals-$TAG_NAME\""
    
    
    cp $LOCAL_SVN_DIR/nova-offline-ups-externals-${SETUP_FILE_SUFFIX} $LOCAL_SVN_DIR/nova-offline-ups-externals-$TAG_NAME
    
    echo_info "Creating \"$LOCAL_SVN_DIR/nova-offline-ups-externals-$TAG_NAME-prof\""
    
    cp $LOCAL_SVN_DIR/nova-offline-ups-externals-${SETUP_FILE_SUFFIX}-prof $LOCAL_SVN_DIR/nova-offline-ups-externals-$TAG_NAME-prof
    
#3 Create the packages file

    PACKAGE_LIST_FOR_TAG=$LOCAL_SVN_DIR/packages-$TAG_NAME
    if [ -e $PACKAGE_LIST_FOR_TAG ];then
	rm $PACKAGE_LIST_FOR_TAG
    fi
    
    echo_info "Creating \"$PACKAGE_LIST_FOR_TAG\""
    echo ""
    
#Replace the version HEAD with the TAG_NAME for all packages except SoftRelTools
    while read line
      do
      if [[ $line == SoftRelTools* ]];then
	  echo $line  >> $PACKAGE_LIST_FOR_TAG
      else
	  if [ ! -z $TAG_TO_CLONE ];then
	      echo "${line/$TAG_TO_CLONE/$TAG_NAME}" >> $PACKAGE_LIST_FOR_TAG
	  elif [ ! -z $BRANCH_TO_CLONE ];then
	      echo "${line/$BRANCH_TO_CLONE/$TAG_NAME}" >> $PACKAGE_LIST_FOR_TAG
	  else
	      echo "${line/HEAD/$TAG_NAME}" >> $PACKAGE_LIST_FOR_TAG
	  fi
      fi
    done < $LOCAL_SVN_DIR/packages-${SETUP_FILE_SUFFIX}
    
    
#4 Add the externals and packages files to the repository
    echo_info "Adding the externals and packages files to the repository"
    echo ""    


    cd $LOCAL_SVN_DIR
    do_command "svn add $LOCAL_SVN_DIR/nova-offline-ups-externals-$TAG_NAME"
    do_command "svn add $LOCAL_SVN_DIR/nova-offline-ups-externals-$TAG_NAME-prof"
    do_command "svn add $PACKAGE_LIST_FOR_TAG"
    
#5 Commit externals and packages files to the repository
    
    echo_info "Committing the externals and packages files to the repository"
    echo ""    

    cd $LOCAL_SVN_DIR
    do_command "svn commit $LOCAL_SVN_DIR/nova-offline-ups-externals-$TAG_NAME $LOCAL_SVN_DIR/nova-offline-ups-externals-$TAG_NAME-prof $PACKAGE_LIST_FOR_TAG -m \"Necessary setup files for $TAG_NAME\""

#Get svn revision
    if [ ! -z "$REVISION" ];then
	
	echo_info "Setting SVN_REVISION to REVISION \"$REVISION\"" >&2
	SVN_REVISION=$REVISION
    else
	SVN_REVISION=`svn info $LOCAL_SVN_DIR | grep "Revision:"`
	SVN_REVISION=${SVN_REVISION#Revision: *}
    fi

    if [ -d $LOCAL_SVN_DIR ];then  
	rm -rf $LOCAL_SVN_DIR
    fi


}

function create_svn_release(){

    echo_info "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo_info "Creating svn release files"
    echo_info "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo ""

#6 Svn copy the trunk to the new tag

    if [ -z "$TAG_TO_CLONE" ] && [ -z "$BRANCH_TO_CLONE" ];then
	echo_info "This is development tag, so just copying from trunk to tags/"
	echo ""

	do_command "svn cp -r $SVN_REVISION $CVSROOT_OFF/trunk $CVSROOT_OFF/tags/$TAG_NAME -m \"Create frozen release corresponding to revision $SVN_REVISION with tag $TAG_NAME, the $TAG_COLLOQUIAL_NAME release.\""

	for file in nova-offline-ups-externals-$TAG_NAME nova-offline-ups-externals-$TAG_NAME-prof packages-$TAG_NAME
	do
	    echo_info "Copying \"$file\" to Tag \"$TAG_NAME\""
	    do_command "svn cp $CVSROOT_OFF/trunk/setup/$file $CVSROOT_OFF/tags/$TAG_NAME/setup/ -m \"Adding setup files\""
	done

#Not development. Check if cloning tag
    fi

    if [ ! -z "$TAG_TO_CLONE" ];then
	echo_info "Cloning Tag \"$TAG_TO_CLONE\" to create Tag \"$TAG_NAME\""

	do_command "svn cp -r $SVN_REVISION $CVSROOT_OFF/tags/$TAG_TO_CLONE $CVSROOT_OFF/tags/$TAG_NAME -m \"Create a frozen hot-fix release corresponding to revision $SVN_REVISION with tag $TAG_NAME, the $TAG_COLLOQUIAL_NAME release based on $TAG_TO_CLONE.\""

	for file in nova-offline-ups-externals-$TAG_NAME nova-offline-ups-externals-$TAG_NAME-prof packages-$TAG_NAME
	do
	  echo_info "Copying \"$file\" to Tag \"$TAG_NAME\""
	  do_command "svn cp $CVSROOT_OFF/trunk/setup/$file $CVSROOT_OFF/tags/$TAG_NAME/setup/ -m \"Adding setup files\""
	done

    fi

#Not development. Not a tag. Check if cloning a branch

    if [ ! -z "$BRANCH_TO_CLONE" ];then
	echo_info "Cloning Tag \"$BRANCH_TO_CLONE\" to create Tag \"$TAG_NAME\""

	do_command "svn cp -r $SVN_REVISION $CVSROOT_OFF/branches/$BRANCH_TO_CLONE $CVSROOT_OFF/tags/$TAG_NAME -m \"Create a frozen release corresponding to revision $SVN_REVISION with tag $TAG_NAME, the $TAG_COLLOQUIAL_NAME release based on the branch $BRANCH_TO_CLONE.\""

	for file in nova-offline-ups-externals-$TAG_NAME nova-offline-ups-externals-$TAG_NAME-prof packages-$TAG_NAME
	do
	  echo_info "Copying \"$file\" to Tag \"$TAG_NAME\""
	  do_command "svn cp $CVSROOT_OFF/trunk/setup/$file $CVSROOT_OFF/tags/$TAG_NAME/setup/ -m \"Adding setup files\""
	done

    fi



    if [ -d $LOCAL_SVN_DIR ];then  
	rm -rf $LOCAL_SVN_DIR
    fi

}


function main(){
 
    check_user
    process_args "$@"
    check_args
    create_svn_setup_files
    create_svn_release
    exit 0

}

main "$@"



