# generates a minimal PDF with picture (PNG/JPG)
# Sumatra/Adobe/Chrome/Evince compatible
# not pdf.js (Firefox)

# Ange Albertini, BSD Licence 2013

# usage: mkimage.py <test.[jpg/png]> <width> <height> <output.pdf>

template="""%% generated with mkimage.py - Ange Albertini, BSD Licence 2013

%%PDF-1.4

1 0 obj
<<
    /Pages 2 0 R
>>
endobj


2 0 obj
<<
    /Count 1 %% 1 required for Evince
    /Kids [3 0 R] %% subobject required for Evince
>>
endobj


3 0 obj
<<
    /Type /Page
    /Parent 2 0 R
    /MediaBox [0 0 %(width)i %(height)i]
    /Contents 4 0 R
    /Resources
    <<
        /XObject <</Im0 5 0 R>>
    >>
>>
endobj


4 0 obj
<<>>
stream
q
%(width)i 0 0 %(height)i 0 0 cm
/Im0 Do
Q
endstream
endobj


5 0 obj
<<
    /Width %(width)i
    /Height %(height)i

    /ColorSpace /DeviceRGB
    /Subtype /Image
    /Filter [/ASCIIHexDecode %(filter)s] /Type /XObject
    /BitsPerComponent 8
>>
stream
%(hex)s
endstream
endobj

trailer
<<
    /Root 1 0 R %% external root required for Evince
>>
"""

import sys
imgfn, width, height, pdffn = sys.argv[1:5]

width, height = int(width), int(height)

with open(imgfn, "rb") as s:
    data = s.read()

if data.startswith("\x89PNG\r\n\x1a\n"):

    # need to convert the PNG to RAW
    print "filetype: PNG"
    import png, zlib

    data = png.Reader(open(imgfn, "rb")).asRGBA()[2]
    raw = ""
    # we need to remove every 4th element when converting to RAW - no alpha channel
    CHUNKSIZE = 4
    for arr in data:
        for index in range(len(arr) / CHUNKSIZE):
            sub = arr[index * CHUNKSIZE: (index + 1) * CHUNKSIZE]
            raw += "".join(chr(i) for i in sub[:CHUNKSIZE - 1])

    data = zlib.compress(raw)
    filter = "/FlateDecode"
else:
    # JPG is imported as is
    print "filetype: JPG (default)"
    filter = "/DCTDecode"

hex = ["%02x" % ord(c) for c in data]

hex = "".join(hex)

with open(pdffn, "wb") as t:
    t.write(template % globals())
