; a 268-byte PE (as small as possible), W7 x64 Compatible

; same as the 252 bytes PE for W7, but the limit is 268 on W7 x64

;Ange Albertini, BSD Licence, 2010-2013

%include 'consts.inc'

IMAGEBASE equ 400000h

bits 32
org IMAGEBASE

DOS_HEADER:
.e_magic dw 'MZ'

align 4, db 0

istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,         dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.Characteristics, dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd 4      ; also sets e_lfanew
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd 4
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd 40h    ; can't be smaller
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             db IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 2
iend

; data directories
dd 0, 0
dd Import_Descriptor - IMAGEBASE

EntryPoint:
    push message
    call [__imp__printf]
    add esp, 1 * 4
    retn

message db " * tiny 268 bytes PE32 (W7 32b/64b)", 0ah, 0

Import_Descriptor:
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend

hnprintf:
    dw 0
    db 'printf', 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0

msvcrt.dll  db 'msvcrt.dll'

;filling up to 268 bytes for W7 x64, irritating... :(
times 5 db 0
