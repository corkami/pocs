; complete PE example, as if compiled via MASM, including RichHeader, dos stubs, alignments...
; Ange Albertini, BSD Licence, 2010-2013

%include 'consts.inc'

IMAGEBASE equ 4000000h
org IMAGEBASE

SECTIONALIGN EQU 1000h
FILEALIGN EQU 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,    db 'MZ'
    at IMAGE_DOS_HEADER.e_cblp,     dw 090h
    at IMAGE_DOS_HEADER.e_cp,       dw 3
    at IMAGE_DOS_HEADER.e_cparhdr,  dw (dos_stub - IMAGEBASE) >> 4
    at IMAGE_DOS_HEADER.e_maxalloc, dw 0ffffh
    at IMAGE_DOS_HEADER.e_sp,       dw 0b8h
    at IMAGE_DOS_HEADER.e_lfarlc,   dw 040h
    at IMAGE_DOS_HEADER.e_lfanew,   dd NT_Headers - IMAGEBASE
iend
align 010h, db 0

dos_stub:
bits 16
    push cs
    pop  ds
    mov  dx, dos_msg - dos_stub
    mov  ah, 9
    int  21h
    mov  ax, 4c01h
    int  21h
dos_msg
    db 'This program cannot be run in DOS mode.', 0dh, 0dh, 0ah, '$'
align 16, db 0

RichHeader:
    dd "DanS" ^ RichKey,    0 ^ RichKey, 0 ^ RichKey,        0 ^ RichKey
    dd 0131f8eh ^ RichKey,  7 ^ RichKey, 01220fch ^ RichKey, 1 ^ RichKey
    dd "Rich", 0 ^ RichKey, 0, 0
align 16, db 0

NT_Headers:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend

FILE_HEADER:
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,              dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,     dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.TimeDateStamp,        dd 04b51f504h       ; 2010/1/16 5:19pm
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader, dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,      dw IMAGE_FILE_RELOCS_STRIPPED | IMAGE_FILE_EXECUTABLE_IMAGE | \
            IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE
iend

optional_header:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                       dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.MajorLinkerVersion,          db 05h
    at IMAGE_OPTIONAL_HEADER32.MinorLinkerVersion,          db 0ch
    at IMAGE_OPTIONAL_HEADER32.SizeOfCode,                  dd SIZEOFCODE
    at IMAGE_OPTIONAL_HEADER32.SizeOfInitializedData,       dd SIZEOFINITIALIZEDDATA
    at IMAGE_OPTIONAL_HEADER32.SizeOfUninitializedData,     dd SIZEOFUNINITIALIZEDDATA
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,         dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.BaseOfCode,                  dd base_of_code - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.BaseOfData,                  dd base_of_data - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                   dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,            dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,               dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorOperatingSystemVersion, dw 04h
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,       dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,                 dd SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,               dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                   dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.SizeOfStackReserve,          dd 100000h
    at IMAGE_OPTIONAL_HEADER32.SizeOfStackCommit,           dd 1000h
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeapReserve,           dd 100000h
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeapCommit,            dd 1000h
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,         dd NUMBEROFRVAANDSIZES
iend

data_directory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE, DIRECTORY_ENTRY_IMPORT_SIZE
    at IMAGE_DATA_DIRECTORY_16.IATVA,     dd ImportAddressTable - IMAGEBASE, IAT_size
iend
NUMBEROFRVAANDSIZES EQU ($ - data_directory) / (2 * 4)


; DIRECTORY_ENTRY_DEBUG Size should be small, like 0x1000 or less
; Independantly of NumberOfRvaAndSizes. thus, Dword at DATA_DIRECTORY + 34h

section_header:
SIZEOFOPTIONALHEADER EQU $ - optional_header
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.Name,             db '.text'
    at IMAGE_SECTION_HEADER.VirtualSize,      dd SECTION0VS
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd SECTION0SIZE
    at IMAGE_SECTION_HEADER.PointerToRawData, dd SECTION0OFFSET
    at IMAGE_SECTION_HEADER.Characteristics,  dd \
        IMAGE_SCN_CNT_CODE | IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_READ
iend
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.Name,             db '.rdata'
    at IMAGE_SECTION_HEADER.VirtualSize,      dd SECTION1VS
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd Section1Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd SECTION1SIZE
    at IMAGE_SECTION_HEADER.PointerToRawData, dd SECTION1OFFSET
    at IMAGE_SECTION_HEADER.Characteristics,  dd \
        IMAGE_SCN_CNT_INITIALIZED_DATA | IMAGE_SCN_MEM_READ
iend
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.Name,             db '.data'
    at IMAGE_SECTION_HEADER.VirtualSize,      dd SECTION2VS
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd Section2Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd SECTION2SIZE
    at IMAGE_SECTION_HEADER.PointerToRawData, dd SECTION2OFFSET
    at IMAGE_SECTION_HEADER.Characteristics,  dd \
        IMAGE_SCN_CNT_INITIALIZED_DATA | IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS EQU ($ - section_header) / IMAGE_SECTION_HEADER_size

ALIGN FILEALIGN, db 0
SIZEOFHEADERS EQU $ - IMAGEBASE

;******************************************************************************

SECTION0OFFSET EQU $ - IMAGEBASE

SECTION code valign = SECTIONALIGN
Section0Start:

bits 32
base_of_code:

EntryPoint:
    push Msg
    call printf
    add esp, 1 * 4
    push 0
    call ExitProcess
printf:
    jmp [__imp__printf]
ExitProcess:
    jmp [__imp__ExitProcess]

SECTION0VS equ $ - Section0Start
align FILEALIGN,db 0
SECTION0SIZE EQU $ - Section0Start
SIZEOFCODE equ $ - base_of_code

;******************************************************************************

SECTION1OFFSET equ $ - Section0Start + SECTION0OFFSET
SECTION idata valign = SECTIONALIGN
Section1Start:
base_of_data:

Import_Descriptor:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd kernel32.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1,              dd kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,         dd kernel32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd msvcrt.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1,              dd msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,         dd msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess _IMAGE_IMPORT_BY_NAME 'ExitProcess'
hnprintf      _IMAGE_IMPORT_BY_NAME 'printf'

_d

ImportAddressTable:
kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d
IAT_size equ $ - ImportAddressTable

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

DIRECTORY_ENTRY_IMPORT_SIZE equ $ - Import_Descriptor
SECTION1VS equ $ - Section1Start

align FILEALIGN,db 0

;******************************************************************************

SECTION1SIZE EQU $ - Section1Start
SECTION2OFFSET equ $ - Section1Start + SECTION1OFFSET
SECTION data valign = SECTIONALIGN

Section2Start:
Msg db " * a 'compiled' PE", 0ah, 0

SECTION2VS equ $ - Section2Start

ALIGN FILEALIGN,db 0
SECTION2SIZE EQU $ - Section2Start
;SIZEOFINITIALIZEDDATA equ $ - base_of_data ; too complex

;******************************************************************************

SIZEOFINITIALIZEDDATA equ SECTION2SIZE + SECTION1SIZE
uninit_data:
SIZEOFUNINITIALIZEDDATA equ $ - uninit_data

SIZEOFIMAGE EQU $ - IMAGEBASE
