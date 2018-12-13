#!/usr/bin/env bash

#This pre-build step is to make sure that we have bootstrapped srt / novasoft

#Make some directories
mkdir -p $WORKSPACE/buildout
rm -rf $WORKSPACE/buildout/*


cd ${WORKSPACE}
if [ -e nova_srt_bootstrap ]; then
    echo "removing nova_srt_bootstrap"
    rm -f nova_srt_bootstrap
fi 

if [ ! -e nova_srt_bootstrap ];then
  wget https://cdcvs.fnal.gov/redmine/projects/novaart/repository/raw/trunk/SRT_NOVA/scripts/nova_srt_bootstrap
  chmod +x nova_srt_bootstrap
fi

./nova_srt_bootstrap ${WORKSPACE}

source ${WORKSPACE}/srt/srt.sh

#Now clear out the old release

rm -rf ${WORKSPACE}/releases/${RELEASE}

#Now we need to update the release (check out the code)
if [ -e update-release ]; then
    echo "removing update-release"
    rm -f update-release
fi 

if [ ! -e update-release ];then
  wget https://cdcvs.fnal.gov/redmine/projects/novaart/repository/raw/trunk/SRT_NOVA/scripts/update-release
  chmod +x update-release
fi

if [ "$BRANCH" == "TRUE" ];then
  ./update-release -rel $RELEASE -b
else
  ./update-release -rel $RELEASE
fi

cd ${WORKSPACE}/setup/
svn update
