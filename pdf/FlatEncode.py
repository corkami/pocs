import zlib

with open("structure-filters.pdf", "rt") as f:
    r = f.read()

i = r.find("stream") 
if i == -1:
    sys.exit()
i += len("stream") + 1
subs = r[i:]
j = subs.find("endstream")
if j == -1:
    sys.exit()

plain = subs[:j - 1]
comp = zlib.compress(plain)

# let's chomp a few bytes to show that the start of the decompressed buffer is executed correctly
CHOMP = 4
print "removed %i bytes from the decompressed stream" % CHOMP
comp = comp[:-CHOMP] if CHOMP > 0 else comp

try:
    zlib.decompress(comp)
except zlib.error as s:
    print s
    print " => the chomped stream is indeed incorrect"
r = r.replace(plain, comp)
r = r.replace("/Filter ()", "/Filter /FlateDecode")
with open("structure-filters-flate.pdf", "wb") as f:
    f.write(r)
