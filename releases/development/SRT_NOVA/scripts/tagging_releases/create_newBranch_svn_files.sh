#!/bin/bash

#This script will create the setup files necessary for producing a special development branch and commit them to svn
#The script can also produce tags from the special development branch.

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
    while getopts "hfv:n:t:r:c:-:" opt; do
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
                BRANCH_NAME="$OPTARG"
                ;;
	    n)
		BRANCH_COLLOQUIAL_NAME="$OPTARG"
		;;
	    t)
		LOCAL_SVN_DIR="$OPTARG"
		;;
	    c)
		BRANCH_TO_CLONE="$OPTARG"
		;;
	    v)
		REVISION="$OPTARG"
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

    if [ -z "$BRANCH_NAME" ] || [ -z "$BRANCH_COLLOQUIAL_NAME" ] || [ -z "$LOCAL_SVN_DIR" ];then
	usage
	exit 1;
    fi

    echo_info "============================================================" 
    echo_info "create_newBranch_svn_files.sh"
    echo_info "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo_info "branch/tag: \"$BRANCH_NAME\""
    echo_info "branch/tag colloquial name: \"$BRANCH_COLLOQUIAL_NAME\""
    echo_info "local svn dir: \"$LOCAL_SVN_DIR\"" 
    if [ ! -z "$BRANCH_TO_CLONE" ];then
	echo_info "branch to clone to tag: \"$BRANCH_TO_CLONE\""
    fi
    echo_info "" 
    echo_info "Date: `date`" 
    echo_info "============================================================" 


}

function usage(){

    echo "Usage: create_newBranch_svn_files.sh " >&2
    echo "         -h print this help" >&2
    echo "         -r <release>" >&2
    echo "         -n <branch colloquial name>" >&2
    echo "         -t <temporary directory for svn actions>" >&2
    echo "         -v <revision> copy from specific revision in repository" >&2    
    echo "         -c <release> copy this branch from an existing one" >&2
    
}


