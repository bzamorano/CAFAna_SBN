#! /usr/bin/env bash
# This script runs the datagram server that receives UDP packets from 
# clients.  The data sent by the client is basically a string and the
# server simply writes it down into the log file.
#
# in FNAL crontab
#   # was:  sg e875 " <script> "; now just <script>
#   # sg = "set group" because minsoft account was "mysql" rather than "e875" 
#   0 0 * * * /grid/fermiapp/minos/minossoft/setup/datagram/run_datagram.sh
# this restarts the server daily to keep the logs easily searched and
# manageable sized.

# we need to know where this was installed so we can run it
export SRT_DIST=/grid/fermiapp/nova/novaart/novasvn
cd ${SRT_DIST}/setup/datagram


echo "in `pwd`/run_datagram.sh" 
echo "SRT_DIST=${SRT_DIST}" 
#
./datagram_client.py --shutdown "run_datagram.sh requests shutdown" 
#
logtag=`date +%Y%m%d_%H%M%S`
export OUTFILE=/nova/app/home/novasoft/datagram_logs/zzz_${logtag}.log
echo restarted server ${logtag}
echo log output to $OUTFILE
touch                  $OUTFILE
chmod g+w              $OUTFILE
./datagram_server.py > $OUTFILE 2>&1
#
endtime=`date +%Y%m%d_%H%M%S`
echo completed at ${endtime}
# end-of-script
