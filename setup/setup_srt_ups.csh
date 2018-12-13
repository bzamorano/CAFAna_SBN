#!/bin/csh -vx
# reads in a file consisting of arguments to UPS setup command

# P. Shanahan 10/7/09


# setup_srt_ups filename [-u]
# -u option causes unsetup for each product

setenv UPS_OPTIONS -B

if ( $# == 0 ) then
	echo "usage: setup_srt_ups filename [-u]"
	echo " "
	echo "filename contains arguments for ups setup commands."
	echo "-u causes unsetup for each product prior to setup."
	exit
endif

set version_file=$1

if ( ! -f $version_file ) then
	echo "UPS products version file $version_file not found!"
	exit 1
endif

if ( $# == 2 ) then
	if ( "$2" = "-u" ); then
		set do_unsets 
	endif
endif

set nline=`grep . -c $version_file`
set iline=1

while ( $iline <= $nline )

    set line=`head -$iline $version_file | tail -1`

    if ( $?do_unsets ) then
	set prodname=`echo $line | sed -e "s/ .*//g" `
	unsetup $prodname
	unset prodname
    endif
    setup -B $line
    @ iline++
end

unset do_unsets
