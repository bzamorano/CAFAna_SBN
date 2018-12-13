#!/bin/bash

prodpath=/grid/fermiapp/products/nova/externals

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
if [ ${#@} != 2 ]; then
    echo "The scripts requires two arguments:"
    echo "1) The location of the calibration CSV files (/nova/ana/calibration/csvs/?)"
    echo "2) Version number of UPS product to be created"
    echo ""
    echo "Try executing again."
    exit
fi 

# check if the first argument is a valid path to calibration csv files
if [ ! -d "$1" ]; then
    echo "$1 is an invalid path."
    echo "The first argument should be a valid path to CSV files."
    echo ""
    echo "Try executing again."
    exit
fi

# check that the third argument is in a valid version format
if [[ ! $2 =~ ^v\.?[0-9][0-9]\.[0-9][0-9]$ ]] ; then 
    echo "Version number of type $2 are not allowed." 
    echo "Allowed version numbers should follow the vXX.XX scheme."
    echo ""
    echo "Try executing again."
    exit
fi

filedir=$1
prodname=calibcsvs
version=$2

echo "Location of calibration CSV files: $filedir"
echo "Name of product: $prodname"
echo "Version: $version"
echo ""

# check that setup_nova has NOT been run
if [[ ${NOVASOFT_SETUP} == 1 ]]; then
    echo "setup_nova has been run. Try again, without setting up novasoft"
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

mkdir -p ${proddir}/${version}/NULL/csv/
echo "Copying CSV files from $filedir to ${proddir}/${version}/NULL/csv/"
cp -rL $filedir/* ${proddir}/${version}/NULL/csv/ 

#Make sure the permissions aren't crazy 
find ${proddir}/${version}/NULL/csv/ -type d -exec chmod 755 {} \;
find ${proddir}/${version}/NULL/csv/ -type f -exec chmod 644 {} \;

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
   EnvSet(${prodname_upper}_CSV_PATH, \${UPS_PROD_DIR}/csv )

EOF

echo "Declaring product ${prodname} with version ${version} to UPS."

ups declare -f NULL -z ${prodpath} \
    -r ${prodpath}/${prodname}/${version}/NULL/ \
    -m ${prodname}.table \
    ${prodname} ${version}

retval=$?
test $retval -ne 0 && echo "ERROR : 'ups declare' returned non-zero - BAILING" && exit 1


echo "Adding product to UPD.."
tar_file=${proddir}/temp/${prodname}.${version}.upd.addproduct.tar.gz
echo "Making a tarball to avoid /tmp file size limitations: ${tar_file}"
mkdir -p ${proddir}/temp
cd ${proddir}/${version}/NULL/
tar -czf ${tar_file} .

upd addproduct ${prodname} ${version} -T ${tar_file} -f NULL
retval=$?
test $retval -ne 0 && echo "ERROR : 'upd addproduct' returned non-zero - BAILING" && exit 1
echo "Removing the tarball and directory: ${tar_file}"
rm -ri ${proddir}/temp

echo "All done!"
