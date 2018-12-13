#!/bin/bash

# check that the user is logged in as novasoft
echo ""
user=`whoami`

prodpath=/grid/fermiapp/products/nova/externals


if [ ${user} != "novasoft" ]; then
   echo "This script can only be run as novasoft."
   echo "Please log in as novasoft and try executing again."
   echo ""
   exit
fi

# check that setup_nova has NOT been run
if [[ ${NOVASOFT_SETUP} == 1 ]]; then
    echo "setup_nova has been run. Try again, without setting up novasoft"
    exit -1
fi


# Go somewhere private
cd `mktemp -d`

git clone https://github.com/gperftools/gperftools.git || exit 1
cd gperftools || exit 1
git checkout at8_0-release || exit 1
./autogen.sh || exit 1
mkdir build_output || exit 1
# don't use libunwind that has trouble on 64bit. Instead rely on frame pointers
./configure --enable-frame-pointers --prefix=`pwd`/build_output || exit 1
make || exit 1
make install || exit 1



filedir=build_output/
prodname=gperftools
version=v08.00

source $prodpath/setup
setup ups
setup upd

FQ=`ups flavor -4`

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

mkdir -p ${proddir}/${version}/${FQ}/
echo "Copying files files from $filedir to ${proddir}/${version}/${FQ}/"
cp -rL $filedir/* ${proddir}/${version}/${FQ}/

#Make sure the permissions aren't crazy 
find ${proddir}/${version}/${FQ}/lib/ -type d -exec chmod 755 {} \;
find ${proddir}/${version}/${FQ}/lib/ -type f -exec chmod 644 {} \;

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
   proddir()
   EnvSet(${prodname_upper}_VERSION, \${UPS_PROD_VERSION} )
   EnvSet(${prodname_upper}_LIB_PATH, \${UPS_PROD_DIR}/lib )
   EnvSet(${prodname_upper}_BIN_PATH, \${UPS_PROD_DIR}/bin )

EOF

echo "Declaring product ${prodname} with version ${version} to UPS."

ups declare -f ${FQ} -z ${prodpath} \
    -r ${prodpath}/${prodname}/${version}/${FQ}/ \
    -m ${prodname}.table \
    ${prodname} ${version}

retval=$?
test $retval -ne 0 && echo "ERROR : 'ups declare' returned non-zero - BAILING" && exit 1


echo "Adding product to UPD.."
tar_file=${proddir}/temp/${prodname}.${version}.upd.addproduct.tar.gz
echo "Making a tarball to avoid /tmp file size limitations: ${tar_file}"
mkdir -p ${proddir}/temp
cd ${proddir}/${version}/${FQ}/
tar -czf ${tar_file} .

echo About to run \'upd addproduct\'. This is likely to fail due to some kind
echo of size limit on the remote end. The only suggested solution is to split
echo the library up until smaller pieces. Not a disaster, all this step
echo accomplishes is allowing people to \'ups install\' the product. They can
echo scp it instead.

upd addproduct ${prodname} ${version} -T ${tar_file} -f ${FQ}
retval=$?
test $retval -ne 0 && echo "ERROR : 'upd addproduct' returned non-zero" # && exit 1
echo "Removing the tarball and directory: ${tar_file}"
rm -ri ${proddir}/temp

echo "All done!"
