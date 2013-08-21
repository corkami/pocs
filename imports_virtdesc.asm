; PE with 1st import descriptor starting in virtual space

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd Import_Descriptor - IMAGEBASE - 3 * 4 ; <==
        at IMAGE_DATA_DIRECTORY_16.IATVA,   dd ImportsAddressTable - IMAGEBASE ; required under XP
        at IMAGE_DATA_DIRECTORY_16.IATSize, dd IMPORTSADDRESSTABLESIZE    ; required under XP
iend

%include 'section_1fa.inc'

Import_Descriptor:
;kernel32.dll_DESCRIPTOR:
    ;dd kernel32.dll_hintnames - IMAGEBASE
    ;dd 0, 0
    dd kernel32.dll - IMAGEBASE
    dd kernel32.dll_iat - IMAGEBASE
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
_d
ImportsAddressTable:
kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
IMPORTSADDRESSTABLESIZE equ $ - ImportsAddressTable
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

%include 'code_printf.inc'

Msg db " * virtual 1st import descriptor", 0ah, 0
_d

align FILEALIGN, db 0
