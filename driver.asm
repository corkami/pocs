; a minimal driver

; Ange Albertini, BSD LICENCE 2009-2011

%include 'consts.inc'

IMAGEBASE EQU 10000H
org IMAGEBASE
bits 32

SECTIONALIGN equ 200h
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
    at IMAGE_OPTIONAL_HEADER32.CheckSum,                  dd 0fb5ah
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw 1 ; IMAGE_SUBSYSTEM_NATIVE
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

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

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint:
reloc0:
    push Msg
reloc1:
    call [__imp__DbgPrint]
    add esp, 1 * 4
_
    mov eax, 0xC0000182; STATUS_DEVICE_CONFIGURATION_ERROR
    retn 8
_c

ntoskrnl.exe_iat:
__imp__DbgPrint:
    dd hnDbgPrint - IMAGEBASE
    dd 0

Import_Descriptor:
;ntoskrnl.exe_DESCRIPTOR
    dd ntoskrnl.exe_hintnames - IMAGEBASE
    dd 0, 0
    dd ntoskrnl.exe - IMAGEBASE
    dd ntoskrnl.exe_iat - IMAGEBASE
times 5 dd 0

ntoskrnl.exe_hintnames:
    dd hnDbgPrint - IMAGEBASE
    dd 0

hnDbgPrint:
    dw 0
    db 'DbgPrint', 0

ntoskrnl.exe db 'ntoskrnl.exe',0
_d

Directory_Entry_Basereloc:
block_start0:
; relocation block start
    .VirtualAddress dd reloc0 - IMAGEBASE
    .SizeOfBlock dd base_reloc_size_of_block0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc0 + 1 - reloc0)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc1 + 2 - reloc0)
    base_reloc_size_of_block0 equ $ - block_start0
;relocation block end

;relocations end

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc
_d

Msg db " * minimalist driver", 0
_d

align FILEALIGN, db 0
