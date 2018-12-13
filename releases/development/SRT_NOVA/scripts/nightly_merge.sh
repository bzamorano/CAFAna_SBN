#!/bin/bash

#j.p.davies@sussex.ac.uk
#December 2014

#Script to merge changes from development into branches/first-ana to be run in a nightly cronjob
#This is basically the script that Kanika wrote, then I stole

user=`whoami`
echo "user \"$user\""
echo "date `date`"
echo ""


CVSROOT_OFF=svn+ssh://p-novaart@cdcvs.fnal.gov/cvs/projects/novaart/pkgs.svn

function usage(){

    echo "Usage: nightly_merge.sh: <setup directory> <svn co directory>"
    
}


if [ "$1" == "" ] || [ "$2" == "" ];then
    usage 
    exit 1
fi

DEBUG=0

SETUP_DIR=$1
SVN_DIR=$2

echo ""
echo "============================================================"
echo "nightly_merge.sh"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "setup directory: \"$SETUP_DIR\""
echo "svn co directory: \"$SVN_DIR\""
echo ""



#Check these directories are what they say they are

if [ ! -d $SETUP_DIR ];then
    echo "ERROR: SETUP_DIR \"$SETUP_DIR\" does not exist"
    echo "============================================================" 
    echo ""
    usage
    exit 1
fi

if [ -d $SVN_DIR ];then
    rm -rf $SVN_DIR
fi

mkdir -p $SVN_DIR
cd $SVN_DIR

output_file=${SVN_DIR}/output

svn co ${CVSROOT_OFF}/branches/first-ana ./ >> ${output_file}


echo "" >> $output_file 2>&1
echo "SETUP_DIR \"$SETUP_DIR\"" >> $output_file 2>&1
echo "" >> $output_file 2>&1
cd $SETUP_DIR
svn info &> /dev/null
RETVAL=$?
if [ ! $RETVAL==0  ];then
    echo "Error in getting svn info for SETUP_DIR RETVAL $RETVAL"
    echo "============================================================" 
    echo ""
    cat $output_file
    exit 1
fi
URL=`svn info | grep URL | awk '{print $2 }'`

if [[ "$URL" == *"/trunk/setup"* ]];then
    :
else
    echo "URL needs to be \"${CVSROOT_OFF}/trunk/setup\""
    echo "But it is \"$URL\""
    echo "============================================================" 
    echo ""
    cat $output_file
    exit 1
fi


echo "" >> $output_file 2>&1
echo "SVN_DIR \"$SVN_DIR\"" >> $output_file 2>&1
echo "" >> $output_file 2>&1

cd $SVN_DIR
svn info &> /dev/null
RETVAL=$?
if [ ! $RETVAL==0  ];then
    echo "Error in getting svn info for SVN_DIR RETVAL $RETVAL"
    echo "============================================================" 
    echo ""
    cat $output_file
    exit 1
fi
URL=`svn info | grep URL | awk '{print $2 }'`

if [ "$URL" == "${CVSROOT_OFF}/branches/first-ana" ];then
    :
else
    echo "URL needs to be \"${CVSROOT_OFF}/branches/first-ana\""
    echo "But it is \"$URL\""
    echo "============================================================" 
    echo ""
    cat $output_file
    exit 1
fi



# Make sure the merge-list is up to date.

echo "Updating the setup directory" >> $output_file 2>&1
echo "" >> $output_file 2>&1

cd $SETUP_DIR
svn up >> $output_file 2>&1



# go the the first-ana branch
echo "Updating the CMakeLists.txt file in first-ana" >> $output_file 2>&1
echo "" >> $output_file 2>&1
cd $SVN_DIR

# merge the top level CMakeList file
svn merge --non-interactive ${CVSROOT_OFF}/trunk/CMakeLists.txt >> $output_file 2>&1

echo "Going into each package then updating and merging" >> $output_file 2>&1
echo "" >> $output_file 2>&1


# loop over packages in the merge-list and merge them. Bail if you hit a conflict.
errorcode=0
while read package
do
    echo "cd $package" >> $output_file 2>&1
    cd $package
    svn up >> $output_file 2>&1
    echo "svn merge --non-interactive ${CVSROOT_OFF}/trunk/$package" >> $output_file 2>&1

    mergeinfo=$(svn merge --non-interactive ${CVSROOT_OFF}/trunk/$package)
    
   if [[ $mergeinfo == *conflict* ]]; then 
       echo "Conflicts in merging ${package}. Automated merge will be aborted." >> $output_file 2>&1
       errorcode=1
       break
   fi
   cd $SVN_DIR
   echo "-----------------------" >> $output_file 2>&1

done < $SETUP_DIR//merge-list.txt


if [ ! $errorcode==0 ];then
    echo "ERROR: merging detected a conflict. Will not commit"
    echo "============================================================" 
    echo ""
    cat $output_file
    exit 1
fi

# if we get here, we didn't have a conflict. commit.

if [  $DEBUG == 0 ];then
    svn commit -m "Automated merge of trunk to the first-ana branch." >> $output_file 2>&1
else
    echo "svn commit -m \"Automated merge of trunk to the first-ana branch.\" >> $output_file 2>&1"
fi

RETVAL=$?
if [ ! $RETVAL==0 ];then
    echo "ERROR: Error in committing changes to svn"
    echo "============================================================" 
    echo ""
    cat $output_file
    exit 1  
fi

echo "============================================================" 
echo ""
cat $output_file

exit 0
