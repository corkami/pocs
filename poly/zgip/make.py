#!/usr/bin/env python3

# prepare the data for the zgip source from any file

# Ange Albertini 2022

import argparse
import binascii
import gzip
import sys


def bytes2db(d):
	if not d:
		return []
	result = []
	i = 0
	while i < len(d):
		result .append("db %s" % (", ".join("0x%02X" % c for c in d[i:i+16])))
		i += 16
	return result


parser = argparse.ArgumentParser(description="Generates `external.inc` from any given file.")

parser.add_argument('file', help="Input file.")
parser.add_argument('-s', '--skip', help="Bytes to skip in the Zip content", type=int, default=0)

args = parser.parse_args()

fn = args.file
skip = args.skip
assert skip <= 0xffff

with open(fn, "rb") as f:
	data = f.read()

DATA_ZCRC32 = binascii.crc32(data)
DATA_GZCRC32 = binascii.crc32(data[skip:])
DATA_USIZE = len(data)

prefdata = b""
if skip > 0:
	prefix = data[:skip]
	prefdata = b"".join([
		b"\x00", # stored block
		len(prefix).to_bytes(2, byteorder="little"),  # length
		(len(prefix) ^ 0xffff).to_bytes(2, byteorder="little"), # !length
		prefix,
		])

cdata = gzip.compress(data[skip:])
cdata = cdata[10:-8] # skipping header, removing CRC32 and size32

adata = "\n".join(bytes2db(prefdata) + bytes2db(cdata))

DATA_GSIZE = DATA_USIZE
if skip > 0:
	DATA_GSIZE -= skip
	skip += 5

with open("external.inc", "w") as f:
	f.write(f"""; Don't modify by hand, regenerate with make.py

%macro EXT_DATA 0
{adata}
%endmacro

EXT_ZCRC32 equ {DATA_ZCRC32:#x}
EXT_GZCRC32 equ {DATA_GZCRC32:#x}
EXT_USIZE equ {DATA_USIZE}
EXT_GSIZE equ {DATA_GSIZE}
SKIP equ {skip}
""")

print("Success!")

# Now generate it with `yasm -o blah.zip zgip.asm`
