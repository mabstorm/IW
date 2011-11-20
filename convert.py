#!/usr/bin/python


# EUC-JP 2 UTF-8

import os
import sys
import re



"""
   Reads the information to/from from the codepage file given and populates
   the global ConversionTable so we can use it to translate the characters
   later
"""
def PopulateConversionTable(fn):
    global ConversionTable;
    ConversionTable = {};
    fp = open(fn, "r");
    for l in fp:
        line = str(l);
        end = line.find('#')
        if (end >= 0):
            line = line[:end]

        x = line.split("\t")
        if (len(x) >= 2):
            From = int(x[0],16);
            To = x[1].strip();
            if (len(To) == 0):
                To = 0
            else:
                To = int(To,16)
            ConversionTable[From] = To;

    fp.close()

"""
  Takes a given NUMBER (not byte(s)) and returns a bytearray
  encoded with UTF8.
  The number must be the number part of the format U+0000.
  Checkout wikipedia for more info: http://en.wikipedia.org/wiki/UTF-8
"""
def EncodeUTF8(num):
    # return the converted byte array
    ret = []
    if (num < 128):
        ret.append(num)
    elif (num < 2048):
        # 0x1f / 00011111
        # 0x3f / 00111111
        part2 = 0x80 | (num & 0x3f);
        aux = num >> 6;
        part1 = 0xc0 | (aux & 0x1f);
        ret.append(part1);
        ret.append(part2);
    elif (num < 65536):
        # 0x0f / 00001111
        # 0x3f / 00111111
        # 0x3f / 00111111
        part3 = 0x80 | (num & 0x3f);
        aux = num >> 6;
        part2 = 0x80 | (aux & 0x3f);
        aux = aux >> 6;
        part1 = 0xe0 | (aux & 0x0f);
        ret.append(part1);
        ret.append(part2);
        ret.append(part3);
    elif(num < 1114112):
        # 0x07 / 00000111
        # 0x3f / 00111111
        # 0x3f / 00111111
        # 0x3f / 00111111
        part4 = 0x80 | (num & 0x3f);
        aux = num >> 6;
        part3 = 0x80 | (aux & 0x3f);
        aux = aux >> 6;
        part2 = 0x80 | (aux & 0x3f);
        aux = aux >> 6;
        part1 = 0xf0 | (aux & 0x0f);
        ret.append(part1);
        ret.append(part2);
        ret.append(part3);
        ret.append(part4);
        
    return(bytes(ret))

CodePage = 936
IncludePreamble = 1 # When this is not zero, it prepends the UTF-8 BOM 0xEFBBBF to the output file.

# Only mess with these if you know what you're doing
ReplacementChar = 0xfffd

# The conversion table from UTF to UNICODE
global ConversionTable;
ConversionTable = {}
PopulateConversionTable("cp%d.txt" % CodePage);
print("Done loading conversion table.")

for arg in sys.argv:
  if (re.search("-stripped.txt",arg)==None):
    continue
  print arg

# Setup: Files and parameters
  InputFile = arg
  OutputFile = arg + "-utf8.txt"


# Start converting.



  fp_in = open(InputFile, "rb")
  fp_out = open(OutputFile, "wb")

  print("Starting conversion of file %s" % InputFile)

  fp_in.seek(0, os.SEEK_END)
  FileSize = fp_in.tell()
  fp_in.seek(0, os.SEEK_SET)
  PercStep = int(FileSize / 20)

  ReplacementBytes = EncodeUTF8(ReplacementChar)

# Write preamble?
  if (IncludePreamble):
      fp_out.write(bytes([0xef, 0xbb, 0xbf]));

# We read byte per byte
  data = fp_in.read(1)
  pos = 0
  while(len(data) > 0):
      n = data[0]

      # Some verbose info on our conversion
      Pos = fp_in.tell()
      if (Pos % PercStep == 0):
          print("Progress: %.2f%%" % (100 * Pos / FileSize)) 
      
      # We always have a match for one-byte EUC.
      Conv = ConversionTable[n];
      
      if (Conv == n):
          # No conversion is needed.
          fp_out.write(data)
      elif (Conv > 0):
          # We need to convert and we use only one byte on the original file.
          Out = EncodeUTF8(Conv)
          fp_out.write(Out)
      else:
          # Need to get another byte, so we can figure out what character
          # we are using, pass it trough the conversion table and Encode the result.
          aux = n << 8; # Same thing of n*256, only faster.
          dt = fp_in.read(1)
          n = dt[0]
          aux = aux + n

          if (aux in ConversionTable):
              Conv = ConversionTable[aux]
              Out = EncodeUTF8(Conv)
              fp_out.write(Out)
          else:
              # oooops. This encoded key was not found!
              fp_out.write(ReplacementBytes);
              fp_out.write(bytes("0x%x" % data[0], "UTF-8"));
              fp_out.write(ReplacementBytes);
              #print("Invalid character sequence: 0x%x%x" % (data[0], dt[0])) #Debug Purposes
              fp_in.seek(-1, os.SEEK_CUR) # We didnt use the last byte. roll back.
      data = fp_in.read(1)

  fp_out.close()
  fp_in.close()


