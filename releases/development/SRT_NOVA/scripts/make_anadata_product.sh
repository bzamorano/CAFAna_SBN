#!/bin/bash

# Script for making a ups product, and installing in upd, that contains
# analysis data files i.e. predictions, systs
#
# Example:
# ./make_anadata_product.sh </path/to/data/files> nusdata v00.00 17

# check that the user is logged in as novasoft
echo ""
user=`whoami`
if [ ${user} != "novasoft" ]; then
    echo "This script can only be run as novasoft."
    echo "Please log in as novasoft and try executing again."
    echo ""
    exit
fi

# check that the appropriate number of arguments are specified.
if [ ${#@} != 4 ]; then
    echo "The scripts requires three arguments:"
    echo "1) The location of analysis data files"
    echo "2) analysis data package name i.e. nusdata, nuedata, etc. "
    echo "3) Version number of UPS product to be created"
    echo "4) Which analysis year? 17, 18, 19 etc..."
    echo ""
    echo "Try executing again."
    exit
fi

# check if the first argument is a valid path to analysis data files
if [ ! -d "$1" ]; then
    echo "$1 is an invalid path."
    echo "The first argument should be a valid path to analysis data files."
    echo ""
    echo "Try executing again."
    exit
fi

# check that setup_nova has NOT been run
if [[ ${NOVASOFT_SETUP} == 1 ]] ; then
    echo "setup_nova has been run.Try again, without setting up novasoft."
    exit -1
fi
    
if [[ ! $2 =~ ^(nusdata|numudata|nuedata)$ ]]; then
   echo "Valid options are:"
   echo "nusdata, numudata, nuedata"
   echo "Try executing again."
   exit
fi

# check that the third argument is in a valid version format
if [[ ! $3 =~ ^v\.?[0-9][0-9]\.[0-9][0-9]$ ]] ; then 
    echo "Version number of type $3 are not allowed." 
    echo "Allowed version numbers should follow the vXX.XX scheme."
    echo ""
    echo "Try executing again."
    exit
fi

# check that the fourth argument is a valid year
if [[ ! $4 =~ ^[0-9][0-9]$ ]]; then
    echo "Not a valid year."
    echo "Try executing again."
    exit
fi
if [ $4 -lt "17" ]; then
    echo "Formatting pre-2017 is a mess."
    echo "Try executing again."
fi

filedir=$1
prodname=$2
version=$3
anatype=${prodname:0:${#prodname}-4}
anayear=$4
anadir=${anatype}${anayear}

echo "Location of analysis data files: $filedir"
echo "Name of product: $prodname"
echo "Version: $version"
echo "Analysis type: $anatype"
echo "Analysis year: $anayear"
echo "Analysis dir:  $anadir"
echo ""

source /grid/fermiapp/products/nova/externals/setup
setup ups
setup upd

export PRODUCTS=$PRODUCTS:/nova/data/pidlibs/products
# GSD # Should this actually, finally be changed to /grid/fermiapp...?
prodpath=/nova/data/pidlibs/products
proddir=${prodpath}/${prodname}

echo "Product will be created in $proddir"
if [ -d "${proddir}" ]; then
    cd $proddir
else 
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
	exit
    fi
fi

#prodname_upper=`echo ${prodname} | tr '[:lower:]' '[:upper:]'`
prodname_upper=`echo ${prodname^^}`
anadir_upper=`echo ${anadir^^}`

mkdir -p ${proddir}/${version}/NULL/${anadir}
echo "Copying PID files from $filedir to ${proddir}/${version}/NULL/${anadir}/"
cp -rL $filedir/* ${proddir}/${version}/NULL/${anadir}/

if [ $? -ne 0 ]; then
    echo "Copying failed."
    echo "Cleaning up failed attempt..."
    rm -rf ${proddir}/${version}
    echo "Stop attempt to make ups product. Debug failures and retry."
    exit
fi


echo "Creating table file.." 
mkdir ${proddir}/${version}/NULL/ups
cd ${proddir}/${version}/NULL/ups
touch ${prodname}.table


if [ $anatype == "nus" ]; then
cat >${prodname}.table <<EOF
 FILE=TABLE
 PRODUCT=${prodname}
 VERSION=${version}

 FLAVOR=NULL
 QUALIFIERS = "" 
 
 ACTION=SETUP
   setupEnv()
   proddir()
   EnvSet(${prodname_upper}_VERSION, \${UPS_PROD_VERSION} )
   EnvSet(${prodname_upper}_${anadir_upper}_PRED, \${UPS_PROD_DIR}/${anadir}/pred )
   EnvSet(${prodname_upper}_${anadir_upper}_COVMX, \${UPS_PROD_DIR}/${anadir}/covmx )
   EnvSet(${prodname_upper}_${anadir_upper}_COSMIC, \${UPS_PROD_DIR}/${anadir}/cos )
   EnvSet(${prodname_upper}_${anadir_upper}_FAKEDATA, \${UPS_PROD_DIR}/${anadir}/fake_data )
   EnvSet(${prodname_upper}_${anadir_upper}_SYSTS, \${UPS_PROD_DIR}/${anadir}/systs )
   EnvSet(${prodname_upper}_${anadir_upper}_WEIGHTS, \${UPS_PROD_DIR}/${anadir}/weights )

EOF
fi

if [[ $anatype =~ ^(nue|numu)$ ]]; then
cat >${prodname}.table <<EOF
 FILE=TABLE
 PRODUCT=${prodname}
 VERSION=${version}

 FLAVOR=NULL
 QUALIFIERS = "" 
 
 ACTION=SETUP
   setupEnv()
   proddir()
   EnvSet(${prodname_upper}_VERSION, \${UPS_PROD_VERSION} )
   EnvSet(${prodname_upper}_${anadir_upper}_PRED, \${UPS_PROD_DIR}/${anadir}/pred )
   EnvSet(${prodname_upper}_${anadir_upper}_COSMIC, \${UPS_PROD_DIR}/${anadir}/cos )
   EnvSet(${prodname_upper}_${anadir_upper}_SYSTS, \${UPS_PROD_DIR}/${anadir}/systs )

EOF
fi


echo "Declaring product ${prodname} with version ${version} to UPS."

ups declare -f NULL -z ${prodpath} \
    -r ${prodpath}/${prodname}/${version}/NULL/ \
    -m ${prodname}.table \
    ${prodname} ${version}

retval=$?
test $retval -ne 0 && echo "ERROR : 'ups declare' returned non-zero - BAILING" && exit 1

echo "Adding product to UPD.."
cd ${proddir}/${version}/NULL/

upd addproduct ${prodname} ${version} 
retval=$?
test $retval -ne 0 && echo "ERROR : 'upd addproduct' returned non-zero - BAILING" && exit 1

echo "All done!"
