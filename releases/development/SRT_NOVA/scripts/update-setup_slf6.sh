#!/bin/bash

# This is just a quick script to setup novasoft and update
# the setup directory used to source the releases on the 
# FNAL VMs. Only necessary since the releases get built
# locally on a dedicated build machine.

source /nova/app/home/novasoft/slf6/novasoft/setup/setup_nova.sh -5 "/nova/app/home/novasoft/slf6/novasoft" -6 "/nova/app/home/novasoft/slf6/novasoft"

echo "Starting at `date`"
echo "Updating the following directory"
echo "$SRT_DIST/setup"

cd $SRT_DIST/setup

svn update

NIGHTLY_BUILD_DIR=/nova/app/home/novasoft/nightly_build

for DIR in ${NIGHTLY_BUILD_DIR}/{setup,SRT_NOVA}; do
echo "Updating ${DIR}"
cd $DIR
svn update
done
