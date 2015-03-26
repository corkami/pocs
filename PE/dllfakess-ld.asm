; dll with fake subsystem loader

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

EntryPoint:
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
    call [__imp__export]
    push 0
    call [__imp__ExitProcess]
_c

Msg db ' * imported a DLL with fake subsystem', 0ah, 0

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
_import_descriptor dll.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames dd hnExitProcess - IMAGEBASE, 0
dll.dll_hintnames      dd hndllexport - IMAGEBASE, 0
msvcrt.dll_hintnames   dd hnprintf - IMAGEBASE, 0
_d

_d

hnExitProcess _IMAGE_IMPORT_BY_NAME 'ExitProcess'
hndllexport   _IMAGE_IMPORT_BY_NAME 'exportfakeSS'
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

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnprintf _IMAGE_IMPORT_BY_NAME 'printf'

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
dll.dll db 'dllfakess.dll', 0
_d

align FILEALIGN, db 0

SIZEOFIMAGE EQU $ - IMAGEBASE
