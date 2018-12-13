#! /usr/bin/env python
# The basis for this UDP (User Datagram Protocol) portion of this code
# came from:  http://en.wikipedia.org/wiki/User_Datagram_Protocol  (2008-05-01)
# This script is a copy of the one used in MINOS, written by Robert Hatcher,
# but adapted to nova.

import os, sys, getopt
import socket
import getpass, platform

SERVER_ADDRESS = 'novabuild01.fnal.gov'
SERVER_PORT = 12345
DATAGRAM_VERSION = 'v0.1' #jpd -- introduce a version so that we know how to parse the output according to version

# Before DATAGRAM_VERSION was introduced
# message = shell + ' ' + user + ' ' + release + ' ' + kernel + ' ' + sl
# DATAGRAM_VERSION = 'v0.1'
# message = shell + ' ' + user + ' ' + release + ' ' + kernel + ' ' + sl + ' ' + DATAGRAM_VERSION + ' ' + srt_public_context + ' ' + products


def Usage():
    print "usage: datagram_client \"release\"" 
    print "  -a --addr=   server address [novasoftbuild01.fnal.gov]" 
    print "  -p --port=   port #  [12345]" 
    print "  --shutdown   request server shutdown" 

try:
    optpairs, args = \
          getopt.getopt(sys.argv[1:],\
                        'a:p:',\
                        ["addr=","port=","shutdown"])
except getopt.GetoptError:
    Usage()
    sys.exit(1)

envmap = os.environ
if "CVMFS_DISTRO_BASE" in envmap:
    if not os.path.isdir("/grid/fermiapp/"):
        sys.exit(0)

client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)

for io in range(len(optpairs)):
    kv = optpairs[io]
    opt1 = kv[0]
    arg1 = kv[1]
    for k in ('-a','--addr'):
        if (k == opt1):
            SERVER_ADDRESS = arg1
    for k in ('-p','--port'):
        if (k == opt1):
            SERVER_PORT = int(arg1)
    if (opt1 == '--shutdown'):
        args.append('SPECIAL_SHUTDOWN_MESSAGE')
    
user   = getpass.getuser()
kernel = platform.release()
if "SHELL" in os.environ.keys():
    shell  = os.environ["SHELL"]
else:
    shell = "Unknown"
#if SLF5 SLF6 this file exists
if os.path.exists('/etc/redhat-release'):
    fin    = open('/etc/redhat-release','r') 
    sl     = fin.readline().split(' ')[-2]
#else try parsing this which can be called on OS X
else:
    sl = os.popen('uname -s').read()
if os.environ.keys().count("X509_USER_PROXY") != 0:
    user = user + '/' + os.environ["X509_USER_PROXY"]

#jpd Add checking of the SRT_PUBLIC_CONTEXT and PRODUCTS environment variables
#    - only implemented in DATAGRAM_VERSION = v0.1

if os.environ.keys().count("SRT_PUBLIC_CONTEXT") != 0:
    srt_public_context = os.environ["SRT_PUBLIC_CONTEXT"]
else:
    srt_public_context = 'unknown'

if os.environ.keys().count("PRODUCTS") != 0:
    products = os.environ["PRODUCTS"]
else:
    products = 'unknown'

for release in args:

    if release == 'SPECIAL_SHUTDOWN_MESSAGE':
        message = 'SPECIAL_SHUTDOWN_MESSAGE'
        client.sendto(message,(SERVER_ADDRESS, SERVER_PORT))
    else:
        message = shell + ' ' + user + ' ' + release + ' ' + kernel + ' ' + sl + ' ' + DATAGRAM_VERSION
        message = message + ' ' + srt_public_context + ' ' + products
        client.sendto(message,(SERVER_ADDRESS, SERVER_PORT))

client.close()
