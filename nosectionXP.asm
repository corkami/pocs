; Low Alignment PE for XP, with no sections.

; Ange Albertini, BSD LICENCE 2009-2011

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1
FILEALIGN equ 1

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Signature - IMAGEBASE
iend

NT_Signature:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw 0f40h ; 0 <= SizeOfOptionalHeader <= 1000h - (NT_Signature * 2)
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 77000000h ; filesize <=SizeofImage <= 77000000h
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd 77000000h - 1 ; 2ch <= SIZEOFHEADERS < SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    ; all these 3 are required for imports, under XP
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATVA,     dd ImportsAddressTable - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATSize,   dd IMPORTSADDRESSTABLESIZE
iend
SIZEOFHEADERS equ $ - IMAGEBASE

EntryPoint:
    push message
    call [__imp__printf]
    add esp, 1 * 4
    push 0
    call [__imp__ExitProcess]
_c

message db " * Low alignment PE with no section (XP)", 0ah, 0
_d

Import_Descriptor:
;kernel32.dll_DESCRIPTOR:
    dd kernel32.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd kernel32.dll - IMAGEBASE
    dd kernel32.dll_iat - IMAGEBASE
;msvcrt.dll_DESCRIPTOR:
    dd msvcrt.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;terminator
    dd 0, 0, 0, 0, 0
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
msvcrt.dll db 'msvcrt.dll';, 0
