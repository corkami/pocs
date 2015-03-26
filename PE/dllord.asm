; DLL with exports by ordinal and heavily export corrupted structure

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

IMAGEBASE equ 400000h ;<=====
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

NT_Headers:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,              dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,     dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader, dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,      dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL ; <======
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA,  dd Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd import_descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,   dd Directory_Entry_Basereloc - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsSize, dd DIRECTORY_ENTRY_BASERELOC_SIZE
iend

%include 'section_1fa.inc'

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

export db " * DLL export by ordinal called", 0ah, 0
_d

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

import_descriptor:
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend


msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0

hnprintf:
    dw 0
    db 'printf', 0
_d

msvcrt.dll db 'msvcrt.dll', 0
_d

Exports_Directory: ;************************************************************
istruc IMAGE_EXPORT_DIRECTORY
  at IMAGE_EXPORT_DIRECTORY.Characteristics,       dd -1
  at IMAGE_EXPORT_DIRECTORY.TimeDateStamp,         dd -1
  at IMAGE_EXPORT_DIRECTORY.MajorVersion,          dw -1
  at IMAGE_EXPORT_DIRECTORY.MinorVersion,          dw -1
  at IMAGE_EXPORT_DIRECTORY.nName,                 dd -1
  at IMAGE_EXPORT_DIRECTORY.nBase,                 dd 313h
  at IMAGE_EXPORT_DIRECTORY.NumberOfFunctions,     dd -1
  at IMAGE_EXPORT_DIRECTORY.NumberOfNames,         dd -1
  at IMAGE_EXPORT_DIRECTORY.AddressOfFunctions,    dd address_of_functions - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNames,        dd -1
  at IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals, dd -1
iend
_d

address_of_functions:
    dd -1                                   ; bogus entry that will be 313h
    dd __exp__Export - IMAGEBASE
_d

EXPORT_SIZE equ -1

Directory_Entry_Basereloc: ;****************************************************
block_start0:
    .VirtualAddress dd reloc31 - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc31 + 1 - reloc31)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc42 + 2 - reloc31)
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc

align FILEALIGN, db 0

