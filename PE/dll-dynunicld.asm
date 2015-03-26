; dll loader by unicode

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

EntryPoint:
    push start
    call [__imp__printf]
    add esp, 1 * 4
_
    push dllU
    call [__imp__LoadLibraryW]
    mov [h], eax
_
    push 0
    call [__imp__ExitProcess]
_c

start db ' * loading DLL by Unicode', 0ah, 0
_d

h dd 0
exp dd 0
_

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd hnLoadLibraryW - IMAGEBASE
    dd 0
_d

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
_d

hnLoadLibraryW:
    dw 0
    db 'LoadLibraryW', 0
_d

export db 'export', 0
_d

hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
__imp__LoadLibraryW:
    dd hnLoadLibraryW - IMAGEBASE
    dd 0
_d

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
align 2, db 0 ; required under W7
dllU db 'd', 0, 'l', 0, 'l', 0, '.', 0, 'd', 0, 'l', 0, 'l', 0, 0, 0
msvcrt.dll db 'msvcrt.dll', 0
_d

align FILEALIGN, db 0

