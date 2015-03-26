; dllord loader

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

EntryPoint:
    call [__imp__export]
    push 0
    call [__imp__ExitProcess]
_c

Import_Descriptor:
_import_descriptor kernel32.dll
istruc IMAGE_IMPORT_DESCRIPTOR
OriginalFirstThunk
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd dll.dll_iat - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1,              dd dll.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,         dd dll.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
_d

dll.dll_hintnames:
    dd hndllexport - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
_d

hndllexport:
    dw 0
    db 'export', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0
_d
dll.dll_iat:
__imp__export:
    dd 80000314h
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
dll.dll db 'dllord.dll', 0
_d

align FILEALIGN, db 0

