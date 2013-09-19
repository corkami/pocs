; PE with
; * a kernel range IMAGEBASE to force predictable relocations
; * and low alignment to make header writeable

; => relocation is applied to imagebase in memory, which corrects the wrong entrypoint

; Ange Albertini, BSD LICENCE 2011-2013

%include 'consts.inc'

IMAGEBASE equ 0FFFF0000h ; <==
DELTA equ 20202h
org IMAGEBASE
bits 32

SECTIONALIGN equ 800h
FILEALIGN equ SECTIONALIGN

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
    at IMAGE_FILE_HEADER.Characteristics,      dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE + DELTA ; <==
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,   dd Directory_Entry_Basereloc - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsSize, dd DIRECTORY_ENTRY_BASERELOC_SIZE
iend

%include 'section_1fa.inc'

EntryPoint:
reloc01:
    push msg
reloc22:
    call [__imp__printf]
    add esp, 1 * 4
    push 0
reloc42:
    call [__imp__ExitProcess]
_c

msg db " * relocated ImageBase (only affects EntryPoint)", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

Directory_Entry_Basereloc:

block_start0:
    .VirtualAddress dd reloc01 - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc01 + 1 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc22 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc42 + 2 - reloc01)
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0

block_start1:
    .VirtualAddress dd OptionalHeader - IMAGEBASE + IMAGE_OPTIONAL_HEADER32.ImageBase - 2
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK1
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | 0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | 1
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | 2
BASE_RELOC_SIZE_OF_BLOCK1 equ $ - block_start1

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc

align FILEALIGN, db 0

SIZEOFIMAGE EQU $ - IMAGEBASE
