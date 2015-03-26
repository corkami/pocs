"""converts a given alphanumerical (lowercase) string to the lowest needed base-encoded number"""
import sys
CHARS = "0123456789abcdefghijklmnopqrstuvwxyz"
s = sys.argv[1].lower()

b = 0
for i in s:
	b = max(b, CHARS.index(i))
b += 1
print "the minimum base is", b


r = 0
index_ = 1
for i in s[::-1]:
	r += CHARS.index(i) * index_
	index_ *= b

print "the string %s in base %i gives %i" % (s,b,r)
print "'%s' == (%i).toString(%i)" % (s, r, b)