#!/usr/local/bin/python3.7

import os,re
import pymongo as pm

logPath=os.path.join('/var','log/')

logFiles=['dmesg', 'syslog']

syslogFile=logPath+logFiles[1]

print(syslogFile)



