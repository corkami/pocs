# simple script to generate
# a minimal PDF with picture
# Sumatra/Adobe/Chrome/Evince compatible

# Ange Albertini, BSD Licence 2013

# usage: mkimage.py <test.jpg> <height> <width> <output.pdf>

template="""
%% a minimal PDF with picture
%% Sumatra/Adobe/Chrome/Evince compatible

%% Ange Albertini, BSD Licence 2013

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
612 0 0 612 0 80 cm
/Im0 Do
Q
endstream
endobj


5 0 obj
<<
    /Height %(height)i
    /Width %(width)i

    /ColorSpace /DeviceRGB
    /Subtype /Image
    /Filter [/ASCIIHexDecode /DCTDecode]
    /Type /XObject
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
with open(sys.argv[1], "rb") as s:
    data = s.read()
hex = ["%02x" % ord(c) for c in data]

hex = " ".join(hex)

with open(sys.argv[4], "wb") as t:
    height = int(sys.argv[2])
    width = int(sys.argv[3])
    t.write(template % globals())
