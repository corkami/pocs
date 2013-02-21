; a PE with version customized minimal info - only to make the version tab appear

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
    at IMAGE_DATA_DIRECTORY_16.ResourceVA, dd Directory_Entry_Resource - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ResourceSize, dd RESOURCE_SIZE

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

; REQUIRED to start with the section !
Directory_Entry_Resource:
; root directory
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd RT_VERSION    ; .. resource type of that directory
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (resource_directory_type - Directory_Entry_Resource)
iend

resource_directory_type:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd 1 ; name of the underneath resource
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
    at IMAGE_RESOURCE_DATA_ENTRY.OffsetToData, dd resource_data - IMAGEBASE
    at IMAGE_RESOURCE_DATA_ENTRY.Size1, dd RESOURCE_SIZE
iend


resource_data:
VS_VERSION_INFO:
	.wLength dw VERSIONLENGTH
	.wValueLength dw VALUELENGTH
	.wType dw 0 ; 0 = bin, 1 = text
	WIDE 'VS_VERSION_INFO'
		align 4, db 0
	Value:
		istruc VS_FIXEDFILEINFO
			at VS_FIXEDFILEINFO.dwSignature, dd 0FEEF04BDh
		iend
	VALUELENGTH equ $ - Value
		align 4, db 0
VERSIONLENGTH equ $ - VS_VERSION_INFO

RESOURCE_SIZE equ $ - resource_data
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

align FILEALIGN, db 0
