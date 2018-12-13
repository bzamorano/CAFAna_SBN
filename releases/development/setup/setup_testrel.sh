#!/bin/bash
#$1 is the FULL PATH to your test release base directory.

pushd $1
srt_setup -a
popd
echo '***'
echo private context is now $SRT_PRIVATE_CONTEXT
echo '***'
