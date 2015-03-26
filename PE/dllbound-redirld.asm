; dll loader with corrupted bound imports to call unexpected API

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,      dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.BoundImportsVA, dd BoundImports - IMAGEBASE
iend

%include 'section_1fa.inc'

EntryPoint:
    call [__imp__export]
    retn
_c

Import_Descriptor:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd dll.dll_hintnames - IMAGEBASE
    dd -1, -1
    at IMAGE_IMPORT_DESCRIPTOR.Name1,              dd dll.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,         dd dll.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

dll.dll_hintnames:
    dd hndllexport - IMAGEBASE
    dd 0
_d

hndllexport:
    dw 0
    db 'RealExport', 0
_d

dll.dll_iat:
__imp__export:
    dd 01001018h ; corrupted VA of the import
    dd 0
_d

dll.dll db 'dllbound.dll', 0
_d

BoundImports:
    dd 31415925h
    dw bounddll - BoundImports
    dw 0

;terminator
dd 0, 0

bounddll db 'dllbound.dll', 0

align FILEALIGN, db 0

