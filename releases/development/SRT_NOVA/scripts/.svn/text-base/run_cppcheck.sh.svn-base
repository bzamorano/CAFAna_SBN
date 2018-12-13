#!/bin/bash

# Runs nightly from a cronjob on novagpvm09 as the novasoft user.

# Prevent more than one concurrent instance
echo Checking lock
exec 200>/tmp/cppcheck.lock
flock -n 200 || exit 2
echo Lock OK, continue

source /grid/fermiapp/nova/novaart/novasvn/setup/setup_nova.sh || exit 1

# v1_63 is broken somehow
setup cppcheck v1_59 || exit 1

OUTFILE=/nusoft/app/web/htdoc/nova/cppcheck/index.html

exec > $OUTFILE 2>&1

echo '<html><head><title>novasoft cppcheck</title></head><body>'
echo '<h1>novasoft cppcheck</h1>'
echo Last updated `date`

time for PKG in `grep HEAD $SRT_PUBLIC_CONTEXT/setup/packages-development | sed 's/ .*//'`
do
    echo '<h2>'$PKG'</h2>'
    echo '<pre>'
    # Disable false positives and very verbose messages. Easiest way to get
    # these IDs is from 'cppcheck --errorlist'. Some of the unusedFunction
    # messages are probably genuine. Should find a way to distinguish them from
    # the meaningless ones from modules and services.
    cppcheck `find $SRT_PUBLIC_CONTEXT/$PKG/ -name *.cpp -or -name *.cxx -or -name *.cc -or -name *.C -not -name *_dict.cc`\
        --enable=style \
        --suppress=unusedFunction \
        --suppress=uninitMemberVar \
        --suppress=invalidscanf \
        --suppress=cstyleCast \
        --suppress=constStatement \
        -q -v \
        -rp=$SRT_PUBLIC_CONTEXT/ \
        -I $SRT_PUBLIC_CONTEXT/ \
        2>&1 | sed 's/</\&lt;/' | sed 's/>/\&gt;/'
    echo '</pre>'
done

echo '</body></html>'

# These are (most of) the include paths you'd need to satisfy cppcheck. But
# they also slow the check down a huge amount, and introduce a lot of "too many
# #ifdef configurations" errors. Let's leave them out and have cppcheck focus
# on novasoft rather than on checking our dependencies.

        # -I /usr/include/ \
        # -I $GCC_FQ_DIR/include/c++/`echo $GCC_VERSION | sed s/v// | sed s/_/./g`/ \
        # -I $ROOT_INC \
        # -I $ART_INC \
        # -I $CPP0X_INC \
        # -I $CETLIB_INC \
        # -I $BOOST_INC \
        # -I $FHICLCPP_INC \
        # -I $MESSAGEFACILITY_INC \
        # -I $NUTOOLS_INC \
        # -I $NOVADAQ_INC \
        # -I $NOVADDT_INC \
        # -I $GENIE_INC/GENIE/ \
