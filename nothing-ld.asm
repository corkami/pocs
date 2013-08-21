; nothing.dll static loader
; TODO: printing then crashing under W7

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

EntryPoint:
	retn
_c

Import_Descriptor:
_import_descriptor dll.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

dll.dll_hintnames:
    dd hndllexport - IMAGEBASE
    dd 0
_d

hndllexport:
    dw 0
    db 'export', 0
_d

dll.dll_iat:
__imp__export:
    dd hndllexport - IMAGEBASE
    dd 0
_d

dll.dll db 'nothing.dll', 0
_d

align FILEALIGN, db 0

