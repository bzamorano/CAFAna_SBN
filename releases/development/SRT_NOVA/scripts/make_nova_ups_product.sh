#!/bin/bash

prodpath=/grid/fermiapp/products/nova/externals

# check that the user is logged in as novasoft
echo ""
user=`whoami`
if [ ${user} != "novasoft" ]; then
    echo "This script can only be run as novasoft."
    echo "Please log in as novasoft and try executing again."
    echo ""
    exit -1
fi

# check that the appropriate number of arguments are specified.
if [ ${#@} != 2 ]; then
    echo "This script requires exactly two arguments:"
    echo "1/ The product name of UPS product to be created"
    echo "2/ The version number of UPS product to be created"
    echo ""
    echo "Try executing again."
    exit -1
fi 

prodname=$1
version=$2
srcdir=/tmp/${prodname}_${version}

if [ ! -d "$prodpath/$1" ]; then
    echo "$1 is not a valid name for package."
    echo "Package $1 does not exist. Typo?"
    echo "Apologies if you are creating package for first time."
    echo "We have this check to avoid human error."
    echo ""
    echo "Try executing again."
    exit
fi

# check that the second argument is in a valid version format
if [[ ! ${version} =~ ^v\.?[0-9][0-9]\.[0-9][0-9]$ ]] ; then 
    echo "Version number of type ${version} are not allowed." 
    echo "Allowed version numbers should follow the vXX.XX scheme."
    echo ""
    echo "Try executing again."
    exit -1
fi

# check that setup_nova has NOT been run
if [[ ${NOVASOFT_SETUP} == 1 ]] ; then
    #setup slf5/slf6 depending on the machine we are running on
    echo "setup_nova has been run.Try again, without setting up novasoft."
    exit -1
fi

source $prodpath/setup
setup ups
setup upd


echo "Source location: ${srcdir}"
echo "Version to declare: ${version}"

# check if the first argument is a valid path
if [  -d "${srcdir}" ]; then
    echo "${srcdir} is already exists!!  Cannot do clean checkout!"
    echo "Aborting"
    exit -1
fi

# Only need read-only version, not committing from here
CVSROOT=http://cdcvs.fnal.gov/subversion/novaart.pkgs.svn

svn co $CVSROOT/trunk/${prodname} ${srcdir}

proddir=${prodpath}/${prodname}
dest=${proddir}/${version}/NULL

echo "Product will be created in ${proddir}"
if [ ! -d "${proddir}" ]; then
    mkdir -p ${proddir}
fi


if [ -d "${proddir}/${version}" ]; then
    echo ""
    echo "Product ${prodname} with version ${version} already exists." 
    echo "Making it again will over-write the existing one."
    echo ""
    read -p "Are you sure you want to proceed (y/n)? " -n 1 -r
    echo   
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
	echo "OK. If you say so."
    else
	echo "The script will now abort. Try again with a different version."
	exit -1
    fi
fi



mkdir -p ${dest}
echo "Copying files from ${srcdir} to ${dest}"

rsync --exclude '*~' --exclude '*.svn' -rL $srcdir/* ${dest}

ups_table=${dest}/ups/${prodname}.table
if [ ! -f "${ups_table}" ] ; then
    echo "Error!!  UPS table ${ups_table} does not exist!!"
    exit -1
fi

echo "Updating table file"
cap_prodname=`echo ${prodname} | tr [:lower:] [:upper:]`
sed -i -e "s:XXVERSIONXX:${version}:" \
       ${ups_table}

echo  "Declaring product ${prodname} with version ${version} to UPS."

ups declare -f NULL -z ${prodpath} \
    -r ${prodpath}/${prodname}/${version}/NULL \
    -m ${prodname}.table \
    ${prodname} ${version}

retval=$?
test $retval -ne 0 && echo "ERROR : 'ups declare' returned non-zero - BAILING" && exit 1

echo "Adding product to UPD.."
cd ${proddir}/${version}/NULL/

upd addproduct ${prodname} ${version} 
retval=$?
test $retval -ne 0 && echo "ERROR : 'upd addproduct' returned non-zero - BAILING" && exit 1

echo "Removing the directory and contents: ${srcdir}"
# Clean up when all is said and done
rm -rf ${srcdir}

echo "All done!"
