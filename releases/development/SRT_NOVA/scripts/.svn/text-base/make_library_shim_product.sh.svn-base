#!/bin/bash

prodpath=/grid/fermiapp/products/nova/externals
# The following libraries are missing (or may be potentially) at some remote sites:
# $NOVAGRIDUTILS_DIR/bin/libraries.txt
#
# Just package up a copy from Fermilab and ship that to them.

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
if [ ${#@} != 1 ]; then
    echo "The scripts requires one argument:"
    echo "1) Version number of UPS product to be created"
    echo ""
    echo "Try executing again."
    exit
fi 

# check that the third argument is in a valid version format
if [[ ! $1 =~ ^v\.?[0-9][0-9]\.[0-9][0-9]$ ]] ; then 
    echo "Version number of type $1 are not allowed." 
    echo "Allowed version numbers should follow the vXX.XX scheme."
    echo ""
    echo "Try executing again."
    exit
fi

prodname=library_shim
version=$1

echo "Name of product: $prodname"
echo "Version: $version"
echo ""

# check that setup_nova has NOT been run
if [[ ${NOVASOFT_SETUP} == 1 ]]; then
    echo "setup_nova has been run. Try again, without setting up novasoft."
    exit -1
fi


source $prodpath/setup
setup ups
setup upd

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

prodname_upper=`echo ${prodname} | tr '[:lower:]' '[:upper:]'`

mkdir -p ${proddir}/${version}/NULL/lib/sl6

LIBFILE=${NOVAGRIDUTILS_DIR}/utils/libraries.txt

echo "Copying library files to ${proddir}/${version}/NULL/lib/"
# Copy libraries in long list to library_shim lib directory
# Libraries are a bunch of symlinks to an underlying library.
# Copying libs /usr/lib64 and/or lib64/ gets the underlying file
# that gets linked to

# Presumably the current VM is SL6
# NOT supporting SL5 anymore

for libName in $(cat ${LIBFILE})
do
    # Have to grep for /lib64/ to only pick up libraries in /lib64/ or
    # /usr/lib64/ directories.
    # Also want to ignore .hmac/.py/.pyc/.pyo extensions
    lib_paths=`locate ${libName} | grep /lib64/ | grep -v ".hmac$\|.py$\|.pyc$\|.pyo$"`
    for libPath in $lib_paths
    do
	# Possible for library name resident on machine to have extension
	# beyond .so we're searching for and that's what we need to copy
	if [ -n "${libPath}" ]; then
	    cp ${libPath} ${proddir}/${version}/NULL/lib/sl6/ 2> /dev/null
	fi
    done
done


# Otherwise we get errors. 
# But is this really such a good idea?
chmod -R g+w ${proddir}

echo SL6 libraries copied from nodes with these versions. Please check
lsb_release -a | grep Description

echo "Creating table file.." 
mkdir -p ${proddir}/${version}/NULL/ups
cd ${proddir}/${version}/NULL/ups
touch ${prodname}.table

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
   EnvSet(${prodname_upper}_SL6_LIB_PATH, \${UPS_PROD_DIR}/lib/sl6 )

EOF

echo "Declaring product ${prodname} with version ${version} to UPS."

ups declare -f NULL -z ${prodpath} \
    -r ${prodpath}/${prodname}/${version}/NULL \
    -m ${proddir}/${version}/NULL/ups/${prodname}.table \
    ${prodname} ${version}

retval=$?
test $retval -ne 0 && echo "ERROR : 'ups declare' returned non-zero - BAILING" && exit 1

echo "Adding product to UPD.."
cd ${proddir}/${version}/NULL/

upd addproduct ${prodname} ${version} 
retval=$?
test $retval -ne 0 && echo "ERROR : 'upd addproduct' returned non-zero - BAILING" && exit 1

echo "All done!"
