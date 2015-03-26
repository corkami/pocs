#cut PDF after each %%EOF

import sys
filename = sys.argv[1]
with open(filename, "rb") as f:
	d = f.read()
i = 1
while d.count("%%EOF") > 1:
	d = d[:d.rfind("%%EOF") + 6]
	with open("%i-%s" % (i, filename), "wb") as f:
		f.write(d)
	i += 1
	d = d[:-6]

		