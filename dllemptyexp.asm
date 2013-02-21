; DLL with empty export name

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
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL
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
    at IMAGE_DATA_DIRECTORY_16.ExportsVA,  dd Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd import_descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,   dd Directory_Entry_Basereloc - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsSize, dd DIRECTORY_ENTRY_BASERELOC_SIZE
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
    push 1
    pop eax
    retn 3 * 4
_c

__exp__Export:
reloc31:
    push export
reloc42:
    call [__imp__printf]
    add esp, 1 * 4
    retn
_c

export db " * statically loaded DLL with empty export name", 0ah, 0
_d

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

import_descriptor:
;msvcrt.dll_DESCRIPTOR:
    dd msvcrt.dll_hintnames - IMAGEBASE
    dd 0
    dd 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE

    times 5 dd 0

msvcrt.dll_hintnames:
    DD hnprintf - IMAGEBASE
    DD 0

hnprintf:
    dw 0
    db 'printf', 0

msvcrt.dll db 'msvcrt.dll', 0

Exports_Directory:
  Characteristics       dd 0
  TimeDateStamp         dd 0
  MajorVersion          dw 0
  MinorVersion          dw 0
  Name                  dd aDllName - IMAGEBASE
  Base                  dd 0
  NumberOfFunctions     dd NUMBER_OF_FUNCTIONS
  NumberOfNames         dd NUMBER_OF_NAMES
  AddressOfFunctions    dd address_of_functions - IMAGEBASE
  AddressOfNames        dd address_of_names - IMAGEBASE
  AddressOfNameOrdinals dd address_of_name_ordinals - IMAGEBASE
_d

aDllName db 'completely unrelated dll name', 1, 2, 3, 4, 0
_d


address_of_functions:
    dd __exp__Export - IMAGEBASE
NUMBER_OF_FUNCTIONS equ ($ - address_of_functions) / 4
_d

address_of_names:
    dd a__exp__Export - IMAGEBASE
NUMBER_OF_NAMES equ ($ - address_of_names) / 4

_d
address_of_name_ordinals:
    dw 0
_d

a__exp__Export:
    db 0
_d

EXPORT_SIZE equ $ - Exports_Directory

Directory_Entry_Basereloc:
block_start0:
    .VirtualAddress dd reloc31 - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc31 + 1 - reloc31)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc42 + 2 - reloc31)
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc

align FILEALIGN, db 0
