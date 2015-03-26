; PE with fake delay imports

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,        dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.DelayImportsVA,   dd delay_imports - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.DelayImportsSize, dd DELAY_IMPORTS_SIZE
iend

%include 'section_1fa.inc'

%include 'code_printf.inc'

Msg db " * fake delay imports data obfuscation", 0ah, 0
_d

fakedll db 'fake.dll', 0

Import_Descriptor:
_import_descriptor kernel32
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd hnLoadLibraryA - IMAGEBASE
    dd hnGetProcAddress - IMAGEBASE
    dd 0

;msvcrt_int:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnLoadLibraryA:
    dw 0
    db 'LoadLibraryA', 0
hnGetProcAddress:
    dw 0
    db 'GetProcAddress', 0
_d

kernel32_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
__imp__LoadLibraryA:
    dd hnLoadLibraryA - IMAGEBASE
__imp__GetProcAddress:
    dd hnGetProcAddress - IMAGEBASE
    dd 0

msvcrt.dll_iat:
    dd hnprintf - IMAGEBASE
    dd 0
_d

msvcrt_int:
    dd hnprintf - IMAGEBASE
    dd 0
_d
hnprintf:
    dw 0
    db 'fake',0

kernel32 db 'kernel32.dll', 0
_d

delay_imports: ;****************************************************************
istruc _IMAGE_DELAY_IMPORT_DESCRIPTOR
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.rvaDLLName, dd fakedll
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.rvaIAT,     dd delay_iat - IMAGEBASE
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.rvaINT,     dd msvcrt_int
iend
istruc _IMAGE_DELAY_IMPORT_DESCRIPTOR
iend

delay_iat:
__imp__printf:
    dd __delay__printf
    dd 0
_d

printf db 'printf', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

__delay__printf:
    push msvcrt.dll
    call [__imp__LoadLibraryA]
    push printf
    push eax
    call [__imp__GetProcAddress]
    push eax
    retn
_c

DELAY_IMPORTS_SIZE equ $ - delay_imports

align FILEALIGN, db 0
