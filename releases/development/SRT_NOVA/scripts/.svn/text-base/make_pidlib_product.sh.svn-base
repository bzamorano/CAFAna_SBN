#!/bin/bash

# check that the user is logged in as novasoft
echo ""
user=`whoami`
if [ ${user} != "novasoft" ]; then
    echo "This script can only be run as novasoft."
    echo "Please log in as novasoft and try executing again."
    echo ""
    exit
fi

# check that the appropriate number fo arguments are specified.
if [ ${#@} != 3 ]; then
    echo "The scripts requires three arguments:"
    echo "1) The location of PID library files"
    echo "2) PID package name "
    echo "3) Version number of UPS product to be created"
    echo ""
    echo "Try executing again."
    exit
fi 

# check if the first argument is a valid path to pid lib files
if [ ! -d "$1" ]; then
    echo "$1 is an invalid path."
    echo "The first argument should be a valid path to PID files."
    echo ""
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
fi; 

filedir=$1
prodname=$2
version=$3

echo "Location of PID library files: $filedir"
echo "Name of product: $prodname"
echo "Version: $version"
echo ""

# check that setup_nova has been run
if [[ ${NOVASOFT_SETUP} != 1 ]]
    then
    #setup slf5/slf6 depending on the machine we are running on
    echo "setup_nova not run. Setting up nova soft"
    redhat=`cat /etc/redhat-release`
    if [[ "$redhat" =~ "release 5." ]]; 
	then
	source /grid/fermiapp/nova/novaart/novasvn/setup/setup_nova.sh -5 "/grid/fermiapp/nova/novaart/novasvn/" 
    elif [[ "$redhat" =~ "release 6." ]]; 
	then
	source /nova/app/home/novasoft/slf6/novasoft/setup/setup_nova.sh -6 "/nova/app/home/novasoft/slf6/novasoft/"
    else
	echo "ERROR: Trying to setup_nova, but the OS was not recognised: $redhat"
	exit
    fi
fi

source /nusoft/app/externals/setup
setup ups
setup upd

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

prodname_upper=`echo ${prodname} | tr '[:lower:]' '[:upper:]'`

mkdir -p ${proddir}/${version}/NULL/lib
echo "Copying PID files from $filedir to ${proddir}/${version}/NULL/lib/"
cp -rL $filedir/* ${proddir}/${version}/NULL/lib/

echo "Creating table file.." 
mkdir ${proddir}/${version}/NULL/ups
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
   EnvSet(${prodname_upper}_LIB_PATH, \${UPS_PROD_DIR}/lib )

EOF

echo "Declaring product ${prodname} with version ${version} to UPS."

ups declare -f NULL -z ${prodpath} \
    -r ${prodpath}/${prodname}/${version}/NULL/ \
    -m ${prodname}.table \
    ${prodname} ${version}

echo "Adding product to UPD.."
cd ${proddir}/${version}/NULL/

upd addproduct ${prodname} ${version} 

echo "All done!"
