; dll loader with corrupted bound imports to call unexpected API

; Ange Albertini, BSD LICENCE 2009-2011

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

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.BoundImportsVA,   dd BoundImports - IMAGEBASE
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
Section0Start:
section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint:
    call [__imp__export]
    retn
_c

Import_Descriptor:
dll.dll_DESCRIPTOR:
    dd dll.dll_hintnames - IMAGEBASE
    dd -1, -1
    dd dll.dll - IMAGEBASE
    dd dll.dll_iat - IMAGEBASE
;terminator
    dd 0, 0, 0, 0, 0
_d

dll.dll_hintnames:
    dd hndllexport - IMAGEBASE
    dd 0
_d

hndllexport:
    dw 0
    db 'RealExport', 0
_d

dll.dll_iat:
__imp__export:
    dd 01001018h ; corrupted VA of the import
    dd 0
_d

dll.dll db 'dllbound.dll', 0
_d

BoundImports:
dd 31415925h
dw bounddll - BoundImports
dw 0

;terminator
dd 0, 0

bounddll db 'dllbound.dll', 0

align FILEALIGN, db 0

Section0Size EQU $ - Section0Start

SIZEOFIMAGE EQU $ - IMAGEBASE
