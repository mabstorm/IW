#!/usr/bin/python


import os
import sys
import re
import linecache


for arg in sys.argv:
  if (arg==sys.argv[0]):
    continue
  print arg
  if (os.path.exists(arg+"-utf8.txt")):
    continue
  fp_out = open(arg+"-utf8.txt","wb")
  
  i=1
  myline = linecache.getline(arg,i)
  while (myline!=''):
    try:
      fp_out.write(myline.decode('EUC-JP').encode('UTF-8'))
      i+=1
      myline = linecache.getline(arg,i)
    except:
      i+=1
      myline = linecache.getline(arg,i)
    else:
      i+=1
      myline = linecache.getline(arg,i)









