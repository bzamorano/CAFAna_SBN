#!/bin/bash

CCACHE_VERSION=3.3.3
UPS_VERSION=v03.03.03 # should match above apart from formatting

# check that the user is logged in as novasoft
echo ""
user=`whoami`
if [ ${user} != "novasoft" ]; then
    echo "This script can only be run as novasoft."
    echo "Please log in as novasoft and try executing again."
    echo ""
    exit
fi


if [[ ${NOVASOFT_SETUP} == 1 ]]
then
    # Build doesn't work after setupnova for some reason
    echo You must have '*not*' setup novasoft for this to work.
    echo Please try again in a new session
    exit 1
fi


cd `mktemp -d` || exit 1
WORKDIR=`pwd`
echo Working in $WORKDIR
wget https://www.samba.org/ftp/ccache/ccache-${CCACHE_VERSION}.tar.bz2 || exit 1
tar -xjf ccache-${CCACHE_VERSION}.tar.bz2 || exit 1
mkdir build
cd ccache-${CCACHE_VERSION} || exit 1
./configure --prefix=$WORKDIR/build/ || exit 1
make || exit 1
make install || exit 1

cd $WORKDIR/build/bin/
ln -s ccache gcc
ln -s ccache g++
ln -s ccache cc
ln -s ccache c++

prodname=ccache
version=$UPS_VERSION

# check that the third argument is in a valid version format
if [[ ! $version =~ ^v\.?[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9]$ ]] ; then 
    echo "Version number of type $version are not allowed." 
    echo "Allowed version numbers should follow the vXX.XX.XX scheme."
    echo ""
    echo "Try executing again."
    exit
fi

source /grid/fermiapp/products/nova/externals/setup
setup ups
setup upd

prodpath=$EXTERNALS
proddir=${prodpath}/${prodname}

echo
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

FQ=`ups flavor -4`

prodname_upper=`echo ${prodname} | tr '[:lower:]' '[:upper:]'`

mkdir -p ${proddir}/${version}/${FQ}/bin || exit 1
echo "Copying binary to ${proddir}/${version}/${FQ}/bin/"
cp -a $WORKDIR/build/bin/* ${proddir}/${version}/${FQ}/bin/ || exit 1
mkdir -p ${proddir}/${version}/NULL/src || exit 1
echo "Copying source to ${proddir}/${version}/NULL/src/"
cp -rL $WORKDIR/ccache-${CCACHE_VERSION} ${proddir}/${version}/NULL/src/ || exit 1

echo "Creating table file.." 
mkdir -p ${proddir}/${version}/${FQ}/ups
cd ${proddir}/${version}/${FQ}/ups
touch ${prodname}.table

cat >${prodname}.table <<EOF
 FILE=TABLE
 PRODUCT=${prodname}
 VERSION=${version}

 FLAVOR=${FQ}
 QUALIFIERS = "" 
 
 ACTION=SETUP
   setupEnv()
   EnvSet(${prodname_upper}_VERSION, \${UPS_PROD_VERSION} )
   EnvSet(${prodname_upper}_BIN_DIR, \${UPS_PROD_DIR}bin/ )

EOF

echo "Declaring product ${prodname} with version ${version} to UPS."

ups declare -f ${FQ} -z ${prodpath} \
    -r ${prodpath}/${prodname}/${version}/${FQ}/ \
    -m ${prodname}.table \
    ${prodname} ${version}

retval=$?
test $retval -ne 0 && echo "ERROR : 'ups declare' returned non-zero - BAILING" && exit 1

echo "Adding product to UPD.."
cd ${proddir}/${version}/${FQ}/

upd addproduct ${prodname} ${version} 
retval=$?
test $retval -ne 0 && echo "ERROR : 'upd addproduct' returned non-zero - BAILING" && exit 1
# ups declare -c ${prodname} ${version}

echo "All done!"
