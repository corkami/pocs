#!/usr/bin/env python

# PyMuPDF script to embed data in a PDF via incremental update and
# either (mutually exclusive) standard attachment
# or ZIP polyglot with manual data storing and EoCD adjustments

# Ange Albertini 2019
# with the help of Nicolas Gregoire, Gynvael Coldwind and Philippe Teuwen

import fitz # from PyMuPDF
import os, sys, struct

ATTACHED = True

def createAttachment(doc, name, data):
	doc.embeddedFileAdd(name, data, name, name + "_")


def addStreamData(doc, data):
	# create a dummy object entry
	objNb = doc._getNewXref()
	doc._updateObject(objNb, '<<>>')

	# add contents of the archive
	doc._updateStream(objNb, data, new=True)


def adjustZIPcomment(name):
	# adjust ZIP archive comment length
	with open(name, "rb") as f:
		filedata = f.read()

	# locating the comment length in the ZIP's EoCD
	# 4:Sig  2:NbDisk 2: NbCD 2:TotalDisk 2:TotalCD
	# 	4:CDSize 4:Offset 2:ComLen
	offset = filedata.rfind("PK\5\6") + 20

	# new comment length
	length = len(filedata) - offset - 2

	with open(name, "wb") as f:
		f.write(filedata[:offset])
		f.write(struct.pack("<H", length))
		f.write(filedata[offset+2:])


pdf, attach  = sys.argv[1:3]

doc = fitz.open(pdf)

with open(attach, 'rb') as f:
	data = f.read()

if ATTACHED:
	# add as attachment
	createAttachment(doc, attach, data)
	doc.saveIncr()
else:
	# add as extra stream
	# appending one null byte to terminate the archive comment
	addStreamData(doc, data + "\0")
	# 255 = decompress all objects
	doc.save(doc.name, incremental=True, expand=255)
doc.close()

if not ATTACHED:
	adjustZIPcomment(pdf)
	os.system('zip -F %s --out F%s' % (pdf, pdf))
