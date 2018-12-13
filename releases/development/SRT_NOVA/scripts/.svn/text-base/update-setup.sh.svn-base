#!/bin/bash

# This is just a quick script to setup novasoft and update
# the setup directory used to source the releases on the 
# FNAL VMs. Only necessary since the releases get built
# locally on a dedicated build machine.

source /grid/fermiapp/nova/novaart/novasvn/setup/setup_nova.sh -5 "/grid/fermiapp/nova/novaart/novasvn" -6 "/grid/fermiapp/nova/novaart/novasvn"

echo "Starting at `date`"
echo "Updating the following directory"
echo "$SRT_DIST/setup"

cd $SRT_DIST/setup

svn update
