; PE with decryption via relocations
; relocations itself are fixed by relocations
; a fake block uses do-nothing relocations on code
; another fake block does all kinds of relocations on a dummy entry

; some relocations are not using the common HIGHLOW, such as MIPS_JMPADDR

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'
%define iround(n, r) (((n + (r - 1)) / r) * r)

IMAGEBASE equ 0ffff0000h
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
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd VDELTA + EntryPoint - IMAGEBASE ;<===
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd VDELTA + SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd VDELTA + Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,   dd VDELTA + Directory_Entry_Basereloc - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsSize, dd DIRECTORY_ENTRY_BASERELOC_SIZE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd Section0Size
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd VDELTA + Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd iround(Section0Size, FILEALIGN)
    at IMAGE_SECTION_HEADER.PointerToRawData, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE + IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

ALIGN FILEALIGN, db 0

SIZEOFHEADERS equ $ - IMAGEBASE

Section0Start:
VDELTA equ SECTIONALIGN - ($ - IMAGEBASE) ; VIRTUAL DELTA between this sections offset and virtual addresses
db 0,0
EntryPoint:

reloc01:            ;68h push VDELTA + msg
crypt168 db 0
    dd VDELTA + msg

reloc22:            ; FF15 call [VDELTA + __imp__printf]
crypt2ff db 1
crypt315 db 1
    dd VDELTA + __imp__printf

crypt483 db 1       ;83C404 add esp, 1 * 4
crypt5c4 db 0
crypt604 db 0

crypt76a db 0, 0    ;6A00 push 0

reloc42:            ;FF15 call [VDELTA + __imp__ExitProcess]
crypt8ff db 1
crypt915 db 1
    dd VDELTA + __imp__ExitProcess
_c

msg db " * decryption via relocations", 0ah, 0
_d

Import_Descriptor:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd VDELTA + kernel32.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1             , dd VDELTA + kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk        , dd VDELTA + kernel32.dll_iat - IMAGEBASE
iend                                             
istruc IMAGE_IMPORT_DESCRIPTOR                   
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd VDELTA + msvcrt.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1             , dd VDELTA + msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk        , dd VDELTA + msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd VDELTA + hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd VDELTA + hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
dummy dq 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd VDELTA + hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd VDELTA + hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

Directory_Entry_Basereloc:

block_start_do_nothing: ; does nothing
    .VirtualAddress dd VDELTA + EntryPoint - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK_DO_NOTHING
    dw IMAGE_REL_BASED_ABSOLUTE << 12
    dw IMAGE_REL_BASED_LOW      << 12
    dw IMAGE_REL_BASED_SECTION  << 12
    dw IMAGE_REL_BASED_REL32    << 12
BASE_RELOC_SIZE_OF_BLOCK_DO_NOTHING equ $ - block_start_do_nothing

block_start_dummy: ; does something on a dummy entry
    .VirtualAddress dd VDELTA + dummy - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK_DUMMY
    dw IMAGE_REL_BASED_ABSOLUTE     << 12
    dw IMAGE_REL_BASED_HIGH         << 12
    dw IMAGE_REL_BASED_LOW          << 12
    dw IMAGE_REL_BASED_HIGHLOW      << 12
    dw IMAGE_REL_BASED_HIGHADJ      << 12, 8 << 12 ; outputting a fake type 8 for bad parsers
    dw IMAGE_REL_BASED_MIPS_JMPADDR << 12
    dw IMAGE_REL_BASED_SECTION      << 12
    dw IMAGE_REL_BASED_REL32        << 12
    dw IMAGE_REL_BASED_IA64_IMM64   << 12
    dw IMAGE_REL_BASED_DIR64        << 12
BASE_RELOC_SIZE_OF_BLOCK_DUMMY equ $ - block_start_dummy

; this block will fix the SizeOfBlock of the next block
block_start:
    .VirtualAddress dd VDELTA + relocated_reloc - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK
    dw (IMAGE_REL_BASED_HIGHLOW << 12) ; + 10000h
    dw (IMAGE_REL_BASED_HIGHLOW << 12) ; + 10000h
    dw (IMAGE_REL_BASED_HIGH    << 12) ; + 00001h
    dw (IMAGE_REL_BASED_MIPS_JMPADDR << 12)
BASE_RELOC_SIZE_OF_BLOCK equ $ - block_start

;this block is actually the genuine relocations
block_start0:
    .VirtualAddress dd VDELTA + reloc01 - IMAGEBASE
relocated_reloc:
    .SizeOfBlock dd (BASE_RELOC_SIZE_OF_BLOCK0 - 40002h - (0fc000000h + (20000h >> 2))) & 0ffffffffh
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc01 + 1 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc22 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc42 + 2 - reloc01)
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0

%macro cryptblock 2
block_start%1:
    .VirtualAddress dd VDELTA + %1 - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK%1
    dw (IMAGE_REL_BASED_ABSOLUTE << 12)
    times %2 / 2 dw (IMAGE_REL_BASED_HIGH << 12)
BASE_RELOC_SIZE_OF_BLOCK%1 equ $ - block_start%1
%endmacro

;these blocks are the ones to implement the decryption
cryptblock crypt168, 068h
cryptblock crypt2ff, 0feh
cryptblock crypt315, 015h
cryptblock crypt483, 083h
cryptblock crypt5c4, 0c4h
cryptblock crypt604, 004h
cryptblock crypt76a, 06ah
cryptblock crypt8ff, 0ffh
cryptblock crypt915, 015h

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc

align FILEALIGN, db 0

Section0Size EQU $ - Section0Start

SIZEOFIMAGE EQU $ - IMAGEBASE
