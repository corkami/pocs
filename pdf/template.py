# dumb PDF template post processor:
# fills /Length, xref, startxref pointer, /Size from basic PDF templates
# doesn't support non-contiguous objects

# Ange Albertini

import sys

# usage: template.py <template text> <output pdf>
d = open(sys.argv[1], "rb").read()
out = open(sys.argv[2], "wb")

XREF_COUNT = "0 %i"

XREF_FAKE = "0000000000 65535 f"
XREF_DECL =      "%010i 00000 n"

# some kind of auto-detect of line endings
if d[:16].find("\r\n") > -1:
  RETCHAR = "\r\n"
else:
  # if line endings are single character, then a trailing space must be added in each XREF entries
  XREF_FAKE = XREF_FAKE + " "
  XREF_DECL = XREF_DECL + " "

  if d[:16].find("\r") > -1:
    RETCHAR = "\r"
  else:
    RETCHAR = "\n"

print "auto-detected line endings: %s" % `RETCHAR`
STREAM_START = RETCHAR + "stream" + RETCHAR
STREAM_END = RETCHAR + "endstream"

# standard declaration: add your own
OBJ_DECL = RETCHAR + "%i 0 obj" + RETCHAR

def postproc(d, XREF=True):

  # fill stream lengths
  while d.find("__LENGTH") > -1:
    off = d.find("__LENGTH")
    length = d.find(STREAM_END, off) - d.find(STREAM_START, off) - len(STREAM_START)
    d = d.replace("__LENGTH", "%i" % (length), 1)

  if XREF:
    # fill xref table
    xrefs = [XREF_FAKE]

    # looking for object positions
    i = 1
    while d.find(OBJ_DECL % i) > -1:
      off = d.find(OBJ_DECL % i) + len(RETCHAR)
      xrefs.append(XREF_DECL % (off))
      i += 1

    nb_obj = len(xrefs)
    if nb_obj == 0:
      print "ERROR - no object found - maybe update the object string declaration?"
      sys.exit()

    print "%i objects founds" % nb_obj

    d = d.replace("__XREF", RETCHAR.join([XREF_COUNT % nb_obj] + xrefs))

    # fill xref pointer
    d = d.replace("__STARTXREF", "%i" % (d.find(RETCHAR + "xref" + RETCHAR) + len(RETCHAR) ))

    # fill trailer size - not strictly required but its absence can trigger warnings
    d = d.replace("__SIZE", "%i" % nb_obj)

  return d

out.write(postproc(d))
