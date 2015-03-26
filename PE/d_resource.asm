; a resource only data-PE

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

SOME_TYPE equ 315h
SOME_NAME equ 7354h

bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
times 3ch-2 db -1
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers
iend

NT_Headers:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
times 4 dd -1
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader, dw SIZEOFOPTIONALHEADER
dw -1
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic, dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
times 58 db -1
	at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders, dd 1000h
times 32 db -1
iend

istruc IMAGE_DATA_DIRECTORY_16
times 4 dd -1
    at IMAGE_DATA_DIRECTORY_16.ResourceVA, dd Directory_Entry_Resource, -1
times 13 * 2 dd -1
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
SIZEOFHEADERS equ $

section progbits vstart=SECTIONALIGN align=FILEALIGN

Directory_Entry_Resource: ;*****************************************************
; root directory
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd SOME_TYPE
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (resource_directory_type - Directory_Entry_Resource)
iend

resource_directory_type:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd SOME_NAME
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (resource_directory_language - Directory_Entry_Resource)
iend

resource_directory_language:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd resource_entry - Directory_Entry_Resource
iend

resource_entry:
istruc IMAGE_RESOURCE_DATA_ENTRY
    at IMAGE_RESOURCE_DATA_ENTRY.OffsetToData, dd resource_data
    at IMAGE_RESOURCE_DATA_ENTRY.Size1, dd RESOURCE_SIZE
iend

resource_data:
db " * resource-only data PE", 0ah, 0

RESOURCE_SIZE equ $ - resource_data
_d
