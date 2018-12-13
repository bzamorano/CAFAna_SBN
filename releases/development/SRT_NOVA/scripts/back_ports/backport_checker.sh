#!/bin/bash

#backport_checker
#j.p.davies@sussex.ac.uk
#15-06-16
#
#Check that backports have been applied correctly. This should just be 

THIS_DEBUG=0

function do_sys_command(){

    if [ "$THIS_DEBUG" -gt 1 ];then
	echo "COMMAND:  \"$@\"" >&2
	echo "" >&2
    else
	eval $@
    fi

}

function ask_yes_or_no() {

 
    THIS_MESSAGE="USER   :  $@? (y/n): "
    read  -r -p "$THIS_MESSAGE" REPLY
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
	return 0
    else
        echo-info "Skipping"
	return 1
    fi

}

function echo-info(){

    echo "INFO   :  $@" >&2

}

function echo-error(){

    echo "ERROR  :  $@" >&2

}

function echo-warn(){

    echo "WARNING:  $@" >&2

}

function usage(){

    echo "" >&2
    echo-error "Usage `basename $0` <releases_base_dir> <releases_file> <diffs_file>"
    echo "" >&2
    echo-info "<releases_base_dir> -- e.g. /nova/app/home/novasoft/nova_offline_software/novasoft/slf6/novasoft/releases"
    echo-info "<releases_file>     -- should contain a list of releases (one per line)"
    echo-info "<diffs_file>        -- should contain a line per fcl that should be update via a backport"
    echo-info "                    -- for fcls that get installed into the job/ directory each line should be"
    echo-info "                        -- path/to/fclname.fcl job/fclname.fcl"
    echo-info "                    -- for fcls that do not get installed anywhere each line should be"
    echo-info "                        -- path/to/fclname.fcl "
}

if [ $# -lt 3 ];then
    usage
    exit 1
fi

THIS_RELEASES_BASE_DIR=$1
THIS_RELEASE_FILE=$2
THIS_DIFF_FILE=$3



#First create array of all the releases
THIS_LINE_NUM=0;
while read THIS_LINE; do
    RELEASES_ARRAY[$THIS_LINE_NUM]=$THIS_LINE ; 
#    echo "THIS_LINE_NUM $THIS_LINE_NUM RELEASES_ARRAY[$THIS_LINE_NUM] ${RELEASES_ARRAY[$THIS_LINE_NUM]}"
    THIS_LINE_NUM=$(( THIS_LINE_NUM +1 )); 
done < $THIS_RELEASE_FILE

#Second create array of all the diffs
THIS_LINE_NUM=0;
while read THIS_LINE; do
    DIFF_ARRAY[$THIS_LINE_NUM]=$THIS_LINE ; 
#    echo "THIS_LINE_NUM $THIS_LINE_NUM DIFF_ARRAY[$THIS_LINE_NUM] ${DIFF_ARRAY[$THIS_LINE_NUM]}"
    THIS_LINE_NUM=$(( THIS_LINE_NUM +1 )); 
done < $THIS_DIFF_FILE


for ((i = 0; i < ${#RELEASES_ARRAY[@]}; i++))
do
  echo "" >&2
  RELEASE=${RELEASES_ARRAY[$i]}
  echo-info $RELEASE
  echo "" >&2
  THIS_RELEASE_DIR=${THIS_RELEASES_BASE_DIR}/${RELEASE}
#  echo-info "THIS_RELEASE_DIR \"$THIS_RELEASE_DIR\""

  if [ ! -e $THIS_RELEASE_DIR ];then
      echo-error "THIS_RELEASE_DIR doesn't exist"
      continue
  fi

  for ((j = 0; j < ${#DIFF_ARRAY[@]}; j++))
    do

    DIFF_PAIR=${DIFF_ARRAY[$j]}
    echo-info "DIFF_PAIR \"$DIFF_PAIR\""

    DIFF_PAIR=( $DIFF_PAIR ) #Recasts as an array
    NUM_DIFF_PAIR=${#DIFF_PAIR[@]}

    #Item 1) in the diff pair is the revision

    #Item 2) in the diff par is the thing to be updated

    #Item 3) (if it exists) is the install location

    #All pairs have at least Item 1) and Item 2). 
    #Find the directory, then do an svn update there
    echo-info "DIFF_PAIR[1] \"${DIFF_PAIR[1]}\""
    DIFF_DIR=${DIFF_PAIR[1]%*/*}
    echo-info "DIFF_DIR \"$DIFF_DIR\""
    
    SVN_UPDATE_COMMAND="cd $THIS_RELEASE_DIR/$DIFF_DIR; svn update; cd -"
    echo-info "SVN_UPDATE_COMMAND \"$SVN_UPDATE_COMMAND\""

    if [ "$THIS_DEBUG" -gt 0 ];then
	if ask_yes_or_no "SVN UPDATE";
	then
	    do_sys_command "$SVN_UPDATE_COMMAND"
	fi
    else
	do_sys_command "$SVN_UPDATE_COMMAND"
    fi
    
#Now if Item 3). do a 'cp' then a 'diff'
    if [ "$NUM_DIFF_PAIR" -gt 2 ];then

	COPY_COMMAND="cp $THIS_RELEASE_DIR/${DIFF_PAIR[1]} $THIS_RELEASE_DIR/${DIFF_PAIR[2]}"
	DIFF_COMMAND="diff $THIS_RELEASE_DIR/${DIFF_PAIR[1]} $THIS_RELEASE_DIR/${DIFF_PAIR[2]}"


	if [ "$THIS_DEBUG" -gt 0 ];then
	    echo-info "COPY_COMMAND \"$COPY_COMMAND\""
	    if ask_yes_or_no "CP to job/";
	    then
		do_sys_command "$COPY_COMMAND"
	    fi
	    
	    echo-info "DIFF_COMMAND \"$DIFF_COMMAND\""
	    if ask_yes_or_no "DIFF";	    
	    then
		do_sys_command "$DIFF_COMMAND"
	    fi
	else
	    echo-info "COPY_COMMAND \"$COPY_COMMAND\""
	    do_sys_command "$COPY_COMMAND"
	    echo-info "DIFF_COMMAND \"$DIFF_COMMAND\""
	    do_sys_command "$DIFF_COMMAND"
	fi

    fi

    BACKPORT_INFO_COMMAND="echo \"Backport revision ${DIFF_PAIR[0]} of ${DIFF_PAIR[1]} in release $RELEASE\" >> $THIS_RELEASE_DIR/backports"
    echo-info "BACKPORT_INFO_COMMAND \"$BACKPORT_INFO_COMMAND\""
    if ask_yes_or_no "LOG BACKPORT";
    then
	do_sys_command "$BACKPORT_INFO_COMMAND"
    fi


    echo "" >&2
  done

done



