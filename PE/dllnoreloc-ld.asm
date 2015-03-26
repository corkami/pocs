; no relocation dll loader

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

EntryPoint:
    ; we know the address in advance... risky !
    call 3301008h
    ;call [__imp__export]
    push 0
    call [__imp__ExitProcess]
_c

Import_Descriptor: ;************************************************************
_import_descriptor kernel32.dll
_import_descriptor dll.dll
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
    dd hndllexport - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
dll.dll db 'dllnoreloc.dll', 0
_d

align FILEALIGN, db 0
