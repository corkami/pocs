; a 268-byte PE 32+ (as small as possible), W7 x64 only

; similar to the 268 byte tiny PE, but more collapsing is required as code is bigger

;Ange Albertini, BSD Licence, 2010-2011

%include 'consts.inc'

IMAGEBASE equ 400000h

org IMAGEBASE

DOS_HEADER:
.e_magic       dw 'MZ'

align 4, db 0

istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend

istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_AMD64
    at IMAGE_FILE_HEADER.TimeDateStamp

hnprintf:
    dw 0
    db 'printf', 0

    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

istruc IMAGE_OPTIONAL_HEADER64
    at IMAGE_OPTIONAL_HEADER64.Magic,                     dw IMAGE_NT_OPTIONAL_HDR64_MAGIC

msvcrt.dll  db 'msvcrt.dll', 0 ; dll extension not required

    at IMAGE_OPTIONAL_HEADER64.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.ImageBase,                 dq IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.SectionAlignment,          dd 4      ; also sets e_lfanew
    at IMAGE_OPTIONAL_HEADER64.FileAlignment,             dd 4
    at IMAGE_OPTIONAL_HEADER64.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER64.SizeOfImage,               dd 40h    ; can't be smaller
    at IMAGE_OPTIONAL_HEADER64.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI

msvcrt.dll_iat:
__imp__printf:
    dq hnprintf - IMAGEBASE
    dq 0

    at IMAGE_OPTIONAL_HEADER64.NumberOfRvaAndSizes,       dd 2
iend

; data directories
dd 0, 0, Import_Descriptor - IMAGEBASE, 0

bits 64

EntryPoint:
    sub rsp, 8 * 5
    lea ecx, [message]
    call [__imp__printf]
    add rsp, 8 * 5
    retn

message db " * tiny 268 bytes PE32+ (W7 64b only)", 0ah, 0

Import_Descriptor:
;msvcrt.dll_DESCRIPTOR
    dd msvcrt.dll_iat - IMAGEBASE
    dd 0, 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;terminator
    dd 0, 0, 0, 0, 0

;filling up to 268 bytes :(
times 10 db 0
