; a PE with multiple import descriptors

; Ange Albertini, BSD LICENCE 2012

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

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
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
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
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd Import_Descriptor - IMAGEBASE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint:
    push Msg1
    call [__imp__printf1]
    add esp, 1 * 4
_
    push Msg2
    call [__imp__printf2]
    add esp, 1 * 4
    push 0
    call [__imp__ExitProcess]
_c

Msg1 db " * a PE with multiple descriptors", 0
Msg2 db " to the same DLL (under different names)", 0ah, 0
_d

Import_Descriptor:
;msvcrt.dll_DESCRIPTOR:
    dd msvcrt1.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd msvcrt1.dll - IMAGEBASE
    dd msvcrt1.dll_iat - IMAGEBASE
;kernel32.dll_DESCRIPTOR:
    dd kernel32.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd kernel32.dll - IMAGEBASE
    dd kernel32.dll_iat - IMAGEBASE
;msvcrt.dll_DESCRIPTOR:
    dd msvcrt2.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd msvcrt2.dll - IMAGEBASE
    dd msvcrt2.dll_iat - IMAGEBASE
;terminator
    dd 0, 0, 0, 0, 0
_d

msvcrt1.dll_hintnames:
    dd hnprintf1 - IMAGEBASE
    dd 0
kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt2.dll_hintnames:
    dd hnprintf2 - IMAGEBASE
    dd 0
_d

hnprintf1:
    dw 0
    db 'printf', 0
hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf2:
    dw 0
    db 'printf', 0
_d

msvcrt1.dll_iat:
__imp__printf1:
    dd hnprintf1 - IMAGEBASE
    dd 0

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt2.dll_iat:
__imp__printf2:
    dd hnprintf2 - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt1.dll db 'msvcrt.dll', 0
msvcrt2.dll db 'MSVcrt', 0
_d

align FILEALIGN, db 0
