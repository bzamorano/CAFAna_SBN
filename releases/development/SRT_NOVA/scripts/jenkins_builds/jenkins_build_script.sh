#!/usr/bin/env bash

cd $WORKSPACE

                      
os_release=`cat /etc/redhat-release`

source ${WORKSPACE}/setup/setup_nova.sh -r "${RELEASE}" -b "${BUILDTYPE}" -5 "${WORKSPACE}" -6 "${WORKSPACE}" -e "/grid/fermiapp/products/common/db:/grid/fermiapp/products/nova/externals"

return_code=$?
if [ $return_code != 0 ];then
    echo "ERROR: setup_nova.sh failed. Exiting"
    exit 1
fi

# # This location is visible from Jenkins machines. Don't want to share a cache
# # with regular NOvA users anyway. Building the base release and building in a
# # test release don't share cache hits. But, it's not writeable from
# # Jenkins. Leave ccache disabled for now.
# export CCACHE_DIR=/grid/fermiapp/nova/ccache_jenkins_cache/

# # Rewrite paths below this location to relative paths. This helps the sharing
# # of caches in different directories. Everything we build should be below here.
# export CCACHE_BASEDIR=${SRT_PUBLIC_CONTEXT}/

# # Actually activate ccache
# export PATH=$CCACHE_BIN_DIR:$PATH


echo "INFO: \$BUILD \"$BUILD\""
echo "INFO: \$BUILDTYPE \"$BUILDTYPE\""

BUILD_COMMAND="${SRT_PUBLIC_CONTEXT}/SRT_NOVA/scripts/novasoft_build -rel ${RELEASE} -failonerror"
#BUILD_COMMAND="${SRT_PUBLIC_CONTEXT}/SRT_NOVA/scripts/novasoft_build -rel ${RELEASE}"

#Handle build type
if [ "$BUILDTYPE" == "debug" ];then
    BUILD_COMMAND="$BUILD_COMMAND -debug"
elif [ "$BUILDTYPE" == "maxopt" ];then
    BUILD_COMMAND="$BUILD_COMMAND"
else
    echo "ERROR: Failed to interpret the BUILDTYPE (which should be debug or maxopt). See the configuration of this project in the section \"User Defined Axis\""
    return_code=1
fi
#Handle if it should be parallelised
if [ "$MTHREADED" == "TRUE" ];then
    BUILD_COMMAND="$BUILD_COMMAND -p 17"
fi
if [ $return_code == 0 ];then
    echo "BUILD_COMMAND $BUILD_COMMAND"
    eval "$BUILD_COMMAND"
    return_code=$?
fi

echo ""
echo "Build return code \"$return_code\""
echo ""

if [ $return_code != 0 ];then
    exit 1
fi

echo ""
echo "Creating file ${SRT_PUBLIC_CONTEXT}/build_date with content \"`date +'%F %T'`\""
echo ""

echo `date +'%F %T'` > ${SRT_PUBLIC_CONTEXT}/build_date

#Create tar file of the build
cd ${WORKSPACE}/releases/

#Delete unneeded files
rm -rf ${WORKSPACE}/releases/${RELEASE}/lib/*/*.o
rm -rf ${WORKSPACE}/releases/${RELEASE}/tmp/*


TAR_FILE=novabuild.${RELEASE}.${OS}.${BUILDTYPE}.tar.bz2
tar cjf ${TAR_FILE} ${RELEASE}
mv ${TAR_FILE} ${WORKSPACE}/buildout/

#Delete the old build
rm -rf ${WORKSPACE}/releases/${RELEASE}
