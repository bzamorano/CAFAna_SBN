#!/bin/bash

# Assumes one has setup novasoft beforehand
# Grabs the build type (default if none given is debug)
# Grabs the software version (default is development of course)
# Then sets up the necessary GRID env. variables etc
# This needs to be sourced in the grid submission script also now

build=debug
release=development

if [ $# -eq 0 ];
then
    build=debug
    release=development
fi

while [[ $# > 1 ]]
do
    key="$1"
    shift
    
    case $key in
	-r|--rel)
	    release="$1"
	    shift
	    ;;
	-b|--build)
	    build="$1"
	    shift
	    ;;
	*)
	    ;;
    esac
done
	
############
# Define the job script, executable, release and build type
export NOVA_RELEASE=$release
export BUILD=$build


#############
# Setup Jobsub
# Only setup jobsub_tools and jobsub_client interactively, not in grid jobs
if [ -d /grid/fermiapp/ -a -z "${_CONDOR_SCRATCH_DIR}" ]; then
    #Temporary: undo once "test" version is "current"
    setup jobsub_client
fi


# Set Database variables for production
if [ ! -z "${_CONDOR_SCRATCH_DIR}" ]; then
    export NOVADBTIMEOUT=1800
    export NOVADBUSER=nova_grid
    export NOVAHWDBUSER=nova_grid
    # Be extra safe and set both for now
    export NOVADBPWDFILE=${SRT_PUBLIC_CONTEXT}/Database/config/nova_grid_pwd
    export NOVADBGRIDPWDFILE=${SRT_PUBLIC_CONTEXT}/Database/config/nova_grid_pwd
fi

