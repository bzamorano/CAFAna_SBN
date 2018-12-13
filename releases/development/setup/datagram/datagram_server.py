#! /usr/bin/env python
# The basis for this UDP (User Datagram Protocol) portion of this code
# came from:  http://en.wikipedia.org/wiki/User_Datagram_Protocol  (2008-05-01)
# This script is a copy of the one used in MINOS, written by Robert Hatcher,
# adapted for NOvA.

import socket, time, sys

PORT = 12345
BUFLEN = 512

server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
server.bind(('', PORT))

docontinue = True
while docontinue:
    (message, address) = server.recvfrom(BUFLEN)
    rtime = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime())
    rmach = socket.gethostbyaddr(address[0])[0]
    if ( message == 'SPECIAL_SHUTDOWN_MESSAGE'):
        sys.stdout.write(rtime)
        sys.stdout.write(' Received SHUTDOWN message from %s\n'%rmach)
        docontinue = False
    else:
        sys.stdout.write(rtime)
        sys.stdout.write(' %s : \"%s\"\n'%(rmach, message))
    sys.stdout.flush()

server.close()
