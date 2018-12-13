#!/bin/bash

#Name: build_novaart_release.sh
#Brief: Update a release, then build both the debug and maxopt versions of it

TEMP_SCRIPTS_DIR=~/user_dirs/jpdavies/scripts/temp_build_scripts

function usage(){

    echo "Usage: build_novaart_release.sh <release>" >&2

}

source ~/.bashrc
setup_jpdavies

#1. Find out which system we are on slf5 / slf6

redhat=`cat /etc/redhat-release`
if [[ "$redhat" =~ "release 6." ]] ; then
    os=slf6
elif [[ "$redhat" =~ "release 5." ]] ; then
    os=slf5
else
    echo "Unkown release of slf. redhat $redhat" >&2
    exit 1
fi

#2. Find out which release we want to build

if [ "$1" == "" ]; then
    usage
    exit 1
fi

release=$1

mkdir -p $TEMP_SCRIPTS_DIR/${release}/${os}/


#3. Create the update-release script
UPDATE_RELEASE_SCRIPT=$TEMP_SCRIPTS_DIR/${release}/${os}/update-release_${release}_${os}.sh
if [ -e $UPDATE_RELEASE_SCRIPT ]; then
    rm $UPDATE_RELEASE_SCRIPT
fi
echo -e "#!/bin/bash\n" >> $UPDATE_RELEASE_SCRIPT
echo -e "source ~/.bashrc\n" >> $UPDATE_RELEASE_SCRIPT

if [ "$os" == "slf5" ];then
  echo -e "setup_nova_build\n" >> $UPDATE_RELEASE_SCRIPT  
elif [ "$os" == "slf6" ];then
    echo -e "setup_nova_build_slf6\n" >> $UPDATE_RELEASE_SCRIPT  
fi

echo -e "echo \"Updating release $release\"\n"  >> $UPDATE_RELEASE_SCRIPT
echo -e "echo \"SRT_PUBLIC_CONTEXT \$SRT_PUBLIC_CONTEXT\"\n"  >> $UPDATE_RELEASE_SCRIPT

echo -e "cd \$SRT_PUBLIC_CONTEXT\n" >> $UPDATE_RELEASE_SCRIPT

if [ "$release" == "first-ana" ];then
    echo -e "./SRT_NOVA/scripts/update-release -rel $release -b\n" >> $UPDATE_RELEASE_SCRIPT
else
    echo -e "./SRT_NOVA/scripts/update-release -rel $release\n" >> $UPDATE_RELEASE_SCRIPT
fi

#4. Create the debug script to run
BUILD_DEBUG_SCRIPT=$TEMP_SCRIPTS_DIR/${release}/${os}/build_${release}_debug_${os}.sh
if [ -e $BUILD_DEBUG_SCRIPT ]; then
    rm $BUILD_DEBUG_SCRIPT
fi

echo -e "#!/bin/bash\n" >> $BUILD_DEBUG_SCRIPT
echo -e "source ~/.bashrc\n" >> $BUILD_DEBUG_SCRIPT


if [ "$os" == "slf5" ];then
  echo -e "setup_nova_build -r $release\n" >> $BUILD_DEBUG_SCRIPT
elif [ "$os" == "slf6" ];then
    echo -e "setup_nova_build_slf6 -r $release\n" >> $BUILD_DEBUG_SCRIPT
fi

echo -e "echo \"SRT_PUBLIC_CONTEXT \$SRT_PUBLIC_CONTEXT\"\n"  >> $BUILD_DEBUG_SCRIPT

echo -e "cd \$SRT_PUBLIC_CONTEXT\n" >> $BUILD_DEBUG_SCRIPT
echo -e "echo output written to \$SRT_PUBLIC_CONTEXT/build.log\n" >> $BUILD_DEBUG_SCRIPT

echo -e "./SRT_NOVA/scripts/novasoft_build -rel $release -p 17 -debug &> build.log\n" >> $BUILD_DEBUG_SCRIPT

#5. Create the maxopt script to run
BUILD_MAXOPT_SCRIPT=$TEMP_SCRIPTS_DIR/${release}/${os}/build_${release}_maxopt_${os}.sh
if [ -e $BUILD_MAXOPT_SCRIPT ]; then
    rm $BUILD_MAXOPT_SCRIPT
fi

echo -e "#!/bin/bash\n" >> $BUILD_MAXOPT_SCRIPT
echo -e "source ~/.bashrc\n" >> $BUILD_MAXOPT_SCRIPT

if [ "$os" == "slf5" ];then
  echo -e "setup_nova_build -r $release -b maxopt\n" >> $BUILD_MAXOPT_SCRIPT
elif [ "$os" == "slf6" ];then
    echo -e "setup_nova_build_slf6 -r $release -b maxopt\n" >> $BUILD_MAXOPT_SCRIPT
fi

echo -e "echo \"SRT_PUBLIC_CONTEXT \$SRT_PUBLIC_CONTEXT\"\n"  >> $BUILD_MAXOPT_SCRIPT

echo -e "cd \$SRT_PUBLIC_CONTEXT\n" >> $BUILD_MAXOPT_SCRIPT
echo -e "echo output written to \$SRT_PUBLIC_CONTEXT/build_maxopt.log\n" >> $BUILD_MAXOPT_SCRIPT

echo -e "./SRT_NOVA/scripts/novasoft_build -rel $release -p 17  &> build_maxopt.log\n" >> $BUILD_MAXOPT_SCRIPT

#6. Run the scipts
chmod +x $UPDATE_RELEASE_SCRIPT
chmod +x $BUILD_DEBUG_SCRIPT
chmod +x $BUILD_MAXOPT_SCRIPT
 
echo "Updating release at `date`"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++"

$UPDATE_RELEASE_SCRIPT &> ${UPDATE_RELEASE_SCRIPT}.output

echo "Finished updating release"
echo ""

send_jpd_mail "Updated $os $release: `date`" "Finished updating $os $release `date`"

echo "Building debug at `date`"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++"

$BUILD_DEBUG_SCRIPT > ${BUILD_DEBUG_SCRIPT}.output

echo "Finished building debug"
echo ""

send_jpd_mail "Built $os $release debug: `date`" "Finished building $os $release debug `date`"

echo "Building maxopt at `date`"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++"

$BUILD_MAXOPT_SCRIPT > ${BUILD_MAXOPT_SCRIPT}.output

echo "Finished building maxopt"
echo ""

send_jpd_mail "Built $os $release maxopt: `date`" "Finished building $os $release maxopt `date`"

echo "Finished at `date`"

exit 0
