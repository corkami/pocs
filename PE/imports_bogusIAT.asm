; a PE with a bogus IAT

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATVA,     dd ImportAddressTable - IMAGEBASE, IAT_SIZE
iend

%include 'section_1fa.inc'

%include 'code_printf.inc'

Msg db " * a PE with a bogus IAT", 0ah, 0
_d

Import_Descriptor:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd kernel32.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1,              dd kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,         dd kernel32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd msvcrt.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1,              dd msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,         dd msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames dd hnExitProcess - IMAGEBASE, 0
msvcrt.dll_hintnames   dd hnprintf - IMAGEBASE, 0
_d

hnExitProcess db 0,0, 'ExitProcess', 0
hnprintf      db 0,0, 'printf', 0
hnfake1       db 0,0, 'HI', 0
hnfake2       db 0,0, 'MUM', 0
_d

ImportAddressTable:
kernel32.dll_iat:
__imp__ExitProcess:
    dd hnfake1 - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnfake2 - IMAGEBASE
    dd 0
IAT_SIZE equ $ - ImportAddressTable
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

align FILEALIGN, db 0
