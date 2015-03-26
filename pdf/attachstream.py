# extract stream object to be attached to a file, to get Adobe decompression

# takes a "PDF with attached file" template
# an argument, and an object number
# inserts the extracted stream object into the template

# Ange Albertini, BSD Licence, 2011

#TODO: more robust tags parsing

import sys
with open("structure-attached.pdf", "rt") as f:
	template = f.read()

if len(sys.argv) == 1:
	print "attachstream.py <filename.pdf> <object number>"
	sys.exit()
with open(sys.argv[1], "rb") as f:
	source = f.read()
i = int(sys.argv[2])

if source.find("/Encrypt") > -1:
    print "/Encrypt object found. This PDF might be encrypted, thus it will not work if it's not decrypted first."
off =  source.find("%i 0 obj" % i)

if off == -1:
	print "object not found"
	sys.exit()

source = source[off:]
off = source.find("stream")
stream = source[off:]
stream = stream[:stream.find("endstream") + len("endstream")]

replaceme = template[template.find("%{"): template.find("%}") + 2]
template = template.replace(replaceme, stream)

#TODO: implement parsing of the original filters
template = template.replace("%Filters", "/Filter /FlateDecode")
with open(
        sys.argv[1].replace(".pdf", "-s%i.pdf" % i), 
        "wb"
        ) as f:
	f.write(template)

print "object extracted and embedded successfully"