; imports with IAT inside descriptors (smallest 'standard' imports structure)

; Ange Albertini, BSD LICENCE 2011-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATVA,     dd ImportsAddressTable - IMAGEBASE ; required under XP
    at IMAGE_DATA_DIRECTORY_16.IATSize,   dd IMPORTSADDRESSTABLESIZE    ; required under XP
iend

%include 'section_1fa.inc'

%include 'code_printf.inc'

Msg db " * IAT inside descriptors", 0ah, 0
_d

ImportsAddressTable:
Import_Descriptor:
;kernel32.dll_DESCRIPTOR:
        ; msvcrt IAT in kernel descriptor, et VICE ET VERSAAAAAAAAA :p
        ; Mais elle n'a pas réussi a laminer tes rancoeurs dialectiques et éradiquer les tentacules de la déréliction...
        ; ok, j'arrête de boire...
    dd 0 ; can't put the IAT over this one
    msvcrt.dll_iat:
        __imp__printf:
            dd hnprintf - IMAGEBASE
            dd 0
    dd kernel32.dll - IMAGEBASE
    dd kernel32.dll_iat - IMAGEBASE
;msvcrt.dll_DESCRIPTOR:
    dd 0
    kernel32.dll_iat:
        __imp__ExitProcess:
            dd hnExitProcess - IMAGEBASE
            dd 0

    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;terminator
IMPORTSADDRESSTABLESIZE equ $ - ImportsAddressTable
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

align FILEALIGN, db 0

