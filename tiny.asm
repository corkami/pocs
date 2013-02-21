; a 268-byte PE (as small as possible), XP-W7x64 compatible

; similar with the w7 x64 PE, but larger sizeofimage and IAT required. XP compat also requires Debug Size and TLS VA to be null

;Ange Albertini, BSD Licence, 2010-2011

%include 'consts.inc'

IMAGEBASE equ 400000h

org IMAGEBASE

DOS_HEADER:
.e_magic dw 'MZ'

align 4, db 0

istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.TimeDateStamp
msvcrt.dll  db 'msvcrt.dll', 0 ; keeping the extension in case it'd work under W2K
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE ; | IMAGE_FILE_32BIT_MACHINE

iend

istruc IMAGE_OPTIONAL_HEADER32
        at IMAGE_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
bits 32
EntryPoint:
    push message
    call [__imp__printf]
    jmp _2
        at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
        at IMAGE_OPTIONAL_HEADER32.BaseOfCode, dd 0 ; must be valid for W7
_2:
    add esp, 1 * 4
    retn
        at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
        at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd 4      ; also sets e_lfanew
        at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd 4

ImportsAddressTable:
msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
IMPORTSADDRESSTABLESIZE equ $ - ImportsAddressTable

        at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
        at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd SIZEOFIMAGE
        at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFIMAGE - 1
        at IMAGE_OPTIONAL_HEADER32.Subsystem,                 db IMAGE_SUBSYSTEM_WINDOWS_CUI
hnprintf:
    dw 0
    db 'printf', 0

        at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 13
iend

istruc IMAGE_DATA_DIRECTORY_13

        at IMAGE_DATA_DIRECTORY_13.ImportsVA,   dd Import_Descriptor - IMAGEBASE

Import_Descriptor:
;msvcrt.dll_DESCRIPTOR
    dd msvcrt.dll_iat - IMAGEBASE
    dd 0, 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;terminator
    dd 0, 0, 0, 0
        at IMAGE_DATA_DIRECTORY_13.DebugSize, dd 0 ; required for safety under XP

        at IMAGE_DATA_DIRECTORY_13.TLSVA, dd 0 ; required for safety under XP

        at IMAGE_DATA_DIRECTORY_13.IATVA,     dd ImportsAddressTable - IMAGEBASE ; required under XP
        at IMAGE_DATA_DIRECTORY_13.IATSize,   dd IMPORTSADDRESSTABLESIZE    ; required under XP
iend

message db " * 268b universal tiny PE (XP-W7x64)", 0ah, 0

times 268 - 266 db 0
SIZEOFIMAGE equ 268

struc IMAGE_DATA_DIRECTORY_13
    .ExportsVA        resd 1
    .ExportsSize      resd 1
    .ImportsVA        resd 1
    .ImportsSize      resd 1
    .ResourceVA       resd 1
    .ResourceSize     resd 1
    .Exception        resd 2
    .Security         resd 2
    .FixupsVA         resd 1
    .FixupsSize       resd 1
    .DebugVA          resd 1
    .DebugSize        resd 1
    .Description      resd 2
    .MIPS             resd 2
    .TLSVA            resd 1
    .TLSSize          resd 1
    .Load             resd 2
    .BoundImportsVA   resd 1
    .BoundImportsSize resd 1
    .IATVA            resd 1
    .IATSize          resd 1
endstruc