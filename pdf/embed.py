#!/usr/bin/env python

# a script to embed any data to any PDF

# Ange Albertini 2019

# uses mutool from https://mupdf.com/index.html

import os
import sys

MUTOOL = "mutool"

def EnclosedString(d, starts, ends):
  off = d.find(starts) + len(starts)
  return d[off:d.find(ends, off)]

def getCount(d):
  s = EnclosedString(d, "/Count ", "/")
  count = int(s)
  return count

def procreate(l): # :p
  return " 0 R ".join(l) + " 0 R"

if len(sys.argv) < 4:
  print("PDF payload embedder")
  print("Usage: pdf.py <source.pdf> <payload.bin> <final.pdf>")
  sys.exit()

os.system(MUTOOL + ' merge -o first.pdf %s' % sys.argv[1])

with open(sys.argv[2], "rb") as f:
  payloadbin = f.read()

with open("payload.pdf", "wb") as f:
  f.write("""%%PDF-1.3
1 0 obj <</Type/Catalog/Pages 2 0 R>>endobj
2 0 obj <</Kids[3 0 R]/Type/Pages>>endobj
3 0 obj <</Type/Page/Contents 4 0 R>>endobj
4 0 obj <<>>
stream
%(payloadbin)s
endstream
endobj

trailer<</Size 5/Root 1 0 R>>""" % locals())

with open("first.pdf", "rb") as f:
  d1 = f.read()

os.system(MUTOOL + ' merge -o merged.pdf first.pdf payload.pdf ')

with open("merged.pdf", "rb") as f:
  dm = f.read()

# get kids array string
kids = EnclosedString(dm, "/Kids[", "]")[:-4].split(" 0 R ")

pages = kids[:-1]

COUNT = getCount(d1)
KIDS = procreate(pages[:getCount(d1)])
# the stream object should be just *before* the page object
# (that's how mutool does it)
LASTPAGE = "%i" % (int(kids[-1]) - 1)

contents = """%%PDF-1.4

1 0 obj
<<
  /Type /Catalog
  /Pages 2 0 R
>>
endobj

2 0 obj
<<
  /Type/Pages
  /Count %(COUNT)i
  /Kids[%(KIDS)s]
  /Payload %(LASTPAGE)s 0 R
>>
endobj

""" % locals() + dm[dm.find("3 0 obj"):]

with open("hacked.pdf", "wb") as f:
  f.write(contents)

# let's adjust offsets - -g to get rid of orphan objects by garbage collecting
os.system(MUTOOL + ' clean -gggg  hacked.pdf %s' % sys.argv[3])

for fn in ['first', 'payload', 'merged', 'hacked']:
  os.remove("%s.pdf" % fn)