function create_newBranch_svn_files()
{

    echo_info "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo_info "Creating svn setup files for new branch"
    echo_info "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" 
    echo ""


#1 Check that the local_svn_dir exists and whether we can commit from it
    if [ -d $LOCAL_SVN_DIR ];then

	if [ -z $FORCE ];then

	    echo_error "Local svn directory already exists, aborting";
	    echo "       dir \"$LOCAL_SVN_DIR\"";
	    exit 1
	else
	    rm -rf $LOCAL_SVN_DIR
	fi
    fi


    if [ ! -z "$BRANCH_TO_CLONE" ];then
	SETUP_FILE_SUFFIX="$BRANCH_TO_CLONE"
    else
	SETUP_FILE_SUFFIX=development
    fi


    mkdir $LOCAL_SVN_DIR
    

    if [ ! -d $LOCAL_SVN_DIR ];then
	echo_error "Created local svn directory"
	echo "       dir \"$LOCAL_SVN_DIR\"";
	exit 1
    fi

    echo ""
    echo_info "Checking out the repository"
    echo ""

    cd $LOCAL_SVN_DIR
   
    # copy trunk to new development branch here
    if [ -z "$BRANCH_TO_CLONE" ];then
        svn co svn+ssh://p-novaart@cdcvs.fnal.gov/cvs/projects/novaart/pkgs.svn/trunk/setup . &> /dev/null
    else
        svn co svn+ssh://p-novaart@cdcvs.fnal.gov/cvs/projects/novaart/pkgs.svn/branches/$BRANCH_TO_CLONE/setup . &> /dev/null
    fi



#2 Make copies of the development nova-externals files
    echo_info "Making new setup files for branch"
    echo_info "Creating \"$LOCAL_SVN_DIR/nova-offline-ups-externals-$BRANCH_NAME\""
    
    
    cp $LOCAL_SVN_DIR/nova-offline-ups-externals-${SETUP_FILE_SUFFIX} $LOCAL_SVN_DIR/nova-offline-ups-externals-$BRANCH_NAME
    
    echo_info "Creating \"$LOCAL_SVN_DIR/nova-offline-ups-externals-$BRANCH_NAME-prof\""
    
    cp $LOCAL_SVN_DIR/nova-offline-ups-externals-${SETUP_FILE_SUFFIX}-prof $LOCAL_SVN_DIR/nova-offline-ups-externals-$BRANCH_NAME-prof
    
#3 Create the packages file

    PACKAGE_LIST_FOR_BRANCH=$LOCAL_SVN_DIR/packages-$BRANCH_NAME
    if [ -e $PACKAGE_LIST_FOR_BRANCH ];then
	rm $PACKAGE_LIST_FOR_BRANCH
    fi
    
    echo_info "Creating \"$PACKAGE_LIST_FOR_BRANCH\""
    echo ""
    
#Replace the version HEAD with the BRANCH_NAME for all packages except SoftRelTools
    while read line
      do
      if [[ $line == SoftRelTools* ]];then
	  echo $line  >> $PACKAGE_LIST_FOR_BRANCH
      else
	  if [ ! -z $BRANCH_TO_CLONE ];then
	      echo "${line/$BRANCH_TO_CLONE/$BRANCH_NAME}" >> $PACKAGE_LIST_FOR_BRANCH
	  else
	      echo "${line/HEAD/$BRANCH_NAME}" >> $PACKAGE_LIST_FOR_BRANCH
	  fi
      fi
    done < $LOCAL_SVN_DIR/packages-${SETUP_FILE_SUFFIX}
    
    
#4 Add the externals and packages files to the repository
    echo_info "Adding the externals and packages files to the repository"
    echo ""    


    cd $LOCAL_SVN_DIR
    svn add $LOCAL_SVN_DIR/nova-offline-ups-externals-$BRANCH_NAME
    svn add $LOCAL_SVN_DIR/nova-offline-ups-externals-$BRANCH_NAME-prof
    svn add $PACKAGE_LIST_FOR_BRANCH
    
#5 Commit externals and packages files to the repository
    
    echo_info "Committing the externals and packages files to the repository"
    echo ""    

    cd $LOCAL_SVN_DIR
    svn commit $LOCAL_SVN_DIR/nova-offline-ups-externals-$BRANCH_NAME $LOCAL_SVN_DIR/nova-offline-ups-externals-$BRANCH_NAME-prof $PACKAGE_LIST_FOR_BRANCH -m "Necessary setup files for $BRANCH_NAME"

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

# Svn copy the trunk to the new branch -> this makes the new development branch.

    if [ -z "$BRANCH_TO_CLONE" ];then
	echo_info "This is special development branch, so just copying from trunk to branch/"
	echo ""

	svn cp -r $SVN_REVISION $CVSROOT_OFF/trunk $CVSROOT_OFF/branches/$BRANCH_NAME -m "Create new development branch corresponding to revision $SVN_REVISION with branch $BRANCH_NAME, the $BRANCH_COLLOQUIAL_NAME release."

	for file in nova-offline-ups-externals-$BRANCH_NAME nova-offline-ups-externals-$BRANCH_NAME-prof packages-$BRANCH_NAME
	do
	    echo_info "Copying \"$file\" to Branch \"$BRANCH_NAME\""
	    svn cp $CVSROOT_OFF/trunk/setup/$file $CVSROOT_OFF/branches/$BRANCH_NAME/setup/ -m "Adding setup files"
	done

# Check if cloning branch -> this is for making new tags from special development branches.
    else
	echo_info "Cloning Branch \"$BRANCH_TO_CLONE\" to create tag from special branch \"$BRANCH_NAME\""

	svn cp -r $SVN_REVISION $CVSROOT_OFF/branches/$BRANCH_TO_CLONE $CVSROOT_OFF/tags/$BRANCH_NAME -m "Create a tagged release corresponding to revision $SVN_REVISION with tag name $BRANCH_NAME, the $BRANCH_COLLOQUIAL_NAME release based on the branch $BRANCH_TO_CLONE."

	for file in nova-offline-ups-externals-$BRANCH_NAME nova-offline-ups-externals-$BRANCH_NAME-prof packages-$BRANCH_NAME
	do
	  echo_info "Copying \"$file\" to tag \"$BRANCH_NAME\""
          # In this case - setup files committed to branch.
          # Add them to tag and trunk
	  svn cp $CVSROOT_OFF/branches/$BRANCH_TO_CLONE/setup/$file $CVSROOT_OFF/tags/$BRANCH_NAME/setup/ -m "Adding setup files"
	  svn cp $CVSROOT_OFF/branches/$BRANCH_TO_CLONE/setup/$file $CVSROOT_OFF/trunk/setup/ -m "Adding setup files"
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
    create_newBranch_svn_files
    create_svn_release
    exit 0

}

main "$@"



