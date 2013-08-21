; a non managed PE with MSCOREE imports

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

next:
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

EntryPoint:
    jmp [lpnext]

;*******************************************************************************

lpnext dd next

Msg db " * a non-managed PE with mscoree.dll imports", 0ah, 0
_d

;*******************************************************************************

Import_Descriptor:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd aMscoree_dll  - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd mscoree.dll_iat  - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd kernel32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR ;terminator
iend


hn_CoreExeMain db 0,0, '_CorExeMain',0
hnExitProcess  db 0,0, 'ExitProcess', 0
hnprintf       db 0,0, 'printf', 0
_d

mscoree.dll_iat:
__imp__corexemain:
    dd hn_CoreExeMain - IMAGEBASE
    dd 0

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

aMscoree_dll db 'mscoree.dll',0
kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

;*******************************************************************************

align FILEALIGN, db 0
