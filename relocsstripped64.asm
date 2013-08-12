; a PE32+ a PE using relocations, even if RELOCS_STRIPPED is set

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

IMAGEBASE equ 0436f726b616d0000h
org IMAGEBASE
bits 64

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
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_AMD64
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_RELOCS_STRIPPED
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER64
    at IMAGE_OPTIONAL_HEADER64.Magic,                 dw IMAGE_NT_OPTIONAL_HDR64_MAGIC
    at IMAGE_OPTIONAL_HEADER64.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.ImageBase,             dq IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER64.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER64.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER64.SizeOfImage,           dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER64.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER64.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER64.NumberOfRvaAndSizes,   dd 16
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd Import_Descriptor - IMAGEBASE
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
Section0Start:
section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint:
relocbase:
    sub rsp, 8 * 5
_
    call $ + 5
target:
    pop rdx

    sub rdx, target - IMAGEBASE
    mov rcx, IMAGEBASE
    sub rdx, rcx
reloc03:
    lea ecx, [Msg]
reloc13:
    call [__imp__printf]
_
    xor ecx, ecx
reloc23:
    call [__imp__ExitProcess]

_c

Msg db " * a PE32+ using relocations, even if RELOCS_STRIPPED is set (Delta: 0%016I64xh)", 0ah, 0

_d

Import_Descriptor:
_import_descriptor kernel32
_import_descriptor msvcrt
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32_hintnames dq hnExitProcess - IMAGEBASE, 0
msvcrt_hintnames   dq hnprintf - IMAGEBASE, 0

hnExitProcess _IMAGE_IMPORT_BY_NAME 'ExitProcess'
hnprintf      _IMAGE_IMPORT_BY_NAME 'printf'

kernel32_iat:
__imp__ExitProcess dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt_iat:
__imp__printf dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32 db 'kernel32.dll', 0
msvcrt db 'msvcrt.dll', 0
_d

Directory_Entry_Basereloc:
block_start0:
    .VirtualAddress dd relocbase - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK0
     dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc03 + 3 - relocbase)
     dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc13 + 3 - relocbase)
     dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc23 + 3 - relocbase)
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc

align FILEALIGN, db 0

Section0Size EQU $ - Section0Start

SIZEOFIMAGE EQU $ - IMAGEBASE
