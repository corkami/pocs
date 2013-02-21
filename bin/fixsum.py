import pefile
import sys

fn = sys.argv[1]
pe = pefile.PE(fn)
if pe.OPTIONAL_HEADER.CheckSum == 59788: # pefile checksum can't work on 97 bits files, silently expands data to full optionalheader :(
    sys.exit()
pe.OPTIONAL_HEADER.CheckSum = pe.generate_checksum()
pe.write(fn)
