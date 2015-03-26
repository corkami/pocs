; a PE with multiple import descriptors

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

EntryPoint:
    push Msg1
    call [__imp__printf1]
    add esp, 1 * 4
_
    push Msg2
    call [__imp__printf2]
    add esp, 1 * 4
    push 0
    call [__imp__ExitProcess]
_c

Msg1 db " * a PE with multiple descriptors", 0
Msg2 db " to the same DLL (under different names)", 0ah, 0
_d

Import_Descriptor:
_import_descriptor msvcrt1.dll
_import_descriptor kernel32.dll
_import_descriptor msvcrt2.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

msvcrt1.dll_hintnames:
    dd hnprintf1 - IMAGEBASE
    dd 0
kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt2.dll_hintnames:
    dd hnprintf2 - IMAGEBASE
    dd 0
_d

hnprintf1:
    dw 0
    db 'printf', 0
hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf2:
    dw 0
    db 'printf', 0
_d

msvcrt1.dll_iat:
__imp__printf1:
    dd hnprintf1 - IMAGEBASE
    dd 0

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt2.dll_iat:
__imp__printf2:
    dd hnprintf2 - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt1.dll db 'msvcrt.dll', 0
msvcrt2.dll db 'MSVcrt', 0
_d

align FILEALIGN, db 0
